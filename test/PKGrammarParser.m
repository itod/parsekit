//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PKGrammarParser.h"
#import <ParseKit/ParseKit.h>

// start                = statement*;
// statement            = tokenizerDirective | decl;
// tokenizerDirective   = '@'! ~'start' '=' (~';')+ ';'!;
// decl                 = production '=' action? expr ';'!;
// production           = startProduction | varProduction;
// startProduction      = '@'! 'start'!;
// varProduction        = LowercaseWord;
// expr                 = term orTerm*;
// term                 = semanticPredicate? factor nextFactor*;
// orTerm               = '|' term;
// factor               = (phrase | phraseStar | phrasePlus | phraseQuestion) action?;
// nextFactor           = factor;

// phrase               = primaryExpr predicate*;
// phraseStar           = phrase '*'!;
// phrasePlus           = phrase '+'!;
// phraseQuestion       = phrase '?'!;

// action               = %{'{', '}'};
// semanticPredicate    = %{'{', '}?'};

// predicate            = (intersection | difference);
// intersection         = '&'! primaryExpr;
// difference           = '-'! primaryExpr;

// primaryExpr          = negatedPrimaryExpr | barePrimaryExpr;
// negatedPrimaryExpr   = '~'! barePrimaryExpr;
// barePrimaryExpr      = atomicValue | subSeqExpr | subTrackExpr;
// subSeqExpr           = '(' expr ')'!;
// subTrackExpr         = '[' expr ']'!;
// atomicValue          = parser discard?;
// parser               = pattern | literal | variable | constant | specificConstant | delimitedString;
// discard              = '!';
// pattern              = %{'/', '/'};
// delimitedString      = '%{' QuotedString (',' QuotedString)? '}'!;
// literal              = QuotedString;
// variable             = LowercaseWord;
// constant             = UppercaseWord;

@interface NSObject (PKGrammarParserAdditions)
- (void)parser:(PKParser *)p didMatchTokenizerDirective:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDecl:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSubSeqExpr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSubTrackExpr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchStartProduction:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchVarProduction:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchIntersection:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchAction:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSemanticPredicate:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDifference:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPattern:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDiscard:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchLiteral:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchVariable:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSpecificConstant:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDelimitedString:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPhraseStar:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPhrasePlus:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPhraseQuestion:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchOrTerm:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNegatedPrimaryExpr:(PKAssembly *)a;
@end

@interface PKGrammarParser ()
- (PKAlternation *)zeroOrOne:(PKParser *)p;
- (PKSequence *)oneOrMore:(PKParser *)p;
@end

@implementation PKGrammarParser

- (id)initWithAssembler:(id)a {
    self = [super init];
    if (self) {
        assembler = a;
    }
    return self;
}


- (void)dealloc {
    PKReleaseSubparserTree(self.parser);

    self.parser = nil;
    self.statementParser = nil;
    self.tokenizerDirectiveParser = nil;
    self.declParser = nil;
    self.productionParser = nil;
    self.varProductionParser = nil;
    self.startProductionParser = nil;
    self.tokenizerDirectiveParser = nil;
    self.exprParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.actionParser = nil;
    self.semanticPredicateParser = nil;
    self.phraseStarParser = nil;
    self.phrasePlusParser = nil;
    self.phraseQuestionParser = nil;
    self.primaryExprParser = nil;
    self.negatedPrimaryExprParser = nil;
    self.barePrimaryExprParser = nil;
    self.predicateParser = nil;
    self.intersectionParser = nil;
    self.differenceParser = nil;
    self.atomicValueParser = nil;
    self.parserParser = nil;
    self.discardParser = nil;
    self.patternParser = nil;
    self.delimitedStringParser = nil;
    self.literalParser = nil;
    self.variableParser = nil;
    self.constantParser = nil;
    self.specificConstantParser = nil;
    [super dealloc];
}


- (PKAlternation *)zeroOrOne:(PKParser *)p {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[PKEmpty empty]];
    [a add:p];
    return a;
}


- (PKSequence *)oneOrMore:(PKParser *)p {
    PKSequence *s = [PKSequence sequence];
    [s add:p];
    [s add:[PKRepetition repetitionWithSubparser:p]];
    return s;
}


- (PKCompositeParser *)parser {
    if (!parser) {
        self.parser = [PKRepetition repetitionWithSubparser:self.statementParser];
    }
    return parser;
}


// statement            = tokenizerDirective | decl;
- (PKCollectionParser *)statementParser {
    if (!statementParser) {
        self.statementParser = [PKAlternation alternation];
        statementParser.name = @"statement";
        [statementParser add:self.tokenizerDirectiveParser];
        [statementParser add:self.declParser];
    }
    return statementParser;
}


// tokenizerDirective   = '@'! ~'start' '=' (~';')+ ';'!;
- (PKCollectionParser *)tokenizerDirectiveParser {
    if (!tokenizerDirectiveParser) {
        self.tokenizerDirectiveParser = [PKSequence sequence];
        tokenizerDirectiveParser.name = @"tokenizerDirective";
        
        [tokenizerDirectiveParser add:[[PKSymbol symbolWithString:@"@"] discard]];
        
        PKParser *notStart = [PKNegation negationWithSubparser:[PKLiteral literalWithString:@"start"]];
        [tokenizerDirectiveParser add:notStart];

        [tokenizerDirectiveParser add:[PKSymbol symbolWithString:@"="]];
        
        PKParser *notSemi = [PKNegation negationWithSubparser:[PKSymbol symbolWithString:@";"]];
        PKAlternation *alt = [PKAlternation alternation];
        [alt add:notSemi];
        
        [tokenizerDirectiveParser add:[self oneOrMore:alt]];
        [tokenizerDirectiveParser add:[[PKSymbol symbolWithString:@";"] discard]];
        
        [tokenizerDirectiveParser setAssembler:assembler selector:@selector(parser:didMatchTokenizerDirective:)];
    }
    return tokenizerDirectiveParser;
}


// decl                 = production '=' action? expr ';'!;
- (PKCollectionParser *)declParser {
    if (!declParser) {
        self.declParser = [PKSequence sequence];
        declParser.name = @"decl";
        [declParser add:self.productionParser];
        [declParser add:[PKSymbol symbolWithString:@"="]];
        [declParser add:[self zeroOrOne:self.actionParser]];
        [declParser add:self.exprParser];
        [declParser add:[[PKSymbol symbolWithString:@";"] discard]];
        
        [declParser setAssembler:assembler selector:@selector(parser:didMatchDecl:)];
    }
    return declParser;
}


// productionParser              = varProduction | startProduction;
- (PKCollectionParser *)productionParser {
    if (!productionParser) {
        self.productionParser = [PKAlternation alternation];
        productionParser.name = @"production";
        [productionParser add:self.varProductionParser];
        [productionParser add:self.startProductionParser];
    }
    return productionParser;
}


// startProduction              = '@'! 'start'!;
- (PKCollectionParser *)startProductionParser {
    if (!startProductionParser) {
        self.startProductionParser = [PKSequence sequence];
        startProductionParser.name = @"startProduction";
        [startProductionParser add:[[PKSymbol symbolWithString:@"@"] discard]];
        [startProductionParser add:[[PKLiteral literalWithString:@"start"] discard]];
        [startProductionParser setAssembler:assembler selector:@selector(parser:didMatchStartProduction:)];
    }
    return startProductionParser;
}


// varProduction        = LowercaseWord;
- (PKParser *)varProductionParser {
    if (!varProductionParser) {
        self.varProductionParser = [PKLowercaseWord word];
        varProductionParser.name = @"varProduction";
        [varProductionParser setAssembler:assembler selector:@selector(parser:didMatchVarProduction:)];
    }
    return varProductionParser;
}


// expr        = term orTerm*;
- (PKCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [PKSequence sequence];
        exprParser.name = @"expr";
        [exprParser add:self.termParser];
        [exprParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
    }
    return exprParser;
}


// term                 = semanticPredicate? factor nextFactor*;
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        termParser.name = @"term";
        [termParser add:[self zeroOrOne:self.semanticPredicateParser]];
        [termParser add:self.factorParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
    }
    return termParser;
}


// orTerm               = '|' term;
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        orTermParser.name = @"orTerm";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"|"]]; // preserve as fence
        [tr add:self.termParser];
        
        [orTermParser add:tr];
        [orTermParser setAssembler:assembler selector:@selector(parser:didMatchOrTerm:)];
    }
    return orTermParser;
}


// factor               = (phrase | phraseStar | phrasePlus | phraseQuestion) action?;
- (PKCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [PKSequence sequence];
        factorParser.name = @"factor";

        PKAlternation *alt = [PKAlternation alternation];
        [alt add:self.phraseParser];
        [alt add:self.phraseStarParser];
        [alt add:self.phrasePlusParser];
        [alt add:self.phraseQuestionParser];
        [factorParser add:alt];
        
        [factorParser add:[self zeroOrOne:self.actionParser]];
    }
    return factorParser;
}


// nextFactor           = factor;
- (PKCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [PKSequence sequence];
        nextFactorParser.name = @"nextFactor";
        [nextFactorParser add:self.factorParser];
        //[nextFactorParser setAssembler:assembler selector:@selector(parser:didMatchAnd:)];
}
    return nextFactorParser;
}


// phrase               = primaryExpr predicate*;
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        self.phraseParser = [PKSequence sequence];
        phraseParser.name = @"phrase";
        [phraseParser add:self.primaryExprParser];
        [phraseParser add:[PKRepetition repetitionWithSubparser:self.predicateParser]];
    }
    return phraseParser;
}


// action               = %{'{', '}'};
- (PKParser *)actionParser {
    if (!actionParser) {
        self.actionParser = [PKDelimitedString delimitedStringWithStartMarker:@"{" endMarker:@"}"];
        actionParser.name = @"action";
        [actionParser setAssembler:assembler selector:@selector(parser:didMatchAction:)];
    }
    return actionParser;
}


// semanticPredicate    = %{'{', '}?'};
- (PKParser *)semanticPredicateParser {
    if (!semanticPredicateParser) {
        self.semanticPredicateParser = [PKDelimitedString delimitedStringWithStartMarker:@"{" endMarker:@"}?"];
        semanticPredicateParser.name = @"semanticPredicate";
        [semanticPredicateParser setAssembler:assembler selector:@selector(parser:didMatchSemanticPredicate:)];
    }
    return semanticPredicateParser;
}


// primaryExpr          = negatedPrimaryExpr | barePrimaryExpr;
- (PKCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        primaryExprParser.name = @"primaryExpr";
        [primaryExprParser add:self.negatedPrimaryExprParser];
        [primaryExprParser add:self.barePrimaryExprParser];
    }
    return primaryExprParser;
}


// negatedPrimaryExpr   = '~'! barePrimaryExpr;
- (PKCollectionParser *)negatedPrimaryExprParser {
    if (!negatedPrimaryExprParser) {
        self.negatedPrimaryExprParser = [PKSequence sequence];
        negatedPrimaryExprParser.name = @"negatedPrimaryExpr";
        [negatedPrimaryExprParser add:[[PKLiteral literalWithString:@"~"] discard]];
        [negatedPrimaryExprParser add:self.barePrimaryExprParser];
        [negatedPrimaryExprParser setAssembler:assembler selector:@selector(parser:didMatchNegatedPrimaryExpr:)];
    }
    return negatedPrimaryExprParser;
}


// barePrimaryExpr      = atomicValue | subSeqExpr | subTrackExpr;
// subSeqExpr           = '(' expr ')'!;
// subTrackExpr         = '[' expr ']'!;
- (PKCollectionParser *)barePrimaryExprParser {
    if (!barePrimaryExprParser) {
        self.barePrimaryExprParser = [PKAlternation alternation];
        barePrimaryExprParser.name = @"barePrimaryExpr";
        [barePrimaryExprParser add:self.atomicValueParser];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[PKSymbol symbolWithString:@"("]];
        [s add:self.exprParser];
        [s add:[[PKSymbol symbolWithString:@")"] discard]];
        [s setAssembler:assembler selector:@selector(parser:didMatchSubSeqExpr:)];
        [barePrimaryExprParser add:s];

        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"["]];
        [tr add:self.exprParser];
        [tr add:[[PKSymbol symbolWithString:@"]"] discard]];
        [tr setAssembler:assembler selector:@selector(parser:didMatchSubTrackExpr:)];
        [barePrimaryExprParser add:tr];
    }
    return barePrimaryExprParser;
}


// predicate            = (intersection | difference);
- (PKCollectionParser *)predicateParser {
    if (!predicateParser) {
        self.predicateParser = [PKSequence sequence];
        predicateParser.name = @"predicate";
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:self.intersectionParser];
        [a add:self.differenceParser];
        
        [predicateParser add:a];
    }
    return predicateParser;
}


// intersection         = '&'! primaryExpr;
- (PKCollectionParser *)intersectionParser {
    if (!intersectionParser) {
        self.intersectionParser = [PKTrack track];
        intersectionParser.name = @"intersection";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@"&"] discard]];
        [tr add:self.primaryExprParser];
        
        [intersectionParser add:tr];
        [intersectionParser setAssembler:assembler selector:@selector(parser:didMatchIntersection:)];
    }
    return intersectionParser;
}


// difference            = '-'! primaryExpr;
- (PKCollectionParser *)differenceParser {
    if (!differenceParser) {
        self.differenceParser = [PKTrack track];
        differenceParser.name = @"difference";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@"-"] discard]];
        [tr add:self.primaryExprParser];
        
        [differenceParser add:tr];
        [differenceParser setAssembler:assembler selector:@selector(parser:didMatchDifference:)];
    }
    return differenceParser;
}


// phraseStar           = phrase '*'!;
- (PKCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        phraseStarParser.name = @"phraseStar";
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:[[PKSymbol symbolWithString:@"*"] discard]];
        [phraseStarParser setAssembler:assembler selector:@selector(parser:didMatchPhraseStar:)];
    }
    return phraseStarParser;
}


// phrasePlus           = phrase '+'!;
- (PKCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        phrasePlusParser.name = @"phrasePlus";
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:[[PKSymbol symbolWithString:@"+"] discard]];
        [phrasePlusParser setAssembler:assembler selector:@selector(parser:didMatchPhrasePlus:)];
    }
    return phrasePlusParser;
}


// phraseQuestion       = phrase '?'!;
- (PKCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        phraseQuestionParser.name = @"phraseQuestion";
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:[[PKSymbol symbolWithString:@"?"] discard]];
        [phraseQuestionParser setAssembler:assembler selector:@selector(parser:didMatchPhraseQuestion:)];
    }
    return phraseQuestionParser;
}


// atomicValue          = parser discard?;
- (PKCollectionParser *)atomicValueParser {
    if (!atomicValueParser) {
        self.atomicValueParser = [PKSequence sequence];
        atomicValueParser.name = @"atomicValue";
        [atomicValueParser add:self.parserParser];
        [atomicValueParser add:[self zeroOrOne:self.discardParser]];
    }
    return atomicValueParser;
}


// parser               = pattern | literal | variable | constant | specificConstant | delimitedString;
- (PKCollectionParser *)parserParser {
    if (!parserParser) {
        self.parserParser = [PKAlternation alternation];
        parserParser.name = @"parser";
        [parserParser add:self.patternParser];
        [parserParser add:self.literalParser];
        [parserParser add:self.variableParser];
        [parserParser add:self.constantParser];
        [parserParser add:self.specificConstantParser];
        [parserParser add:self.delimitedStringParser];
    }
    return parserParser;
}


// discard              = '!';
- (PKCollectionParser *)discardParser {
    if (!discardParser) {
        self.discardParser = [PKSequence sequence];
        discardParser.name = @"discard";
        [discardParser add:[[PKSymbol symbolWithString:@"!"] discard]];
        [discardParser setAssembler:assembler selector:@selector(parser:didMatchDiscard:)];
    }
    return discardParser;
}


// pattern              = %{'/', '/'} (Word & /[imxsw]+/)?;
// pattern              = %{'/', '/'};
- (PKCollectionParser *)patternParser {
    if (!patternParser) {
//        self.patternParser = [PKPattern patternWithString:@"/.+?/[imxsw]*"];
//        self.patternParser = [PKPattern patternWithString:@"/[^/]+/[imxsw]*"];
        self.patternParser = [PKAlternation alternation];
        patternParser.name = @"pattern";
        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/"]];
        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/i"]];
//        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/i"]];
//        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/im"]];
//        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/m"]];
//        [patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/mi"]];
        
//        PKParser *opts = [PKPattern patternWithString:@"[imxsw]+" options:PKPatternOptionsNone];
//        PKIntersection *inter = [PKIntersection intersection];
//        [inter add:[PKWord word]];
//        [inter add:opts];
//        [inter setAssembler:assembler selector:@selector(parser:didMatchPatternOptions:)];
//        [patternParser add:[self zeroOrOne:inter]];
        
        [patternParser setAssembler:assembler selector:@selector(parser:didMatchPattern:)];
    }
    return patternParser;
}


// delimitedString      = '%{' QuotedString (',' QuotedString)? '}'!;
- (PKCollectionParser *)delimitedStringParser {
    if (!delimitedStringParser) {
        self.delimitedStringParser = [PKTrack track];
        delimitedStringParser.name = @"delimitedString";
        
        PKSequence *secondArg = [PKSequence sequence];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@","] discard]];
        [tr add:[PKQuotedString quotedString]]; // endMarker
        [secondArg add:tr];
        
        [delimitedStringParser add:[PKSymbol symbolWithString:@"%{"]]; // preserve as fence
        [delimitedStringParser add:[PKQuotedString quotedString]]; // startMarker
        [delimitedStringParser add:[self zeroOrOne:secondArg]];
        [delimitedStringParser add:[[PKSymbol symbolWithString:@"}"] discard]];
        
        [delimitedStringParser setAssembler:assembler selector:@selector(parser:didMatchDelimitedString:)];
    }
    return delimitedStringParser;
}


// literal              = QuotedString;
- (PKParser *)literalParser {
    if (!literalParser) {
        self.literalParser = [PKQuotedString quotedString];
        [literalParser setAssembler:assembler selector:@selector(parser:didMatchLiteral:)];
    }
    return literalParser;
}


// variable             = LowercaseWord;
- (PKParser *)variableParser {
    if (!variableParser) {
        self.variableParser = [PKLowercaseWord word];
        variableParser.name = @"variable";
        [variableParser setAssembler:assembler selector:@selector(parser:didMatchVariable:)];
    }
    return variableParser;
}


// constant             = UppercaseWord;
- (PKParser *)constantParser {
    if (!constantParser) {
        self.constantParser = [PKUppercaseWord word];
        constantParser.name = @"constant";
        [constantParser setAssembler:assembler selector:@selector(parser:didMatchConstant:)];
    }
    return constantParser;
}


// specificConstant      = UppercaseWord '(' QuotedString ')';
- (PKParser *)specificConstantParser {
    if (!specificConstantParser) {
        self.specificConstantParser = [PKSequence sequence];
        specificConstantParser.name = @"specificConstant";
        [specificConstantParser add:[PKUppercaseWord word]];
        [specificConstantParser add:[[PKSymbol symbolWithString:@"("] discard]];
        [specificConstantParser add:[PKQuotedString quotedString]];
        [specificConstantParser add:[[PKSymbol symbolWithString:@")"] discard]];
        [specificConstantParser setAssembler:assembler selector:@selector(parser:didMatchSpecificConstant:)];
    }
    return specificConstantParser;
}

@synthesize parser;
@synthesize statementParser;
@synthesize tokenizerDirectiveParser;
@synthesize declParser;
@synthesize productionParser;
@synthesize varProductionParser;
@synthesize startProductionParser;
@synthesize exprParser;
@synthesize termParser;
@synthesize orTermParser;
@synthesize factorParser;
@synthesize nextFactorParser;
@synthesize phraseParser;
@synthesize actionParser;
@synthesize semanticPredicateParser;
@synthesize phraseStarParser;
@synthesize phrasePlusParser;
@synthesize phraseQuestionParser;
@synthesize primaryExprParser;
@synthesize negatedPrimaryExprParser;
@synthesize barePrimaryExprParser;
@synthesize predicateParser;
@synthesize intersectionParser;
@synthesize differenceParser;
@synthesize atomicValueParser;
@synthesize parserParser;
@synthesize discardParser;
@synthesize patternParser;
@synthesize delimitedStringParser;
@synthesize literalParser;
@synthesize variableParser;
@synthesize constantParser;
@synthesize specificConstantParser;
@end
