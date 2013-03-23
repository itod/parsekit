//
//  TDRegexAssembler.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/1/12.
//
//

#import "TDRegexAssembler.h"
#import <ParseKit/ParseKit.h>

@implementation TDRegexAssembler

- (id)init {
    self = [super init];
    if (self) {
        self.curly = [NSNumber numberWithInt:'{'];
        self.paren = [NSNumber numberWithInt:'('];
        self.square = [NSNumber numberWithInt:'['];
    }
    return self;
}


- (void)dealloc {
    self.curly = nil;
    self.paren = nil;
    self.square = nil;
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


#pragma mark -
#pragma mark Assembler methods

//- (void)parser:(PKParser *)p didMatchChar:(PKAssembly *)a {
//    //    NSLog(@"%s", _cmd);
//    //    NSLog(@"a: %@", a);
//    id obj = [a pop];
//    NSAssert([obj isKindOfClass:[NSNumber class]], @"");
//    PKUniChar c = (PKUniChar)[obj integerValue];
//    [a push:[PKSpecificChar specificCharWithChar:c]];
//}


- (void)parser:(PKParser *)p didMatchLiteralChar:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);

    NSNumber *n = [a pop];
    PKUniChar c = [n intValue];
    
    PKParser *top = [PKSpecificChar specificCharWithChar:c];
    [a push:top];
}


- (void)parser:(PKParser *)p didMatchDot:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);

    //PKParser *top = [PKNegation negationWithSubparser:[PKSpecificChar specificCharWithChar:'\n']];
    
    PKParser *newline = [PKSpecificChar specificCharWithChar:'\n'];
    PKDifference *top = [PKDifference differenceWithSubparser:[PKChar char] minus:newline];
    [a push:top];
}


- (void)parser:(PKParser *)p didMatchWordCharClass:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    PKAlternation *alt = [PKAlternation alternationWithSubparsers:[PKLetter letter], [PKDigit digit], nil];
    [a push:alt];
}


- (void)parser:(PKParser *)p didMatchNotWordCharClass:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    PKAlternation *alt = [PKAlternation alternationWithSubparsers:[PKLetter letter], [PKDigit digit], nil];
    PKDifference *dif = [PKDifference differenceWithSubparser:[PKChar char] minus:alt];
    [a push:dif];
}


- (void)parser:(PKParser *)p didMatchDigitCharClass:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    
    [a push:[PKDigit digit]];
}


- (void)parser:(PKParser *)p didMatchNotDigitCharClass:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    PKDifference *dif = [PKDifference differenceWithSubparser:[PKChar char] minus:[PKDigit digit]];
    [a push:dif];
}


- (void)parser:(PKParser *)p didMatchCustomCharClass:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    NSArray *nums = [a objectsAbove:square];
    [a pop]; // discard '['
    
    PKAlternation *alt = [PKAlternation alternation];
    for (NSNumber *n in nums) {
        PKUniChar c = [n intValue];
        [alt add:[PKSpecificChar specificCharWithChar:c]];
    }
    
    [a push:alt];
}


- (void)parser:(PKParser *)p didMatchPhraseStar:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKRepetition *rep = [PKRepetition repetitionWithSubparser:top];
    [a push:rep];
}


- (void)parser:(PKParser *)p didMatchPhrasePlus:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKSequence *seq = [PKSequence sequence];
    [seq add:top];
    [seq add:[PKRepetition repetitionWithSubparser:top]];
    [a push:seq];
}


- (void)parser:(PKParser *)p didMatchPhraseQuestion:(PKAssembly *)a {
    //    NSLog(@"%s", _cmd);
    //    NSLog(@"a: %@", a);
    id top = [a pop];
    NSAssert([top isKindOfClass:[PKParser class]], @"");
    PKAlternation *alt = [PKAlternation alternation];
    [alt add:[PKEmpty empty]];
    [alt add:top];
    [a push:alt];
}


- (void)parser:(PKParser *)p didMatchPhraseInterval:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//    NSLog(@"a: %@", a);
    
    NSArray *digits = [a objectsAbove:curly];
    [a pop]; // discard '{'
//    NSLog(@"digits: %@", digits);
    
    NSInteger start = -1;
    NSInteger end = -1;
    
    for (NSNumber *n in [digits reverseObjectEnumerator]) {
        if (-1 == start) {
            start = [n intValue] - '0';
            end = start;
        } else {
            end = [n intValue] - '0';
        }
    }
    
    PKParser *top = [a pop];
    PKSequence *seq = [PKSequence sequence];
    
    for (NSInteger i = 0; i < start; i++) {
        [seq add:top];
    }
    
    for (NSInteger i = start; i < end; i++) {
        [seq add:[self zeroOrOne:top]];
    }
    
    [a push:seq];
}


- (void)parser:(PKParser *)p didMatchExpression:(PKAssembly *)a {
    //    NSLog(@"%s", __PRETTY_FUNCTION__);
    //    NSLog(@"a: %@", a);
    
    NSAssert(![a isStackEmpty], @"");
    
    NSArray *objs = [a objectsAbove:paren];
    [a pop]; // discard '('
    
    if ([objs count] > 1) {
        PKSequence *seq = [PKSequence sequence];
        for (id obj in [objs reverseObjectEnumerator]) {
            NSAssert([obj isKindOfClass:[PKParser class]], @"");
            [seq add:obj];
        }
        [a push:seq];
    } else {
        NSAssert((NSUInteger)1 == [objs count], @"");
        PKParser *p = [objs objectAtIndex:0];
        [a push:p];
    }
}


- (void)parser:(PKParser *)p didMatchOrTerm:(PKAssembly *)a {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
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

@synthesize curly;
@synthesize paren;
@synthesize square;
@end
