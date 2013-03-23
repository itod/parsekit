//  Copyright 2012 Todd Ditchendorf
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

#import "TDRegexMatcherTest.h"
#import "TDRegexMatcher.h"

@interface TDRegexMatcher ()
- (PKAssembly *)bestMatchFor:(NSString *)inputStr;

@property (nonatomic, retain) PKParser *parser;
@end

@implementation TDRegexMatcherTest

//- (void)setUp {
//
//    self.ass = [[[TDRegexAssembler alloc] init] autorelease];
//
//    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"regex" ofType:@"grammar"];
//    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//
//    NSError *err = nil;
//    self.regexParser = [[PKParserFactory factory] parserFromGrammar:g assembler:ass error:&err];
//    if (err) {
//        NSLog(@"%@", err);
//    }
//}
//
//
//- (void)tearDown {
//    PKReleaseSubparserTree(regexParser);
//    self.regexParser = nil;
//    self.ass = nil;
//}


- (TDRegexMatcher *)matcherForRegex:(NSString *)regex {
    return [TDRegexMatcher matcherWithRegex:regex];
}


- (void)testAabPlus {
    s = @"aab+";
    
    m = [self matcherForRegex:s];
    
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"aabbbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, a, b, b, b, b]aabbbb^", [res description]);
}


- (void)testAabStar {
    s = @"aab*";
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"aabbbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, a, b, b, b, b]aabbbb^", [res description]);
}


- (void)testAabQuestion {
    s = @"aab?";
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"aabbbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, a, b]aab^bbb", [res description]);
}


- (void)testAb {
    s = @"ab";
    m = [self matcherForRegex:s];

    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"ab";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, b]ab^", [res description]);
}


- (void)testAbc {
    s = @"abc";
    m = [self matcherForRegex:s];

    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"abc";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, b, c]abc^", [res description]);
}


- (void)testAOrB {
    s = @"a|b";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);

    PKParser *p = m.parser;
    TDNotNil(p);
    
    TDTrue([p isKindOfClass:[PKAlternation class]]);
    s = @"b";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b]b^", [res description]);
}


- (void)test4Or7 {
    s = @"4|7";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    s = @"4";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[4]4^", [res description]);
}


- (void)testAOrBStar {
    s = @"a|b*";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKAlternation class]]);
    s = @"bbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b, b, b]bbb^", [res description]);
}


- (void)testAOrBPlus {
    s = @"a|b+";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKAlternation class]]);
    s = @"bbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b, b, b]bbb^", [res description]);
    
    s = @"abbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^bbb", [res description]);
}


- (void)testAOrBQuestion {
    s = @"a|b?";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKAlternation class]]);
    s = @"bbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b]b^bb", [res description]);
    
    s = @"abbb";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^bbb", [res description]);
}


- (void)testParenAOrBParenStar {
    s = @"(a|b)*";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKRepetition class]]);
    s = @"bbbaaa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b, b, b, a, a, a]bbbaaa^", [res description]);
}


- (void)testParenAOrBParenPlus {
    s = @"(a|b)+";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"bbbaaa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b, b, b, a, a, a]bbbaaa^", [res description]);
}


- (void)testParenAOrBParenQuestion {
    s = @"(a|b)?";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKAlternation class]]);
    s = @"bbbaaa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[b]b^bbaaa", [res description]);
}


- (void)testOneInterval {
    s = @"a{1}";

    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^", [res description]);
    
    s = @"aa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^a", [res description]);
}


- (void)testTwoInterval {
    s = @"a{1,2}";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKSequence class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^", [res description]);
    
    s = @"aa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, a]aa^", [res description]);
    
    s = @"aaa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a, a]aa^a", [res description]);
}


- (void)testDot {
    s = @".";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKParser class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^", [res description]);
    
    s = @"aa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^a", [res description]);
    
    s = @"aaa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^aa", [res description]);
}


- (void)testWordCharClass {
    s = @"\\w";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKParser class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^", [res description]);
    
    s = @"aa";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^a", [res description]);
    
    s = @"1a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[1]1^a", [res description]);
}


- (void)testNotWordCharClass {
    s = @"\\W";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKParser class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDNil(res);
    
    s = @"1";
    res = [m bestMatchFor:s];
    TDNil(res);
    
    s = @"#";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[#]#^", [res description]);
}


- (void)testDigitCharClass {
    s = @"\\d";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKParser class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDNil(res);
    
    s = @"2";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[2]2^", [res description]);
    
    s = @"1a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[1]1^a", [res description]);
}


- (void)testNotDigitCharClass {
    s = @"\\D";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKParser class]]);
    s = @"a";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[a]a^", [res description]);
    
    s = @"1";
    res = [m bestMatchFor:s];
    TDNil(res);
    
    s = @"#";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[#]#^", [res description]);
}


- (void)testCustomCharClass {
    s = @"[dcq]";
    
    m = [self matcherForRegex:s];
    TDNotNil(m);
    TDTrue([m.parser isKindOfClass:[PKParser class]]);
    s = @"d";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[d]d^", [res description]);
    
    s = @"q";
    res = [m bestMatchFor:s];
    TDEqualObjects(@"[q]q^", [res description]);
    
    s = @"1";
    res = [m bestMatchFor:s];
    TDNil(res);
    
//    s = @"#";
//    res = [m bestMatchFor:s];
//    TDEqualObjects(@"[#]#^", [res description]);
}

@end
