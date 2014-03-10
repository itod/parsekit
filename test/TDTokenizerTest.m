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

#import "TDTokenizerTest.h"
#import <ParseKit/ParseKit.h>

@implementation TDTokenizerTest

- (void)setUp {
}


- (void)tearDown {
}


- (void)testPythonImports {
    s =
    @"from Quartz.CoreGraphics import *\n"
    @"from Quartz.ImageIO import *\n"
    @"from Foundation import *\n";

    t = [PKTokenizer tokenizerWithString:s];
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    [t.symbolState add:@"**"];
    [t.symbolState add:@"//"];
    [t.symbolState add:@"<<"];
    [t.symbolState add:@">>"];
    [t.symbolState add:@"<="];
    [t.symbolState add:@">="];
    [t.symbolState add:@"=="];
    [t.symbolState add:@"!="];
    [t.symbolState add:@"+="];
    [t.symbolState add:@"-="];
    [t.symbolState add:@"*="];
    [t.symbolState add:@"/="];
    [t.symbolState add:@"//="];
    [t.symbolState add:@"%="];
    [t.symbolState add:@"&="];
    [t.symbolState add:@"|="];
    [t.symbolState add:@"^="];
    [t.symbolState add:@">>="];
    [t.symbolState add:@"<<="];
    [t.symbolState add:@"**="];
	
    [t setTokenizerState:t.wordState from:'_' to:'_'];
    [t.wordState setWordChars:YES from:'_' to:'_'];
	
    // setup comments
    t.commentState.reportsCommentTokens = YES;
    
    // remove default comments
    [t setTokenizerState:t.symbolState from:'/' to:'/'];
    [t.commentState removeSingleLineStartMarker:@"//"];
    [t.commentState removeMultiLineStartMarker:@"/*"];
    
    // add python comments
    [t setTokenizerState:t.commentState from:'#' to:'#'];
    [t.commentState addSingleLineStartMarker:@"#"];
    t.commentState.fallbackState = t.symbolState;
    
    // python doc strings
    [t.symbolState add:@"\"\"\""];
    [t setTokenizerState:t.delimitState from:'"' to:'"'];
    [t.delimitState addStartMarker:@"\"\"\"" endMarker:@"\"\"\"" allowedCharacterSet:nil];
    [t.delimitState setFallbackState:t.quoteState from:'"' to:'"'];
    
    // hex, oct, bin numbers
    [t.numberState addPrefix:@"0x" forRadix:16];
    [t.numberState addPrefix:@"0o" forRadix:8];
    //[t.numberState addPrefix:@"0"  forRadix:8];
    [t.numberState addPrefix:@"0b" forRadix:2];
    
    PKToken *tok = nil;
    
    tok = [t nextToken];
    TDEqualObjects(@"<Word «from»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «Quartz»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Symbol «.»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «CoreGraphics»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «import»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Symbol «*»>", [tok debugDescription]);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «from»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «Quartz»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Symbol «.»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «ImageIO»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «import»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Symbol «*»>", [tok debugDescription]);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «from»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «Foundation»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Word «import»>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Whitespace « »>", [tok debugDescription]);
    tok = [t nextToken];
    TDEqualObjects(@"<Symbol «*»>", [tok debugDescription]);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    tok = [t nextToken];
    TDTrue(tok.isEOF);
}


- (void)testCoreGraphics {
    s = @"CGContextAddArc(${ctx}, ${x}, ${y}, ${radius}, ${startAngle}, ${endAngle}, ${clockwise})";
    t = [PKTokenizer tokenizerWithString:s];
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    [t setTokenizerState:t.symbolState from:'/' to:'/'];
    
    [t setTokenizerState:t.delimitState from:'$' to:'$'];
    [t.symbolState add:@"${"];
    [t.delimitState addStartMarker:@"${" endMarker:@"}" allowedCharacterSet:nil];

    PKToken *tok = nil;
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"CGContextAddArc", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"(", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${ctx}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@",", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${x}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@",", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${y}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@",", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${radius}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@",", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${startAngle}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@",", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${endAngle}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@",", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"${clockwise}", tok.stringValue);
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(@")", tok.stringValue);
}


- (void)testBlastOff {
    s = @"\"It's 123 blast-off!\", she said, // watch out!\n"
        @"and <= 3 'ticks' later /* wince */, it's blast-off (to http://google.com)!";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    //NSLog(@"\n\n starting!!! \n\n");
    while ((tok = [t nextToken]) != eof) {
//        NSLog(@"(%@)", tok.stringValue);
    }
    //NSLog(@"\n\n done!!! \n\n");
    
}


- (void)testStuff {
    s = @"2 != 47. Blast-off!! 'Woo-hoo!'";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    while ((tok = [t nextToken]) != eof) {
        //NSLog(@"(%@) (%.1f) : %@", tok.stringValue, tok.floatValue, [tok debugDescription]);
    }
}


- (void)testStuffWithFastEnumeration {
    s = @"2 != 47. Blast-off!! 'Woo-hoo!'";
    t = [PKTokenizer tokenizerWithString:s];
    
    NSUInteger idx = 0;
    NSArray *results = @[
    @"(2) (2.0) : <Number «2»>",
    @"(!=) (0.0) : <Symbol «!=»>",
    @"(47) (47.0) : <Number «47»>",
    @"(.) (0.0) : <Symbol «.»>",
    @"(Blast-off) (0.0) : <Word «Blast-off»>",
    @"(!) (0.0) : <Symbol «!»>",
    @"(!) (0.0) : <Symbol «!»>",
    @"('Woo-hoo!') (0.0) : <Quoted String «'Woo-hoo!'»>",
    ];
    
    for (PKToken *tok in t) {
        NSString *expected = results[idx++];
        NSString *actual = [NSString stringWithFormat:@"(%@) (%.1f) : %@", tok.stringValue, tok.floatValue, [tok debugDescription]];
        //NSLog(@"%@", actual);
        TDEqualObjects(expected, actual);
    }
    
    TDEquals([results count], idx);
}


- (void)testStuffWithFastEnumeration2 {
    s = @"$00FF_FFFF %0001_0101";
    t = [PKTokenizer tokenizerWithString:s];
    
    [t.numberState addPrefix:@"$" forRadix:16];
    [t.numberState addGroupingSeparator:'_' forRadix:16];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    [t.numberState addPrefix:@"%" forRadix:2];
    [t.numberState addGroupingSeparator:'_' forRadix:2];
    [t setTokenizerState:t.numberState from:'%' to:'%'];
    
    
    NSUInteger idx = 0;
    NSArray *results = @[
        @"($00FF_FFFF) (16777215.0) : <Number «16777215»>",
        @"(%0001_0101) (21.0) : <Number «21»>",
    ];
    
    for (PKToken *tok in t) {
        NSString *expected = results[idx++];
        NSString *actual = [NSString stringWithFormat:@"(%@) (%.1f) : %@", tok.stringValue, tok.floatValue, [tok debugDescription]];
        //NSLog(@"%@", actual);
        TDEqualObjects(expected, actual);
    }
    
    TDEquals([results count], idx);
}


- (void)testStuff2 {
    s = @"2 != 47. Blast-off!! 'Woo-hoo!'";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"2");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:2.0]);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"!=");
    TDEqualObjects(tok.value, @"!=");
    TDEquals(tok.offset, (NSUInteger)2);

    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"47");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:47.0]);
    TDEquals(tok.offset, (NSUInteger)5);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEqualObjects(tok.value, @".");
    TDEquals(tok.offset, (NSUInteger)7);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"Blast-off");
    TDEqualObjects(tok.value, @"Blast-off");
    TDEquals(tok.offset, (NSUInteger)9);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"!");
    TDEqualObjects(tok.value, @"!");
    TDEquals(tok.offset, (NSUInteger)18);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"!");
    TDEqualObjects(tok.value, @"!");
    TDEquals(tok.offset, (NSUInteger)19);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isQuotedString);
    TDEqualObjects(tok.stringValue, @"'Woo-hoo!'");
    TDEqualObjects(tok.value, @"'Woo-hoo!'");
    TDEquals(tok.offset, (NSUInteger)21);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok == eof);
}


- (void)testFortySevenDot {
    s = @"47.";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"47");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:47.0]);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEqualObjects(tok.value, @".");
    TDEquals(tok.offset, (NSUInteger)2);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok == eof);
}


- (void)testFortySevenDotSpaceFoo {
    s = @"47. foo";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"47");
    TDEqualObjects(tok.value, [NSNumber numberWithFloat:47.0]);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEqualObjects(tok.value, @".");
    TDEquals(tok.offset, (NSUInteger)2);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok != eof);
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEqualObjects(tok.value, @"foo");
    TDEquals(tok.offset, (NSUInteger)4);
    
    tok = [t nextToken];
    TDNotNil(tok);
    TDTrue(tok == eof);
}


- (void)testDotOne {
    s = @"   .999";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    STAssertEqualsWithAccuracy((PKFloat)0.999, tok.floatValue, 0.01, @"");
    TDTrue(tok.isNumber);
    TDEquals(tok.offset, (NSUInteger)3);

//    if (tok.isEOFen) break;
    
}


- (void)testSpaceDotSpace {
    s = @" . ";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@".", tok.stringValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)1);

    //    if (tok.isEOFen) break;
    
}


- (void)testInitSig {
    s = @"- (id)init {";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"-", tok.stringValue);
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDEqualObjects(@"(", tok.stringValue);
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)2);
}


- (void)testInitSig2 {
    s = @"-(id)init {";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"-", tok.stringValue);
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);
	
    tok = [t nextToken];
    TDEqualObjects(@"(", tok.stringValue);
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)1);
}


- (void)testMinusSpaceTwo {
    s = @"- 2";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"-", tok.stringValue);
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDEqualObjects(@"2", tok.stringValue);
    TDEquals((PKFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEquals(tok.offset, (NSUInteger)2);
}


- (void)testMinusPlusTwo {
    s = @"+2";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *tok = [t nextToken];
    TDEqualObjects(@"+", tok.stringValue);
    TDTrue(tok.isSymbol);
    TDEquals(tok.offset, (NSUInteger)0);

    tok = [t nextToken];
    TDEquals((PKFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"2", tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)1);

    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testMinusPlusTwoCustom {
    s = @"+2";
    t = [PKTokenizer tokenizerWithString:s];
    [t setTokenizerState:t.numberState from:'+' to:'+'];
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+2", tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    TDEquals([PKToken EOFToken], [t nextToken]);
}


- (void)testSimpleAPIUsage {
    s = @".    ,    ()  12.33333 .:= .456\n\n>=<     'boooo'fasa  this should /*     not*/ appear \r /*but  */this should >=<//n't";

    t = [PKTokenizer tokenizerWithString:s];
    
    [t.symbolState add:@":="];
    [t.symbolState add:@">=<"];
    
    NSMutableArray *toks = [NSMutableArray array];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *token = nil;
    while ((token = [t nextToken])) {
        if (eof == token) break;
        
        [toks addObject:token];

    }

    //NSLog(@"\n\n\n\ntoks: %@\n\n\n\n", toks);
}


- (void)testKatakana1 {
    s = @"ア";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [t nextToken];
    
    TDNotNil(tok);
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDEqualObjects(eof, tok);
}


- (void)testKatakana2 {
    s = @"アア";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [t nextToken];
    
    TDNotNil(tok);
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDEqualObjects(eof, tok);
}


- (void)testKatakana3 {
    s = @"アェ";
    t = [PKTokenizer tokenizerWithString:s];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [t nextToken];
    
    TDNotNil(tok);
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.offset, (NSUInteger)0);
    
    tok = [t nextToken];
    TDEqualObjects(eof, tok);
}


- (void)testParenStuff {
    s = @"-(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"-");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)4);
	
	tok = [t nextToken];
	TDTrue(tok.isNumber);
	TDEqualObjects(tok.stringValue, @"5");
	TDEquals((PKFloat)5.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)5);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @")");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)6);
}


- (void)testParenStuff2 {
    s = @"- (ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	t.whitespaceState.reportsWhitespaceTokens = YES;
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"-");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isWhitespace);
	TDEqualObjects(tok.stringValue, @" ");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)3);
}


- (void)testParenStuff3 {
    s = @"+(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)4);
	
	tok = [t nextToken];
	TDTrue(tok.isNumber);
	TDEqualObjects(tok.stringValue, @"5");
	TDEquals((PKFloat)5.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)5);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @")");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)6);
}


- (void)testParenStuff4 {
    s = @"+ (ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	t.whitespaceState.reportsWhitespaceTokens = YES;
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isWhitespace);
	TDEqualObjects(tok.stringValue, @" ");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);

	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)3);
}


- (void)testParenStuff5 {
    s = @".(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @".");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"+");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)4);
	
	tok = [t nextToken];
	TDTrue(tok.isNumber);
	TDEqualObjects(tok.stringValue, @"5");
	TDEquals((PKFloat)5.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)5);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @")");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)6);
}


- (void)testParenStuff6 {
    s = @". (ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
	t.whitespaceState.reportsWhitespaceTokens = YES;
	
	PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @".");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)0);

	tok = [t nextToken];
	TDTrue(tok.isWhitespace);
	TDEqualObjects(tok.stringValue, @" ");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)1);
	
	tok = [t nextToken];
	TDTrue(tok.isSymbol);
	TDEqualObjects(tok.stringValue, @"(");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)2);

	tok = [t nextToken];
	TDTrue(tok.isWord);
	TDEqualObjects(tok.stringValue, @"ab");
	TDEquals((PKFloat)0.0, tok.floatValue);
    TDEquals(tok.offset, (NSUInteger)3);
}


- (void)testParenStuff7 {
    s = @"-(ab+5)";
    t = [PKTokenizer tokenizerWithString:s];
    
    NSMutableString *final = [NSMutableString string];
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = nil;
    while ((tok = [t nextToken]) != eof) {
        [final appendString:[tok stringValue]];
    }
    
    TDNotNil(tok);
    TDEqualObjects(final, s);
    TDEqualObjects(eof, [t nextToken]);
}

@end
