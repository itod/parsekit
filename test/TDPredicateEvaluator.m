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

#import "TDPredicateEvaluator.h"
#import "NSString+ParseKitAdditions.h"

// expr                 = term orTerm*
// orTerm               = 'or' term
// term                 = primaryExpr andPrimaryExpr*
// andPrimaryExpr       = 'and' primaryExpr
// primaryExpr          = phrase | '(' expression ')'
// phrase               = predicate | negatedPredicate
// negatedPredicate     = 'not' predicate
// predicate            = bool | eqPredicate | nePredicate | gtPredicate | gteqPredicate | ltPredicate | lteqPredicate | beginswithPredicate | containsPredicate | endswithPredicate | matchesPredicate
// eqPredicate          = attr '=' value
// nePredicate          = attr '!=' value
// gtPredicate          = attr '>' value
// gteqPredicate        = attr '>=' value
// ltPredicate          = attr '<' value
// lteqPredicate        = attr '<=' value
// beginswithPredicate  = attr 'beginswith' value
// containsPredicate    = attr 'contains' value
// endswithPredicate    = attr 'endswith' value
// matchesPredicate     = attr 'matches' value

// attr                 = tag | Word
// tag                  = '@' Word
// value                = QuotedString | Number | bool
// bool                 = 'true' | 'false'

@implementation TDPredicateEvaluator

- (id)initWithDelegate:(id <TDPredicateEvaluatorDelegate>)d {
    if (self = [super init]) {
        delegate = d;
    }
    return self;
}


- (void)dealloc {
    delegate = nil;
    self.exprParser = nil;
    self.orTermParser = nil;
    self.termParser = nil;
    self.andPrimaryExprParser = nil;
    self.primaryExprParser = nil;
    self.negatedPredicateParser = nil;
    self.predicateParser = nil;
    self.phraseParser = nil;
    self.attrParser = nil;
    self.tagParser = nil;
    self.eqStringPredicateParser = nil;
    self.eqNumberPredicateParser = nil;
    self.eqBoolPredicateParser = nil;
    self.neStringPredicateParser = nil;
    self.neNumberPredicateParser = nil;
    self.neBoolPredicateParser = nil;
    self.gtPredicateParser = nil;
    self.gteqPredicateParser = nil;
    self.ltPredicateParser = nil;
    self.lteqPredicateParser = nil;
    self.beginswithPredicateParser = nil;
    self.containsPredicateParser = nil;
    self.endswithPredicateParser = nil;
    self.matchesPredicateParser = nil;
    self.valueParser = nil;
    self.boolParser = nil;
    self.trueParser = nil;
    self.falseParser = nil;
    self.stringParser = nil;
    self.numberParser = nil;
    [super dealloc];
}


- (BOOL)evaluate:(NSString *)s {
    PKAssembly *a = [PKTokenAssembly assemblyWithString:s];
    return [[[self.exprParser completeMatchFor:a] pop] boolValue];
}


// expression       = term orTerm*
- (PKCollectionParser *)exprParser {
    if (!exprParser) {
        self.exprParser = [PKSequence sequence];
        [exprParser add:self.termParser];
        [exprParser add:[PKRepetition repetitionWithSubparser:self.orTermParser]];
    }
    return exprParser;
}


// orTerm           = 'or' term
- (PKCollectionParser *)orTermParser {
    if (!orTermParser) {
        self.orTermParser = [PKSequence sequence];
        [orTermParser add:[[PKCaseInsensitiveLiteral literalWithString:@"or"] discard]];
        [orTermParser add:self.termParser];
        [orTermParser setAssembler:self selector:@selector(parser:didMatchOr:)];
    }
    return orTermParser;
}


// term             = primaryExpr andPrimaryExpr*
- (PKCollectionParser *)termParser {
    if (!termParser) {
        self.termParser = [PKSequence sequence];
        [termParser add:self.primaryExprParser];
        [termParser add:[PKRepetition repetitionWithSubparser:self.andPrimaryExprParser]];
    }
    return termParser;
}


// andPrimaryExpr        = 'and' primaryExpr
- (PKCollectionParser *)andPrimaryExprParser {
    if (!andPrimaryExprParser) {
        self.andPrimaryExprParser = [PKSequence sequence];
        [andPrimaryExprParser add:[[PKCaseInsensitiveLiteral literalWithString:@"and"] discard]];
        [andPrimaryExprParser add:self.primaryExprParser];
        [andPrimaryExprParser setAssembler:self selector:@selector(parser:didMatchAnd:)];
    }
    return andPrimaryExprParser;
}


// primaryExpr           = phrase | '(' expression ')'
- (PKCollectionParser *)primaryExprParser {
    if (!primaryExprParser) {
        self.primaryExprParser = [PKAlternation alternation];
        [primaryExprParser add:self.phraseParser];
        
        PKSequence *s = [PKSequence sequence];
        [s add:[[PKSymbol symbolWithString:@"("] discard]];
        [s add:self.exprParser];
        [s add:[[PKSymbol symbolWithString:@")"] discard]];
        
        [primaryExprParser add:s];
    }
    return primaryExprParser;
}


// phrase      = predicate | negatedPredicate
- (PKCollectionParser *)phraseParser {
    if (!phraseParser) {
        self.phraseParser = [PKAlternation alternation];
        [phraseParser add:self.predicateParser];
        [phraseParser add:self.negatedPredicateParser];
    }
    return phraseParser;
}


// negatedPredicate      = 'not' predicate
- (PKCollectionParser *)negatedPredicateParser {
    if (!negatedPredicateParser) {
        self.negatedPredicateParser = [PKSequence sequence];
        [negatedPredicateParser add:[[PKCaseInsensitiveLiteral literalWithString:@"not"] discard]];
        [negatedPredicateParser add:self.predicateParser];
        [negatedPredicateParser setAssembler:self selector:@selector(parser:didMatchNegatedValue:)];
    }
    return negatedPredicateParser;
}


// predicate         = bool | eqPredicate | nePredicate | gtPredicate | gteqPredicate | ltPredicate | lteqPredicate | beginswithPredicate | containsPredicate | endswithPredicate | matchesPredicate
- (PKCollectionParser *)predicateParser {
    if (!predicateParser) {
        self.predicateParser = [PKAlternation alternation];
        [predicateParser add:self.boolParser];
        [predicateParser add:self.eqStringPredicateParser];
        [predicateParser add:self.eqNumberPredicateParser];
        [predicateParser add:self.eqBoolPredicateParser];
        [predicateParser add:self.neStringPredicateParser];
        [predicateParser add:self.neNumberPredicateParser];
        [predicateParser add:self.neBoolPredicateParser];
        [predicateParser add:self.gtPredicateParser];
        [predicateParser add:self.gteqPredicateParser];
        [predicateParser add:self.ltPredicateParser];
        [predicateParser add:self.lteqPredicateParser];
        [predicateParser add:self.beginswithPredicateParser];
        [predicateParser add:self.containsPredicateParser];
        [predicateParser add:self.endswithPredicateParser];
        [predicateParser add:self.matchesPredicateParser];
    }
    return predicateParser;
}


// attr                 = tag | Word
- (PKCollectionParser *)attrParser {
    if (!attrParser) {
        self.attrParser = [PKAlternation alternation];
        [attrParser add:self.tagParser];
        [attrParser add:[PKWord word]];
        [attrParser setAssembler:self selector:@selector(parser:didMatchAttr:)];
    }
    return attrParser;
}


// tag                  = '@' Word
- (PKCollectionParser *)tagParser {
    if (!tagParser) {
        self.tagParser = [PKSequence sequence];
        [tagParser add:[[PKSymbol symbolWithString:@"@"] discard]];
        [tagParser add:[PKWord word]];
    }
    return tagParser;
}


// eqPredicate          = attr '=' value
- (PKCollectionParser *)eqStringPredicateParser {
    if (!eqStringPredicateParser) {
        self.eqStringPredicateParser = [PKSequence sequence];
        [eqStringPredicateParser add:self.attrParser];
        [eqStringPredicateParser add:[[PKSymbol symbolWithString:@"="] discard]];
        [eqStringPredicateParser add:self.stringParser];
        [eqStringPredicateParser setAssembler:self selector:@selector(parser:didMatchEqStringPredicate:)];
    }
    return eqStringPredicateParser;
}


- (PKCollectionParser *)eqNumberPredicateParser {
    if (!eqNumberPredicateParser) {
        self.eqNumberPredicateParser = [PKSequence sequence];
        [eqNumberPredicateParser add:self.attrParser];
        [eqNumberPredicateParser add:[[PKSymbol symbolWithString:@"="] discard]];
        [eqNumberPredicateParser add:self.numberParser];
        [eqNumberPredicateParser setAssembler:self selector:@selector(parser:didMatchEqNumberPredicate:)];
    }
    return eqNumberPredicateParser;
}


- (PKCollectionParser *)eqBoolPredicateParser {
    if (!eqBoolPredicateParser) {
        self.eqBoolPredicateParser = [PKSequence sequence];
        [eqBoolPredicateParser add:self.attrParser];
        [eqBoolPredicateParser add:[[PKSymbol symbolWithString:@"="] discard]];
        [eqBoolPredicateParser add:self.boolParser];
        [eqBoolPredicateParser setAssembler:self selector:@selector(parser:didMatchEqBoolPredicate:)];
    }
    return eqBoolPredicateParser;
}


// nePredicate          = attr '!=' value
- (PKCollectionParser *)neStringPredicateParser {
    if (!neStringPredicateParser) {
        self.neStringPredicateParser = [PKSequence sequence];
        [neStringPredicateParser add:self.attrParser];
        [neStringPredicateParser add:[[PKSymbol symbolWithString:@"!="] discard]];
        [neStringPredicateParser add:self.stringParser];
        [neStringPredicateParser setAssembler:self selector:@selector(parser:didMatchNeStringPredicate:)];
    }
    return neStringPredicateParser;
}


- (PKCollectionParser *)neNumberPredicateParser {
    if (!neNumberPredicateParser) {
        self.neNumberPredicateParser = [PKSequence sequence];
        [neNumberPredicateParser add:self.attrParser];
        [neNumberPredicateParser add:[[PKSymbol symbolWithString:@"!="] discard]];
        [neNumberPredicateParser add:self.numberParser];
        [neNumberPredicateParser setAssembler:self selector:@selector(parser:didMatchNeNumberPredicate:)];
    }
    return neNumberPredicateParser;
}


- (PKCollectionParser *)neBoolPredicateParser {
    if (!neBoolPredicateParser) {
        self.neBoolPredicateParser = [PKSequence sequence];
        [neBoolPredicateParser add:self.attrParser];
        [neBoolPredicateParser add:[[PKSymbol symbolWithString:@"!="] discard]];
        [neBoolPredicateParser add:self.boolParser];
        [neBoolPredicateParser setAssembler:self selector:@selector(parser:didMatchNeBoolPredicate:)];
    }
    return neBoolPredicateParser;
}


// gtPredicate          = attr '>' value
- (PKCollectionParser *)gtPredicateParser {
    if (!gtPredicateParser) {
        self.gtPredicateParser = [PKSequence sequence];
        [gtPredicateParser add:self.attrParser];
        [gtPredicateParser add:[[PKSymbol symbolWithString:@">"] discard]];
        [gtPredicateParser add:self.valueParser];
        [gtPredicateParser setAssembler:self selector:@selector(parser:didMatchGtPredicate:)];
    }
    return gtPredicateParser;
}


// gteqPredicate        = attr '>=' value
- (PKCollectionParser *)gteqPredicateParser {
    if (!gteqPredicateParser) {
        self.gteqPredicateParser = [PKSequence sequence];
        [gteqPredicateParser add:self.attrParser];
        [gteqPredicateParser add:[[PKSymbol symbolWithString:@">="] discard]];
        [gteqPredicateParser add:self.valueParser];
        [gteqPredicateParser setAssembler:self selector:@selector(parser:didMatchGteqPredicate:)];
    }
    return gteqPredicateParser;
}


// ltPredicate          = attr '<' value
- (PKCollectionParser *)ltPredicateParser {
    if (!ltPredicateParser) {
        self.ltPredicateParser = [PKSequence sequence];
        [ltPredicateParser add:self.attrParser];
        [ltPredicateParser add:[[PKSymbol symbolWithString:@"<"] discard]];
        [ltPredicateParser add:self.valueParser];
        [ltPredicateParser setAssembler:self selector:@selector(parser:didMatchLtPredicate:)];
    }
    return ltPredicateParser;
}


// lteqPredicate        = attr '<=' value
- (PKCollectionParser *)lteqPredicateParser {
    if (!lteqPredicateParser) {
        self.lteqPredicateParser = [PKSequence sequence];
        [lteqPredicateParser add:self.attrParser];
        [lteqPredicateParser add:[[PKSymbol symbolWithString:@"<="] discard]];
        [lteqPredicateParser add:self.valueParser];
        [lteqPredicateParser setAssembler:self selector:@selector(parser:didMatchLteqPredicate:)];
    }
    return lteqPredicateParser;
}


// beginswithPredicate  = attr 'beginswith' value
- (PKCollectionParser *)beginswithPredicateParser {
    if (!beginswithPredicateParser) {
        self.beginswithPredicateParser = [PKSequence sequence];
        [beginswithPredicateParser add:self.attrParser];
        [beginswithPredicateParser add:[[PKCaseInsensitiveLiteral literalWithString:@"beginswith"] discard]];
        [beginswithPredicateParser add:self.valueParser];
        [beginswithPredicateParser setAssembler:self selector:@selector(parser:didMatchBeginswithPredicate:)];
    }
    return beginswithPredicateParser;
}


// containsPredicate    = attr 'contains' value
- (PKCollectionParser *)containsPredicateParser {
    if (!containsPredicateParser) {
        self.containsPredicateParser = [PKSequence sequence];
        [containsPredicateParser add:self.attrParser];
        [containsPredicateParser add:[[PKCaseInsensitiveLiteral literalWithString:@"contains"] discard]];
        [containsPredicateParser add:self.valueParser];
        [containsPredicateParser setAssembler:self selector:@selector(parser:didMatchContainsPredicate:)];
    }
    return containsPredicateParser;
}


// endswithPredicate    = attr 'endswith' value
- (PKCollectionParser *)endswithPredicateParser {
    if (!endswithPredicateParser) {
        self.endswithPredicateParser = [PKSequence sequence];
        [endswithPredicateParser add:self.attrParser];
        [endswithPredicateParser add:[[PKCaseInsensitiveLiteral literalWithString:@"endswith"] discard]];
        [endswithPredicateParser add:self.valueParser];
        [endswithPredicateParser setAssembler:self selector:@selector(parser:didMatchEndswithPredicate:)];
    }
    return endswithPredicateParser;
}


// matchesPredicate     = attr 'matches' value
- (PKCollectionParser *)matchesPredicateParser {
    if (!matchesPredicateParser) {
        self.matchesPredicateParser = [PKSequence sequence];
        [matchesPredicateParser add:self.attrParser];
        [matchesPredicateParser add:[[PKCaseInsensitiveLiteral literalWithString:@"matches"] discard]];
        [matchesPredicateParser add:self.valueParser];
        [matchesPredicateParser setAssembler:self selector:@selector(parser:didMatchMatchesPredicate:)];
    }
    return matchesPredicateParser;
}


// value                = QuotedString | Number | bool
- (PKCollectionParser *)valueParser {
    if (!valueParser) {
        self.valueParser = [PKAlternation alternation];
        [valueParser add:self.stringParser];
        [valueParser add:self.numberParser];
        [valueParser add:self.boolParser];
    }
    return valueParser;
}


- (PKCollectionParser *)boolParser {
    if (!boolParser) {
        self.boolParser = [PKAlternation alternation];
        [boolParser add:self.trueParser];
        [boolParser add:self.falseParser];
        [boolParser setAssembler:self selector:@selector(parser:didMatchBool:)];
    }
    return boolParser;
}


- (PKParser *)trueParser {
    if (!trueParser) {
        self.trueParser = [[PKCaseInsensitiveLiteral literalWithString:@"true"] discard];
        [trueParser setAssembler:self selector:@selector(parser:didMatchTrue:)];
    }
    return trueParser;
}


- (PKParser *)falseParser {
    if (!falseParser) {
        self.falseParser = [[PKCaseInsensitiveLiteral literalWithString:@"false"] discard];
        [falseParser setAssembler:self selector:@selector(parser:didMatchFalse:)];
    }
    return falseParser;
}


- (PKParser *)stringParser {
    if (!stringParser) {
        self.stringParser = [PKQuotedString quotedString];
        [stringParser setAssembler:self selector:@selector(parser:didMatchString:)];
    }
    return stringParser;
}


- (PKParser *)numberParser {
    if (!numberParser) {
        self.numberParser = [PKNumber number];
        [numberParser setAssembler:self selector:@selector(parser:didMatchNumber:)];
    }
    return numberParser;
}


- (void)parser:(PKParser *)p didMatchAnd:(PKAssembly *)a {
    NSNumber *b2 = [a pop];
    NSNumber *b1 = [a pop];
    BOOL yn = ([b1 boolValue] && [b2 boolValue]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a {
    NSNumber *b2 = [a pop];
    NSNumber *b1 = [a pop];
    BOOL yn = ([b1 boolValue] || [b2 boolValue]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchEqStringPredicate:(PKAssembly *)a {
    NSString *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = [[delegate valueForAttributeKey:attrKey] isEqual:value];
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchEqNumberPredicate:(PKAssembly *)a {
    NSNumber *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = [value isEqualToNumber:[delegate valueForAttributeKey:attrKey]];
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchEqBoolPredicate:(PKAssembly *)a {
    NSNumber *b = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = ([delegate boolForAttributeKey:attrKey] == [b boolValue]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchNeStringPredicate:(PKAssembly *)a {
    NSString *value = [a pop];
    NSString *attrKey = [a pop];
    
    BOOL yn = ![[delegate valueForAttributeKey:attrKey] isEqual:value];
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchNeNumberPredicate:(PKAssembly *)a {
    NSNumber *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = ![value isEqualToNumber:[delegate valueForAttributeKey:attrKey]];
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchNeBoolPredicate:(PKAssembly *)a {
    NSNumber *b = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = ([delegate boolForAttributeKey:attrKey] != [b boolValue]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchGtPredicate:(PKAssembly *)a {
    NSNumber *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = (NSOrderedDescending == [[delegate valueForAttributeKey:attrKey] compare:value]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchGteqPredicate:(PKAssembly *)a {
    NSNumber *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = (NSOrderedAscending != [[delegate valueForAttributeKey:attrKey] compare:value]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchLtPredicate:(PKAssembly *)a {
    NSNumber *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = (NSOrderedAscending == [[delegate valueForAttributeKey:attrKey] compare:value]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchLteqPredicate:(PKAssembly *)a {
    NSNumber *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = (NSOrderedDescending != [[delegate valueForAttributeKey:attrKey] compare:value]);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchBeginswithPredicate:(PKAssembly *)a {
    NSString *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = [[delegate valueForAttributeKey:attrKey] hasPrefix:value];
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchContainsPredicate:(PKAssembly *)a {
    NSString *value = [a pop];
    NSString *attrKey = [a pop];
    NSRange r = [[delegate valueForAttributeKey:attrKey] rangeOfString:value];
    BOOL yn = (NSNotFound != r.location);
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchEndswithPredicate:(PKAssembly *)a {
    NSString *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = [[delegate valueForAttributeKey:attrKey] hasSuffix:value];
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchMatchesPredicate:(PKAssembly *)a {
    NSString *value = [a pop];
    NSString *attrKey = [a pop];
    BOOL yn = [[delegate valueForAttributeKey:attrKey] isEqual:value]; // TODO should this be a regex match?
    [a push:[NSNumber numberWithBool:yn]];
}


- (void)parser:(PKParser *)p didMatchAttr:(PKAssembly *)a {
    [a push:[[a pop] stringValue]];
}


- (void)parser:(PKParser *)p didMatchNegatedValue:(PKAssembly *)a {
    NSNumber *b = [a pop];
    [a push:[NSNumber numberWithBool:![b boolValue]]];
}


- (void)parser:(PKParser *)p didMatchBool:(PKAssembly *)a {
    NSNumber *b = [a pop];
    [a push:[NSNumber numberWithBool:[b boolValue]]];
}


- (void)parser:(PKParser *)p didMatchTrue:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:YES]];
}


- (void)parser:(PKParser *)p didMatchFalse:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:NO]];
}


- (void)parser:(PKParser *)p didMatchString:(PKAssembly *)a {
    NSString *s = [[[a pop] stringValue] stringByTrimmingQuotes];
    [a push:s];
}


- (void)parser:(PKParser *)p didMatchNumber:(PKAssembly *)a {
    NSNumber *b = [NSNumber numberWithFloat:[(PKToken *)[a pop] floatValue]];
    [a push:b];
}

@synthesize exprParser;
@synthesize orTermParser;
@synthesize termParser;
@synthesize andPrimaryExprParser;
@synthesize primaryExprParser;
@synthesize phraseParser;
@synthesize negatedPredicateParser;
@synthesize predicateParser;
@synthesize attrParser;
@synthesize tagParser;
@synthesize eqStringPredicateParser;
@synthesize eqNumberPredicateParser;
@synthesize eqBoolPredicateParser;
@synthesize neStringPredicateParser;
@synthesize neNumberPredicateParser;
@synthesize neBoolPredicateParser;
@synthesize gtPredicateParser;
@synthesize gteqPredicateParser;
@synthesize ltPredicateParser;
@synthesize lteqPredicateParser;
@synthesize beginswithPredicateParser;
@synthesize containsPredicateParser;
@synthesize endswithPredicateParser;
@synthesize matchesPredicateParser;
@synthesize valueParser;
@synthesize boolParser;
@synthesize trueParser;
@synthesize falseParser;
@synthesize stringParser;
@synthesize numberParser;
@end
