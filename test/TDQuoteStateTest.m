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

#import "TDQuoteStateTest.h"


@implementation TDQuoteStateTest

- (void)setUp {
    quoteState = [[PKQuoteState alloc] init];
    r = [[PKReader alloc] init];
}


- (void)tearDown {
    [quoteState release];
    [r release];
}


- (void)testQuotedString {
    s = @"'stuff'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    
}


- (void)testQuotedStringEOFTerminated {
    s = @"'stuff";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
}


- (void)testQuotedStringRepairEOFTerminated {
    s = @"'stuff";
    r.string = s;
    quoteState.balancesEOFTerminatedQuotes = YES;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"'stuff'", tok.stringValue);
}


- (void)testQuotedStringPlus {
    s = @"'a quote here' more";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(@"'a quote here'", tok.stringValue);
}


- (void)test14CharQuotedString {
    s = @"'123456789abcef'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test15CharQuotedString {
    s = @"'123456789abcefg'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test16CharQuotedString {
    s = @"'123456789abcefgh'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test31CharQuotedString {
    s = @"'123456789abcefgh123456789abcefg'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}


- (void)test32CharQuotedString {
    s = @"'123456789abcefgh123456789abcefgh'";
    r.string = s;
    PKToken *tok = [quoteState nextTokenFromReader:r startingWith:[r read] tokenizer:nil];
    TDEqualObjects(s, tok.stringValue);
    TDTrue(tok.isQuotedString);
}

@end
