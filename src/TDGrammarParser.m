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

#import "TDGrammarParser.h"
#import <ParseKit/ParseKit.h>

@interface NSObject (TDGrammarParserAdditions)
- (void)parser:(PKParser *)p didMatchStatement:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchCallback:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchExpression:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSubExpr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDeclaration:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchAnd:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchIntersection:(PKAssembly *)a;    
- (void)parser:(PKParser *)p didMatchDifference:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPatternOptions:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPattern:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDiscard:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchLiteral:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchVariable:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDelimitedString:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPhraseCardinality:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchCardinality:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNegation:(PKAssembly *)a;
@end

@interface TDGrammarParser ()
- (PKAlternation *)zeroOrOne:(PKParser *)p;
- (PKSequence *)oneOrMore:(PKParser *)p;
@end

@implementation TDGrammarParser

- (id)initWithAssembler:(id)a {
    self = [super init];
    if (self) {
        self.assembler = a;

    }
    return self;
}


- (void)dealloc {
    PKReleaseSubparserTree(self.startParser);

    self.statementParser = nil;
    self.declarationParser = nil;
    self.callbackParser = nil;
    self.selectorParser = nil;
    self.exprParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.phraseStarParser = nil;
    self.phrasePlusParser = nil;
    self.phraseQuestionParser = nil;
    self.phraseCardinalityParser = nil;
    self.cardinalityParser = nil;
    self.primaryExprParser = nil;
    self.negatedPrimaryExprParser = nil;
    self.barePrimaryExprParser = nil;
    self.subExprParser = nil;
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


// @start               = statement*;
// statement            = S* declaration S* '=' expr ';'!;
// callback             = S* '(' S* selector S* ')';
// selector             = Word ':';
// expr                 = S* term orTerm* S*;
// term                 = factor nextFactor*;
// orTerm               = S* '|' S* term;
// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality;
// nextFactor           = S factor;

// phrase               = primaryExpr predicate*;
// phraseStar           = phrase S* '*';
// phrasePlus           = phrase S* '+';
// phraseQuestion       = phrase S* '?';
// phraseCardinality    = phrase S* cardinality;
// cardinality          = '{' S* Number (S* ',' S* Number)? S* '}';

// predicate            = S* (intersection | difference);
// intersection         = '&' S* primaryExpr;
// difference           = '-' S* primaryExpr;

// primaryExpr          = negatedPrimaryExpr | barePrimaryExpr;
// negatedPrimaryExpr   = '~' S* barePrimaryExpr;
// barePrimaryExpr      = atomicValue | subExpr;
// subExpr              = '(' expr ')';
// atomicValue          = parser discard?;
// parser               = pattern | literal | variable | constant | delimitedString;
// discard              = S* '!';
// pattern              = DelimitedString('/', '/') (Word & /[imxsw]+/)?;
// delimitedString      = 'DelimitedString' S* '(' S* QuotedString (S* ',' QuotedString)? S* ')';
// literal              = QuotedString;
// variable             = LowercaseWord;
// constant             = UppercaseWord;


- (PKRepetition *)startParser {
    if (!_startParser) {
        self.startParser = [PKRepetition repetitionWithSubparser:self.statementParser];
    }
    return _startParser;
}


// statement             = S* declaration S* '=' expr;
- (PKCollectionParser *)statementParser {
    if (!_statementParser) {
        self.statementParser = [PKSequence sequence];
        _statementParser.name = @"statement";
        [_statementParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:self.declarationParser];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[PKSymbol symbolWithString:@"="]];
        [tr add:self.exprParser];
        [tr add:[[PKSymbol symbolWithString:@";"] discard]];
        
        [_statementParser add:tr];
        [_statementParser setAssembler:_assembler selector:@selector(parser:didMatchStatement:)];
    }
    return _statementParser;
}


// declaration          = Word callback?;
- (PKCollectionParser *)declarationParser {
    if (!_declarationParser) {
        self.declarationParser = [PKSequence sequence];
        _declarationParser.name = @"declaration";
        [_declarationParser add:[PKWord word]];
        [_declarationParser add:[self zeroOrOne:self.callbackParser]];
        [_declarationParser setAssembler:_assembler selector:@selector(parser:didMatchDeclaration:)];
    }
    return _declarationParser;
}


// callback             = S* '(' S* selector S* ')';
- (PKCollectionParser *)callbackParser {
    if (!_callbackParser) {
        self.callbackParser = [PKSequence sequence];
        _callbackParser.name = @"callback";
        [_callbackParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@"("] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.selectorParser];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [_callbackParser add:tr];
        [_callbackParser setAssembler:_assembler selector:@selector(parser:didMatchCallback:)];
    }
    return _callbackParser;
}


// selector             = LowercaseWord ':' LowercaseWord ':';
- (PKCollectionParser *)selectorParser {
    if (!_selectorParser) {
        self.selectorParser = [PKTrack track];
        _selectorParser.name = @"selector";
        [_selectorParser add:[PKLowercaseWord word]];
        [_selectorParser add:[[PKSymbol symbolWithString:@":"] discard]];
        [_selectorParser add:[PKLowercaseWord word]];
        [_selectorParser add:[[PKSymbol symbolWithString:@":"] discard]];
    }
    return _selectorParser;
}


// expr        = S* term orTerm* S*;
- (PKCollectionParser *)exprParser {
    if (!_exprParser) {
        self.exprParser = [PKSequence sequence];
        _exprParser.name = @"expr";
        [_exprParser add:self.optionalWhitespaceParser];
        [_exprParser add:self.termParser];
        [_exprParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
        [_exprParser add:self.optionalWhitespaceParser];
        [_exprParser setAssembler:_assembler selector:@selector(parser:didMatchExpression:)];
    }
    return _exprParser;
}


// term                = factor nextFactor*;
- (PKCollectionParser *)termParser {
    if (!_termParser) {
        self.termParser = [PKSequence sequence];
        _termParser.name = @"term";
        [_termParser add:self.factorParser];
        [_termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
        [_termParser setAssembler:_assembler selector:@selector(parser:didMatchAnd:)];
    }
    return _termParser;
}


// orTerm               = S* '|' S* term;
- (PKCollectionParser *)orTermParser {
    if (!_orTermParser) {
        self.orTermParser = [PKSequence sequence];
        _orTermParser.name = @"orTerm";
        [_orTermParser add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"|"]]; // preserve as fence
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.termParser];
        
        [_orTermParser add:tr];
        [_orTermParser setAssembler:_assembler selector:@selector(parser:didMatchOr:)];
    }
    return _orTermParser;
}


// factor               = phrase | phraseStar | phrasePlus | phraseQuestion | phraseCardinality;
- (PKCollectionParser *)factorParser {
    if (!_factorParser) {
        self.factorParser = [PKAlternation alternation];
        _factorParser.name = @"factor";
        [_factorParser add:self.phraseParser];
        [_factorParser add:self.phraseStarParser];
        [_factorParser add:self.phrasePlusParser];
        [_factorParser add:self.phraseQuestionParser];
        [_factorParser add:self.phraseCardinalityParser];
    }
    return _factorParser;
}


// nextFactor           = S factor;
- (PKCollectionParser *)nextFactorParser {
    if (!_nextFactorParser) {
        self.nextFactorParser = [PKSequence sequence];
        _nextFactorParser.name = @"nextFactor";
        [_nextFactorParser add:self.whitespaceParser];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:self.phraseParser];
        [a add:self.phraseStarParser];
        [a add:self.phrasePlusParser];
        [a add:self.phraseQuestionParser];
        [a add:self.phraseCardinalityParser];
        
        [_nextFactorParser add:a];
    }
    return _nextFactorParser;
}


// phrase               = primaryExpr predicate*;
- (PKCollectionParser *)phraseParser {
    if (!_phraseParser) {
        self.phraseParser = [PKSequence sequence];
        _phraseParser.name = @"phrase";
        [_phraseParser add:self.primaryExprParser];
        [_phraseParser add:[PKRepetition repetitionWithSubparser:self.predicateParser]];
    }
    return _phraseParser;
}


// primaryExpr          = negatedPrimaryExpr | barePrimaryExpr;
- (PKCollectionParser *)primaryExprParser {
    if (!_primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        _primaryExprParser.name = @"primaryExpr";
        [_primaryExprParser add:self.negatedPrimaryExprParser];
        [_primaryExprParser add:self.barePrimaryExprParser];
    }
    return _primaryExprParser;
}


// negatedPrimaryExpr   = '~' S* barePrimaryExpr;
- (PKCollectionParser *)negatedPrimaryExprParser {
    if (!_negatedPrimaryExprParser) {
        self.negatedPrimaryExprParser = [PKSequence sequence];
        _negatedPrimaryExprParser.name = @"negatedPrimaryExpr";
        [_negatedPrimaryExprParser add:[PKLiteral literalWithString:@"~"]];
        [_negatedPrimaryExprParser add:self.optionalWhitespaceParser];
        [_negatedPrimaryExprParser add:self.barePrimaryExprParser];
        [_negatedPrimaryExprParser setAssembler:_assembler selector:@selector(parser:didMatchNegation:)];
    }
    return _negatedPrimaryExprParser;
}


// barePrimaryExpr          = atomicValue | subExpr;
- (PKCollectionParser *)barePrimaryExprParser {
    if (!_barePrimaryExprParser) {
        self.barePrimaryExprParser = [PKAlternation alternation];
        _barePrimaryExprParser.name = @"barePrimaryExpr";
        [_barePrimaryExprParser add:self.atomicValueParser];
        [_barePrimaryExprParser add:self.subExprParser];
    }
    return _barePrimaryExprParser;
}


// subExpr          = '(' expr ')';
- (PKCollectionParser *)subExprParser {
    if (!_subExprParser) {
        self.subExprParser = [PKSequence sequence];
        _subExprParser.name = @"subExpr";

        [_subExprParser add:[PKSymbol symbolWithString:@"("]];
        [_subExprParser add:self.exprParser];
        [_subExprParser add:[[PKSymbol symbolWithString:@")"] discard]];
        [_subExprParser setAssembler:_assembler selector:@selector(parser:didMatchSubExpr:)];
    }
    return _subExprParser;
}


// predicate            = S* (intersection | difference);
- (PKCollectionParser *)predicateParser {
    if (!_predicateParser) {
        self.predicateParser = [PKSequence sequence];
        _predicateParser.name = @"predicate";
        [_predicateParser add:self.optionalWhitespaceParser];
        
        PKAlternation *a = [PKAlternation alternation];
        [a add:self.intersectionParser];
        [a add:self.differenceParser];
        
        [_predicateParser add:a];
    }
    return _predicateParser;
}


// intersection         = '&' S* primaryExpr;
- (PKCollectionParser *)intersectionParser {
    if (!_intersectionParser) {
        self.intersectionParser = [PKTrack track];
        _intersectionParser.name = @"intersection";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"&"]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.primaryExprParser];
        
        [_intersectionParser add:tr];
        [_intersectionParser setAssembler:_assembler selector:@selector(parser:didMatchIntersection:)];
    }
    return _intersectionParser;
}


// difference            = '-' S* primaryExpr;
- (PKCollectionParser *)differenceParser {
    if (!_differenceParser) {
        self.differenceParser = [PKTrack track];
        _differenceParser.name = @"difference";
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"-"]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:self.primaryExprParser];
        
        [_differenceParser add:tr];
        [_differenceParser setAssembler:_assembler selector:@selector(parser:didMatchDifference:)];
    }
    return _differenceParser;
}


// phraseStar           = phrase S* '*';
- (PKCollectionParser *)phraseStarParser {
    if (!_phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        _phraseStarParser.name = @"phraseStar";
        [_phraseStarParser add:self.phraseParser];
        [_phraseStarParser add:self.optionalWhitespaceParser];
        [_phraseStarParser add:[PKSymbol symbolWithString:@"*"]];
        [_phraseStarParser setAssembler:_assembler selector:@selector(parser:didMatchStar:)];
    }
    return _phraseStarParser;
}


// phrasePlus           = phrase S* '+';
- (PKCollectionParser *)phrasePlusParser {
    if (!_phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        _phrasePlusParser.name = @"phrasePlus";
        [_phrasePlusParser add:self.phraseParser];
        [_phrasePlusParser add:self.optionalWhitespaceParser];
        [_phrasePlusParser add:[PKSymbol symbolWithString:@"+"]];
        [_phrasePlusParser setAssembler:_assembler selector:@selector(parser:didMatchPlus:)];
    }
    return _phrasePlusParser;
}


// phraseQuestion       = phrase S* '?';
- (PKCollectionParser *)phraseQuestionParser {
    if (!_phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        _phraseQuestionParser.name = @"phraseQuestion";
        [_phraseQuestionParser add:self.phraseParser];
        [_phraseQuestionParser add:self.optionalWhitespaceParser];
        [_phraseQuestionParser add:[PKSymbol symbolWithString:@"?"]];
        [_phraseQuestionParser setAssembler:_assembler selector:@selector(parser:didMatchQuestion:)];
    }
    return _phraseQuestionParser;
}


// phraseCardinality    = phrase S* cardinality;
- (PKCollectionParser *)phraseCardinalityParser {
    if (!_phraseCardinalityParser) {
        self.phraseCardinalityParser = [PKSequence sequence];
        _phraseCardinalityParser.name = @"phraseCardinality";
        [_phraseCardinalityParser add:self.phraseParser];
        [_phraseCardinalityParser add:self.optionalWhitespaceParser];
        [_phraseCardinalityParser add:self.cardinalityParser];
        [_phraseCardinalityParser setAssembler:_assembler selector:@selector(parser:didMatchPhraseCardinality:)];
    }
    return _phraseCardinalityParser;
}


// cardinality          = '{' S* Number (S* ',' S* Number)? S* '}';
- (PKCollectionParser *)cardinalityParser {
    if (!_cardinalityParser) {
        self.cardinalityParser = [PKSequence sequence];
        _cardinalityParser.name = @"cardinality";
        
        PKSequence *commaNum = [PKSequence sequence];
        [commaNum add:self.optionalWhitespaceParser];
        [commaNum add:[[PKSymbol symbolWithString:@","] discard]];
        [commaNum add:self.optionalWhitespaceParser];
        [commaNum add:[PKNumber number]];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[PKSymbol symbolWithString:@"{"]]; // serves as fence. dont discard
        [tr add:self.optionalWhitespaceParser];
        [tr add:[PKNumber number]];
        [tr add:[self zeroOrOne:commaNum]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[[PKSymbol symbolWithString:@"}"] discard]];
        
        [_cardinalityParser add:tr];
        [_cardinalityParser setAssembler:_assembler selector:@selector(parser:didMatchCardinality:)];
    }
    return _cardinalityParser;
}


// atomicValue          = parser discard?;
- (PKCollectionParser *)atomicValueParser {
    if (!_atomicValueParser) {
        self.atomicValueParser = [PKSequence sequence];
        _atomicValueParser.name = @"atomicValue";
        [_atomicValueParser add:self.parserParser];
        [_atomicValueParser add:[self zeroOrOne:self.discardParser]];
    }
    return _atomicValueParser;
}


// parser              = pattern | literal | variable | constant | delimitedString;
- (PKCollectionParser *)parserParser {
    if (!_parserParser) {
        self.parserParser = [PKAlternation alternation];
        _parserParser.name = @"parser";
        [_parserParser add:self.patternParser];
        [_parserParser add:self.literalParser];
        [_parserParser add:self.variableParser];
        [_parserParser add:self.constantParser];
        [_parserParser add:self.delimitedStringParser];
    }
    return _parserParser;
}


// discard              = S* '!';
- (PKCollectionParser *)discardParser {
    if (!_discardParser) {
        self.discardParser = [PKSequence sequence];
        _discardParser.name = @"discard";
        [_discardParser add:self.optionalWhitespaceParser];
        [_discardParser add:[[PKSymbol symbolWithString:@"!"] discard]];
        [_discardParser setAssembler:_assembler selector:@selector(parser:didMatchDiscard:)];
    }
    return _discardParser;
}


// pattern              = DelimitedString('/', '/') (Word & /[imxsw]+/)?;
- (PKCollectionParser *)patternParser {
    if (!_patternParser) {
        _patternParser.name = @"pattern";
        self.patternParser = [PKSequence sequence];
        [_patternParser add:[PKDelimitedString delimitedStringWithStartMarker:@"/" endMarker:@"/"]];
        
        PKParser *opts = [PKPattern patternWithString:@"[imxsw]+" options:PKPatternOptionsNone];
        PKIntersection *inter = [PKIntersection intersection];
        [inter add:[PKWord word]];
        [inter add:opts];
        [inter setAssembler:_assembler selector:@selector(parser:didMatchPatternOptions:)];
        
        [_patternParser add:[self zeroOrOne:inter]];
        [_patternParser setAssembler:_assembler selector:@selector(parser:didMatchPattern:)];
    }
    return _patternParser;
}


// delimitedString      = 'DelimitedString' S* '(' S* QuotedString (S* ',' QuotedString)? S* ')';
- (PKCollectionParser *)delimitedStringParser {
    if (!_delimitedStringParser) {
        self.delimitedStringParser = [PKTrack track];
        _delimitedStringParser.name = @"delimitedString";
        
        PKSequence *secondArg = [PKSequence sequence];
        [secondArg add:self.optionalWhitespaceParser];
        
        PKTrack *tr = [PKTrack track];
        [tr add:[[PKSymbol symbolWithString:@","] discard]];
        [tr add:self.optionalWhitespaceParser];
        [tr add:[PKQuotedString quotedString]]; // endMarker
        [secondArg add:tr];
        
        [_delimitedStringParser add:[[PKLiteral literalWithString:@"DelimitedString"] discard]];
        [_delimitedStringParser add:self.optionalWhitespaceParser];
        [_delimitedStringParser add:[PKSymbol symbolWithString:@"("]]; // preserve as fence
        [_delimitedStringParser add:self.optionalWhitespaceParser];
        [_delimitedStringParser add:[PKQuotedString quotedString]]; // startMarker
        [_delimitedStringParser add:[self zeroOrOne:secondArg]];
        [_delimitedStringParser add:self.optionalWhitespaceParser];
        [_delimitedStringParser add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [_delimitedStringParser setAssembler:_assembler selector:@selector(parser:didMatchDelimitedString:)];
    }
    return _delimitedStringParser;
}


// literal              = QuotedString;
- (PKParser *)literalParser {
    if (!_literalParser) {
        self.literalParser = [PKQuotedString quotedString];
        [_literalParser setAssembler:_assembler selector:@selector(parser:didMatchLiteral:)];
    }
    return _literalParser;
}


// variable             = LowercaseWord;
- (PKParser *)variableParser {
    if (!_variableParser) {
        self.variableParser = [PKLowercaseWord word];
        _variableParser.name = @"variable";
        [_variableParser setAssembler:_assembler selector:@selector(parser:didMatchVariable:)];
    }
    return _variableParser;
}


// constant             = UppercaseWord;
- (PKParser *)constantParser {
    if (!_constantParser) {
        self.constantParser = [PKUppercaseWord word];
        _constantParser.name = @"constant";
        [_constantParser setAssembler:_assembler selector:@selector(parser:didMatchConstant:)];
    }
    return _constantParser;
}


- (PKParser *)whitespaceParser {
    return [[PKWhitespace whitespace] discard];
}


- (PKParser *)optionalWhitespaceParser {
    return [PKRepetition repetitionWithSubparser:self.whitespaceParser];
}

@end
