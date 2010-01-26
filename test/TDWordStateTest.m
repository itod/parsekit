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

#import "TDWordStateTest.h"


@implementation TDWordStateTest

- (void)setUp {
    wordState = [[PKWordState alloc] init];
}


- (void)tearDown {
    [wordState release];
    [r release];
}


- (void)testA {
    s = @"a";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"a", tok.stringValue);
    TDEqualObjects(@"a", tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testASpace {
    s = @"a ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"a", tok.stringValue);
    TDEqualObjects(@"a", tok.value);
    TDTrue(tok.isWord);
    TDEquals((PKUniChar)' ', [r read]);
}


- (void)testAb {
    s = @"ab";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testAbc {
    s = @"abc";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testItApostropheS {
    s = @"it's";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testTwentyDashFive {
    s = @"twenty-five";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testTwentyUnderscoreFive {
    s = @"twenty_five";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}


- (void)testNumber1 {
    s = @"number1";
    r = [[PKReader alloc] initWithString:s];
    PKToken *tok = [wordState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDEqualObjects(s, tok.value);
    TDTrue(tok.isWord);
    TDEquals(PKEOF, [r read]);
}

@end
