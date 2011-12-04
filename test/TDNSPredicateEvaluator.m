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

#import "TDNSPredicateEvaluator.h"
#import "PKParserFactory.h"
#import "NSString+ParseKitAdditions.h"
#import "NSArray+ParseKitAdditions.h"

@interface TDNSPredicateEvaluator ()
- (void)parser:(PKParser *)p didMatchCollectionPredicateAssembly:(PKAssembly *)a ordered:(NSComparisonResult)ordered;

@property (nonatomic, assign) id <TDKeyPathResolver>resolver;
@property (nonatomic, retain) PKToken *openCurly;
@end

@implementation TDNSPredicateEvaluator

- (id)initWithKeyPathResolver:(id <TDKeyPathResolver>)r {
    if (self = [super init]) {
        self.resolver = r;

        self.openCurly = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0];

        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"nspredicate" ofType:@"grammar"];
        NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        self.parser = [[PKParserFactory factory] parserFromGrammar:s assembler:self];
    }
    return self;
}


- (void)dealloc {
    resolver = nil;
    self.parser = nil;
    self.openCurly = nil;
    [super dealloc];
}


- (BOOL)evaluate:(NSString *)s {
    id result = [parser parse:s];
    return [result boolValue];
}


- (void)parser:(PKParser *)p didMatchNegatedPredicate:(PKAssembly *)a {
    BOOL b = [[a pop] boolValue];
    [a push:[NSNumber numberWithBool:!b]];
}


- (void)parser:(PKParser *)p didMatchNumComparisonPredicate:(PKAssembly *)a {
    CGFloat n2 = [(PKToken *)[a pop] floatValue];
    NSString *op = [[a pop] stringValue];
    CGFloat n1 = [(PKToken *)[a pop] floatValue];
    
    BOOL result = NO;
    if ([op isEqualToString:@"<"]) {
        result = n1 < n2;
    } else if ([op isEqualToString:@">"]) {
        result = n1 > n2;
    } else if ([op isEqualToString:@"="] || [op isEqualToString:@"=="]) {
        result = n1 == n2;
    } else if ([op isEqualToString:@"<="] || [op isEqualToString:@"=<"]) {
        result = n1 <= n2;
    } else if ([op isEqualToString:@">="] || [op isEqualToString:@"=>"]) {
        result = n1 >= n2;
    } else if ([op isEqualToString:@"!="] || [op isEqualToString:@"<>"]) {
        result = n1 != n2;
    }
    
    [a push:[NSNumber numberWithBool:result]];
}


- (void)parser:(PKParser *)p didMatchCollectionLtPredicate:(PKAssembly *)a {
    [self parser:p didMatchCollectionPredicateAssembly:a ordered:NSOrderedAscending];
}


- (void)parser:(PKParser *)p didMatchCollectionGtPredicate:(PKAssembly *)a {
    [self parser:p didMatchCollectionPredicateAssembly:a ordered:NSOrderedDescending];
}


- (void)parser:(PKParser *)p didMatchCollectionEqPredicate:(PKAssembly *)a {
    [self parser:p didMatchCollectionPredicateAssembly:a ordered:NSOrderedSame];
}


- (void)parser:(PKParser *)p didMatchCollectionPredicateAssembly:(PKAssembly *)a ordered:(NSComparisonResult)ordered {
    id value = [a pop];
    [a pop]; // discard op
    NSArray *array = [a pop];
    NSString *aggOp = [[a pop] stringValue];
    
    BOOL isAny = NSOrderedSame == [aggOp caseInsensitiveCompare:@"ANY"];
    BOOL isSome = NSOrderedSame == [aggOp caseInsensitiveCompare:@"SOME"];
    BOOL isNone = NSOrderedSame == [aggOp caseInsensitiveCompare:@"NONE"];
    BOOL isAll = NSOrderedSame == [aggOp caseInsensitiveCompare:@"ALL"];
    
    BOOL result = NO;
    if (isAny || isSome || isNone) {
        for (id obj in array) {
            if (ordered == [obj compare:value]) {
                result = YES;
                break;
            }
        }
    } else if (isAll) {
        NSInteger c = 0;
        for (id obj in array) {
            if (ordered != [obj compare:value]) {
                break;
            }
            c++;
        }
        result = c == [array count];
    }
    
    if (isNone) {
        result = !result;
    }
    
    [a push:[NSNumber numberWithBool:result]];
}


- (void)parser:(PKParser *)p didMatchString:(PKAssembly *)a {
    NSString *s = [[[a pop] stringValue] stringByTrimmingQuotes];
    [a push:s];
}


- (void)parser:(PKParser *)p didMatchStringTestPredicate:(PKAssembly *)a {
    NSString *s2 = [a pop];
    NSString *op = [[a pop] stringValue];
    NSString *s1 = [a pop];
    
    BOOL result = NO;
    if (NSOrderedSame == [op caseInsensitiveCompare:@"BEGINSWITH"]) {
        result = [s1 hasPrefix:s2];
    } else if (NSOrderedSame == [op caseInsensitiveCompare:@"CONTAINS"]) {
        result = (NSNotFound != [s1 rangeOfString:s2].location);
    } else if (NSOrderedSame == [op caseInsensitiveCompare:@"ENDSWITH"]) {
        result = [s1 hasSuffix:s2];
    } else if (NSOrderedSame == [op caseInsensitiveCompare:@"LIKE"]) {
        result = NSOrderedSame == [s1 caseInsensitiveCompare:s2]; // TODO
    } else if (NSOrderedSame == [op caseInsensitiveCompare:@"MATCHES"]) {
        result = NSOrderedSame == [s1 caseInsensitiveCompare:s2]; // TODO
    }
    
    [a push:[NSNumber numberWithBool:result]];
}


- (void)parser:(PKParser *)p didMatchAndAndTerm:(PKAssembly *)a {
    BOOL b2 = [[a pop] boolValue];
    BOOL b1 = [[a pop] boolValue];
    [a push:[NSNumber numberWithBool:b1 && b2]];
}


- (void)parser:(PKParser *)p didMatchOrOrTerm:(PKAssembly *)a {
    BOOL b2 = [[a pop] boolValue];
    BOOL b1 = [[a pop] boolValue];
    [a push:[NSNumber numberWithBool:b1 || b2]];
}


- (void)parser:(PKParser *)p didMatchArray:(PKAssembly *)a {
    NSArray *objs = [a objectsAbove:openCurly];
    [a pop]; // discard '{'
    [a push:[objs reversedArray]];
}


- (void)parser:(PKParser *)p didMatchCollectionTestPredicate:(PKAssembly *)a {
    NSArray *array = [a pop];
    NSAssert([array isKindOfClass:[NSArray class]], @"");
    id value = [a pop];
    [a push:[NSNumber numberWithBool:[array containsObject:value]]];
}


- (void)parser:(PKParser *)p didMatchKeyPath:(PKAssembly *)a {
    NSString *keyPath = [[a pop] stringValue];
    [a push:[resolver resolvedValueForKeyPath:keyPath]];
}


- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a {
    [a push:[NSNumber numberWithFloat:[(PKToken *)[a pop] floatValue]]];
}


- (void)parser:(PKParser *)p didMatchTrue:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:YES]];
}


- (void)parser:(PKParser *)p didMatchFalse:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:NO]];
}


- (void)parser:(PKParser *)p didMatchTruePredicate:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:YES]];
}


- (void)parser:(PKParser *)p didMatchFalsePredicate:(PKAssembly *)a {
    [a push:[NSNumber numberWithBool:NO]];
}

@synthesize resolver;
@synthesize parser;
@synthesize openCurly;
@end
