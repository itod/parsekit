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

#import "TDRegularParser.h"

@interface TDRegularParser ()
- (void)parser:(PKParser *)p didMatchChar:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a;
//- (void)parser:(PKParser *)p didMatchAnd:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchExpression:(PKAssembly *)a;

@property (nonatomic, retain) NSNumber *curly;
@end

@implementation TDRegularParser

- (id)init {
    self = [super init];
    if (self) {
        self.curly = [NSNumber numberWithInt:(int)'{'];

        [self add:self.expressionParser];
    }
    return self;
}


- (void)dealloc {
    self.expressionParser = nil;
    self.termParser = nil;
    self.orTermParser = nil;
    self.factorParser = nil;
    self.nextFactorParser = nil;
    self.phraseParser = nil;
    self.phraseStarParser = nil;
    self.phrasePlusParser = nil;
    self.phraseQuestionParser = nil;
    self.phraseIntervalParser = nil;
    self.charParser = nil;
    self.metaCharParser = nil;
    
    self.curly = nil;
    [super dealloc];
}


+ (id)parserFromGrammar:(NSString *)s {
    TDRegularParser *p = (TDRegularParser *)[TDRegularParser parser];
    PKAssembly *a = [PKCharacterAssembly assemblyWithString:s];
    a = [p completeMatchFor:a];
    return [a pop];
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


// expression        = term orTerm*;
// term              = factor nextFactor*;
// orTerm            = '|' term;
// factor            = phrase | phraseStar | phrasePlus | phraseQuestion | phraseInterval;
// nextFactor        = factor;
// phrase            = char | '(' expression ')';
// phraseStar        = phrase '*';
// phrasePlus        = phrase '+';
// phraseQuestion    = phrase '?';
// phraseInterval    = phrase '{' Digit (',' Digit)? '}';
// char              = metaChar | Letter | Digit;
// metaChar          = '.';


// expression        = term orTerm*
- (PKCollectionParser *)expressionParser {
    if (!expressionParser) {
        self.expressionParser = [PKSequence sequence];
        expressionParser.name = @"expression";
        [expressionParser add:self.termParser];
        [expressionParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
        [expressionParser setAssembler:self selector:@selector(parser:didMatchExpression:)];
    }
    return expressionParser;
}


// term                = factor nextFactor*
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        termParser.name = @"term";
        [termParser add:self.factorParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.nextFactorParser]];
    }
    return termParser;
}


// orTerm            = '|' term
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        orTermParser.name = @"orTerm";
        [orTermParser add:[[PKSpecificChar specificCharWithChar:'|'] discard]];
        [orTermParser add:self.termParser];
        [orTermParser setAssembler:self selector:@selector(parser:didMatchOr:)];
    }
    return orTermParser;
}


// factor            = phrase | phraseStar | phrasePlus | phraseQuestion | phraseInterval
- (PKCollectionParser *)factorParser {
    if (!factorParser) {
        self.factorParser = [PKAlternation alternation];
        factorParser.name = @"factor";
        [factorParser add:self.phraseParser];
        [factorParser add:self.phraseStarParser];
        [factorParser add:self.phrasePlusParser];
        [factorParser add:self.phraseQuestionParser];
        [factorParser add:self.phraseIntervalParser];
    }
    return factorParser;
}


// nextFactor        = factor
- (PKCollectionParser *)nextFactorParser {
    if (!nextFactorParser) {
        self.nextFactorParser = [PKAlternation alternation];
        nextFactorParser.name = @"nextFactor";
        [nextFactorParser add:self.phraseParser];
        [nextFactorParser add:self.phraseStarParser];
        [nextFactorParser add:self.phrasePlusParser];
        [nextFactorParser add:self.phraseQuestionParser];
        [nextFactorParser add:self.phraseIntervalParser];
//        [nextFactorParser setAssembler:self selector:@selector(parser:didMatchAnd:)];
    }
    return nextFactorParser;
}


// phrase            = char | '(' expression ')'
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        PKSequence *s = [PKSequence sequence];
        [s add:[[PKSpecificChar specificCharWithChar:'('] discard]];
        [s add:self.expressionParser];
        [s add:[[PKSpecificChar specificCharWithChar:')'] discard]];

        self.phraseParser = [PKAlternation alternation];
        phraseParser.name = @"phrase";
        [phraseParser add:self.charParser];
        [phraseParser add:s];
    }
    return phraseParser;
}


// phraseStar        = phrase '*'
- (PKCollectionParser *)phraseStarParser {
    if (!phraseStarParser) {
        self.phraseStarParser = [PKSequence sequence];
        phraseStarParser.name = @"phraseStar";
        [phraseStarParser add:self.phraseParser];
        [phraseStarParser add:[[PKSpecificChar specificCharWithChar:'*'] discard]];
        [phraseStarParser setAssembler:self selector:@selector(parser:didMatchStar:)];
    }
    return phraseStarParser;
}


// phrasePlus        = phrase '+'
- (PKCollectionParser *)phrasePlusParser {
    if (!phrasePlusParser) {
        self.phrasePlusParser = [PKSequence sequence];
        phrasePlusParser.name = @"phrasePlus";
        [phrasePlusParser add:self.phraseParser];
        [phrasePlusParser add:[[PKSpecificChar specificCharWithChar:'+'] discard]];
        [phrasePlusParser setAssembler:self selector:@selector(parser:didMatchPlus:)];
    }
    return phrasePlusParser;
}


// phrasePlus        = phrase '?'
- (PKCollectionParser *)phraseQuestionParser {
    if (!phraseQuestionParser) {
        self.phraseQuestionParser = [PKSequence sequence];
        phraseQuestionParser.name = @"phraseQuestion";
        [phraseQuestionParser add:self.phraseParser];
        [phraseQuestionParser add:[[PKSpecificChar specificCharWithChar:'?'] discard]];
        [phraseQuestionParser setAssembler:self selector:@selector(parser:didMatchQuestion:)];
    }
    return phraseQuestionParser;
}


// phraseInterval        = phrase '{' Digit (',' Digit)? '}'
- (PKCollectionParser *)phraseIntervalParser {
    if (!phraseIntervalParser) {
        self.phraseIntervalParser = [PKSequence sequence];
        phraseIntervalParser.name = @"phraseInterval";
        [phraseIntervalParser add:self.phraseParser];
        [phraseIntervalParser add:[PKSpecificChar specificCharWithChar:'{']];
        [phraseIntervalParser add:[PKDigit digit]];

        PKSequence *seq = [PKSequence sequence];
        [seq add:[[PKSpecificChar specificCharWithChar:','] discard]];
        [seq add:[PKDigit digit]];
        [phraseIntervalParser add:[self zeroOrOne:seq]];
        
        [phraseIntervalParser add:[[PKSpecificChar specificCharWithChar:'}'] discard]];
        [phraseIntervalParser setAssembler:self selector:@selector(parser:didMatchInterval:)];
    }
    return phraseIntervalParser;
}


// char    = metaChar | Letter | Digit;
- (PKCollectionParser *)charParser {
    if (!charParser) {
        self.charParser = [PKAlternation alternation];
        charParser.name = @"char";
        [charParser add:self.metaCharParser];
        [charParser add:[PKLetter letter]];
        [charParser add:[PKDigit digit]];
        [charParser setAssembler:self selector:@selector(parser:didMatchChar:)];
    }
    return charParser;
}


- (PKCollectionParser *)metaCharParser {
    if (!metaCharParser) {
        self.metaCharParser = [PKAlternation alternation];
        metaCharParser.name = @"metaChar";
        [metaCharParser add:[PKSpecificChar specificCharWithChar:'.']];
        [metaCharParser setAssembler:self selector:@selector(parser:didMatchMetaChar:)];
    }
    return metaCharParser;
}


- (void)parser:(PKParser *)p didMatchChar:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id obj = [a pop];
    NSAssert([obj isKindOfClass:[NSNumber class]], @"");
    PKUniChar c = (PKUniChar)[obj integerValue];
    [a push:[PKSpecificChar specificCharWithChar:c]];
}


- (void)parser:(PKParser *)p didMatchMetaChar:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    id obj = [a pop];
    NSAssert([obj isKindOfClass:[NSString class]], @"");
    
    PKNegation *neg = [PKNegation negationWithSubparser:[PKSpecificChar specificCharWithChar:'\n']];
    [a push:neg];
}


- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKRepetition *rep = [PKRepetition repetitionWithSubparser:top];
    [a push:rep];
}


- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKSequence *seq = [PKSequence sequence];
    [seq add:top];
    [seq add:[PKRepetition repetitionWithSubparser:top]];
    [a push:seq];
}


- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKAlternation *alt = [PKAlternation alternation];
    [alt add:[PKEmpty empty]];
    [alt add:top];
    [a push:alt];
}


- (void)parser:(PKParser *)p didMatchInterval:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    NSArray *digits = [a objectsAbove:curly];
    [a pop]; // discard '{'

    NSInteger start = -1;
    NSInteger end = -1;
    
    for (NSNumber *n in [digits reverseObjectEnumerator]) {
        if (-1 == start) {
            start = [n integerValue] - '0';
            end = start;
        } else {
            end = [n integerValue] - '0';
        }
    }

    PKParser *rep = [a pop];
    PKSequence *seq = [PKSequence sequence];

    for (NSInteger i = 0; i < start; i++) {
        [seq add:rep];
    }
    
    for (NSInteger i = start; i < end; i++) {
        [seq add:[self zeroOrOne:rep]];
    }
    
    [a push:seq];
}


//- (void)parser:(PKParser *)p didMatchAnd:(PKAssembly *)a {
////    NSLog(@"%s", _cmd);
////    NSLog(@"a: %@", a);
//    id second = [a pop];
//    id first = [a pop];
//    NSAssert([first isKindOfClass:[PKParser class]], @"");
//    NSAssert([second isKindOfClass:[PKParser class]], @"");
//    PKSequence *p = [PKSequence sequence];
//    [p add:first];
//    [p add:second];
//    [a push:p];
//}


- (void)parser:(PKParser *)p didMatchExpression:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    NSAssert(![a isStackEmpty], @"");
    
    id obj = nil;
    NSMutableArray *objs = [NSMutableArray array];
    while (![a isStackEmpty]) {
        obj = [a pop];
        [objs addObject:obj];
        NSAssert([obj isKindOfClass:[PKParser class]], @"");
    }
    
    if ([objs count] > 1) {
        PKSequence *seq = [PKSequence sequence];
        for (id obj in [objs reverseObjectEnumerator]) {
            [seq add:obj];
        }
        [a push:seq];
    } else {
        NSAssert((NSUInteger)1 == [objs count], @"");
        PKParser *p = [objs objectAtIndex:0];
        [a push:p];
    }
}


- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a {
//    NSLog(@"%s", _cmd);
//    NSLog(@"a: %@", a);
    id second = [a pop];
    id first = [a pop];
//    NSLog(@"first: %@", first);
//    NSLog(@"second: %@", second);
    NSAssert(first, @"");
    NSAssert(second, @"");
    NSAssert([first isKindOfClass:[PKParser class]], @"");
    NSAssert([second isKindOfClass:[PKParser class]], @"");
    PKAlternation *alt = [PKAlternation alternation];
    [alt add:first];
    [alt add:second];
    [a push:alt];
}

@synthesize expressionParser;
@synthesize termParser;
@synthesize orTermParser;
@synthesize factorParser;
@synthesize nextFactorParser;
@synthesize phraseParser;
@synthesize phraseStarParser;
@synthesize phrasePlusParser;
@synthesize phraseQuestionParser;
@synthesize phraseIntervalParser;
@synthesize charParser;
@synthesize metaCharParser;
@synthesize curly;
@end
