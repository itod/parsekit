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

#import "TDSignificantWhitespaceStateTest.h"


@implementation TDSignificantWhitespaceStateTest

- (void)setUp {
    whitespaceState = [[TDSignificantWhitespaceState alloc] init];
}


- (void)tearDown {
    [whitespaceState release];
    [r release];
}


- (void)testSpace {
    s = @" ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testTwoSpaces {
    s = @"  ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testEmptyString {
    s = @"";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testTab {
    s = @"\t";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testNewLine {
    s = @"\n";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testCarriageReturn {
    s = @"\r";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testSpaceCarriageReturn {
    s = @" \r";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testSpaceTabNewLineSpace {
    s = @" \t\n ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(s, t.stringValue, @"");
    STAssertEquals(PKEOF, [r read], @"");
}


- (void)testSpaceA {
    s = @" a";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@" ", t.stringValue, @"");
    STAssertEquals((PKUniChar)'a', [r read], @"");
}

- (void)testSpaceASpace {
    s = @" a ";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@" ", t.stringValue, @"");
    STAssertEquals((PKUniChar)'a', [r read], @"");
}


- (void)testTabA {
    s = @"\ta";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\t", t.stringValue, @"");
    STAssertEquals((PKUniChar)'a', [r read], @"");
}


- (void)testNewLineA {
    s = @"\na";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\n", t.stringValue, @"");
    STAssertEquals((PKUniChar)'a', [r read], @"");
}


- (void)testCarriageReturnA {
    s = @"\ra";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\r", t.stringValue, @"");
    STAssertEquals((PKUniChar)'a', [r read], @"");
}


- (void)testNewLineSpaceCarriageReturnA {
    s = @"\n \ra";
    r = [[PKReader alloc] initWithString:s];
    PKToken *t = [whitespaceState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    STAssertNotNil(t, @"");
    STAssertEqualObjects(@"\n \r", t.stringValue, @"");
    STAssertEquals((PKUniChar)'a', [r read], @"");
}


@end
