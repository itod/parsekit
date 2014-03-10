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

#import "TDDelimitStateTest.h"

@implementation TDDelimitStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
    delimitState = t.delimitState;
}


- (void)tearDown {
    [t release];
}


- (NSString *)stringInFile:(NSString *)filename {
    NSString *file = [filename stringByDeletingPathExtension];
    NSString *ext = [filename pathExtension];
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:file ofType:ext];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    return str;
}


- (void)testUnreadDivEightComment {
    s = @"foo/8\n//bar";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    // setup comments
    t.commentState.reportsCommentTokens = YES;
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    [t.commentState addSingleLineStartMarker:@"//"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    // comment state should fallback to delimit state to match regex delimited strings
    t.commentState.fallbackState = t.delimitState;
    
    // regex delimited strings
    cs = [[NSCharacterSet newlineCharacterSet] invertedSet];
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"foo", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isNumber);
    TDEqualObjects(@"8", tok.stringValue);
    TDEquals((double)8.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@"\n", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isComment);
    TDEqualObjects(@"//bar", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUnreadDivEightComment2 {
    s = @"foo/8\n//";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    // setup comments
    t.commentState.reportsCommentTokens = YES;
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    [t.commentState addSingleLineStartMarker:@"//"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    // comment state should fallback to delimit state to match regex delimited strings
    t.commentState.fallbackState = t.delimitState;
    
    // regex delimited strings
    cs = [[NSCharacterSet newlineCharacterSet] invertedSet];
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"foo", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isNumber);
    TDEqualObjects(@"8", tok.stringValue);
    TDEquals((double)8.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@"\n", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isComment);
    TDEqualObjects(@"//", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUnreadDivEight {
    s = @"{unread= unread/8";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
    // setup comments
    t.commentState.reportsCommentTokens = YES;
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    [t.commentState addSingleLineStartMarker:@"//"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    // comment state should fallback to delimit state to match regex delimited strings
    t.commentState.fallbackState = t.delimitState;
    
    // regex delimited strings
    cs = [[NSCharacterSet newlineCharacterSet] invertedSet];
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"{", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"unread", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"=", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWhitespace);
    TDEqualObjects(@" ", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"unread", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isNumber);
    TDEqualObjects(@"8", tok.stringValue);
    TDEquals((double)8.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSlashSlashEscapeSemi {
    s = @"/foo\\/bar/;";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/foo\\/bar/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@";", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSlashSlashEscape {
    s = @"/foo\\/bar/";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/foo\\/bar/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isEOF);
}


- (void)testSlashSlashEscapeBackslash {
    s = @"/foo\\\\/bar/";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/foo\\\\/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"bar", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isEOF);
}


- (void)testSlashSlashEscapeBackslashFile {
    s = [self stringInFile:[NSString stringWithFormat:@"%@.txt", NSStringFromSelector(_cmd)]];
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/foo\\\\/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"bar", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isEOF);
}


- (void)testNestedParens2 {
    s = @"(foo(bar))";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'(' to:'('];
    [delimitState addStartMarker:@"(" endMarker:@")" allowedCharacterSet:cs];
    delimitState.allowsNestedMarkers = YES;
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testNestedParens1 {
    s = @"(foo(bar))";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'(' to:'('];
    [delimitState addStartMarker:@"(" endMarker:@")" allowedCharacterSet:cs];
    delimitState.allowsNestedMarkers = NO;
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"(foo(bar)", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects(@")", tok.stringValue);
}


- (void)testLtFooGt {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSlashFooSlash {
    s = @"/foo/";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSlashFooSlashBar {
    s = @"/foo/bar";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/foo/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(@"bar", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSlashFooSlashSemi {
    s = @"/foo/;";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'/' to:'/'];
    [delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(@"/foo/", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(@";", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtFooGtWithFOAllowed {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"fo"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtFooGtWithFAllowed {
    s = @"<foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


//- (void)testLtFooGtWithFAllowedAndRemove {
//    s = @"<foo>";
//    t.string = s;
//    NSCharacterSet *cs = nil;
//    
//    [t setTokenizerState:delimitState from:'<' to:'<'];
//    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
//    [delimitState removeStartMarker:@"<"];
//    
//    tok = [t nextToken];
//    
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @"<");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"foo");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @">");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects([PKToken EOFToken], tok);
//}


- (void)testLtHashFooGt {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtHashFooGtWithFOAllowed {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"fo"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtHashFooGtWithFAllowed {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
#if PK_PLATFORM_TWITTER_STATE
    TDTrue(tok.isHashtag);
    TDEqualObjects(tok.stringValue, @"#foo");
    TDEquals(tok.floatValue, (double)0.0);
#else
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (double)0.0);
#endif
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtHashFooGtWithFAllowedAndMultiCharSymbol {
    s = @"<#foo>";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<#" endMarker:@">" allowedCharacterSet:cs];
    
    [t.symbolState add:@"<#"];
    
    tok = [t nextToken];
    
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<#");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtHashFooHashGt {
    s = @"=#foo#=";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'=' to:'='];
    [delimitState addStartMarker:@"=#" endMarker:@"#=" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtHashFooHashGtWithFOAllowed {
    s = @"=#foo#=";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"fo"];
    
    [t setTokenizerState:delimitState from:'=' to:'='];
    [delimitState addStartMarker:@"=#" endMarker:@"#=" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtHashFooHashGtWithFAllowed {
    s = @"=#foo#=";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"f"];
    
    [t setTokenizerState:delimitState from:'=' to:'='];
    [delimitState addStartMarker:@"=#" endMarker:@"#=" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"=");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
#if PK_PLATFORM_TWITTER_STATE
    TDTrue(tok.isHashtag);
    TDEqualObjects(tok.stringValue, @"#foo");
    TDEquals(tok.floatValue, (double)0.0);
#else
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (double)0.0);
#endif
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"=");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollar123Dollar {
    s = @"$123$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$" endMarker:@"$" allowedCharacterSet:cs];
    
    tok = [t nextToken];

    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollar123DollarDollar {
    s = @"$$123$$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$$" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollar123DollarHash {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollar123DollarHashDecimalDigitAllowed {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet decimalDigitCharacterSet];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollar123DollarHashAlphanumericAllowed {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet alphanumericCharacterSet];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollar123DollarHashAlphanumericAndWhitespaceAndNewlineAllowed {
    s = @"$$123 456\t789\n0$#";
    t.string = s;
    NSMutableCharacterSet *cs = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
    [cs formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
    [cs formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollar123DollarHashWhitespaceAllowed {
    s = @"$$123$#";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"123");
    TDEquals(tok.floatValue, (double)123.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"#");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollarDollarHash {
    s = @"$$$#";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollarDollar {
    s = @"$$$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"$");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtDollarDollarDollarBalanceEOFStrings {
    s = @"$$$";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    delimitState.balancesEOFTerminatedStrings = YES;
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"$$" endMarker:@"$#" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue, @"$$$$#");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testPHPPrint {
    s = @"<?= 'foo' ?>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<?=" endMarker:@"?>" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);

    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testPHP {
    s = @"<?php echo 'foo'; ?>";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'<' to:'<'];
    [delimitState addStartMarker:@"<?php" endMarker:@"?>" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testEnvVars {
    s = @"${PRODUCT_NAME} or ${EXECUTABLE_NAME}";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    
    [t setTokenizerState:delimitState from:'$' to:'$'];
    [delimitState addStartMarker:@"${" endMarker:@"}" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  @"${PRODUCT_NAME}");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue,  @"or");
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  @"${EXECUTABLE_NAME}");
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testCocoaString {
    s = @"@\"foo\"";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'@' to:'@'];
    [delimitState addStartMarker:@"@\"" endMarker:@"\"" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testAlphaMarkerXX {
    s = @"XXfooXX";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testAlphaMarkerXXAndXXX {
    s = @"XXfooXXX";
    t.string = s;
    NSCharacterSet *cs = nil;
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XXX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testAlphaMarkerXXFails {
    s = @"XXfooXX ";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"XXfooXX", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testAlphaMarkerXXFails2 {
    s = @"XXfooXX";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(@"XXfooXX", tok.stringValue);
    TDEquals((double)0.0, tok.floatValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testAlphaMarkerXXFalseStartMarker {
    s = @"XfooXX";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet whitespaceCharacterSet];
    
    [t setTokenizerState:delimitState from:'X' to:'X'];
    [delimitState addStartMarker:@"XX" endMarker:@"XX" allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testAtStartMarkerNilEndMarker {
    s = @"@foo";
    t.string = s;
    NSCharacterSet *cs = [NSCharacterSet alphanumericCharacterSet];
    
    [t setTokenizerState:delimitState from:'@' to:'@'];
    [delimitState addStartMarker:@"@" endMarker:nil allowedCharacterSet:cs];
    
    tok = [t nextToken];
    TDTrue(tok.isDelimitedString);
    TDEqualObjects(tok.stringValue,  s);
    TDEquals(tok.floatValue, (double)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


//- (void)testAtStartMarkerNilEndMarker2 {
//    s = @"@foo bar @ @baz ";
//    t.string = s;
//    NSCharacterSet *cs = [NSCharacterSet alphanumericCharacterSet];
//    
//    [t setTokenizerState:delimitState from:'@' to:'@'];
//    [delimitState addStartMarker:@"@" endMarker:nil allowedCharacterSet:cs];
//    
//    tok = [t nextToken];
//    TDTrue(tok.isDelimitedString);
//    TDEqualObjects(tok.stringValue,  @"@foo");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue,  @"bar");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue,  @"@");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isDelimitedString);
//    TDEqualObjects(tok.stringValue,  @"@baz");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects([PKToken EOFToken], tok);
//}
//
//
//- (void)testUnbalancedElementStartTag {
//    s = @"<foo bar=\"baz\" <bat ";
//    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"<"] invertedSet];
//    
//    t.string = s;
//    [t setTokenizerState:delimitState from:'<' to:'<'];
//    [delimitState addStartMarker:@"<" endMarker:@">" allowedCharacterSet:cs];
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue,  @"<");
//    TDEquals(tok.floatValue, (double)0.0);
//
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue,  @"foo");
//    TDEquals(tok.floatValue, (double)0.0);
//    
//    t.string = s;
//    delimitState.allowsUnbalancedStrings = YES;
//    
//    tok = [t nextToken];
//    TDTrue(tok.isDelimitedString);
//    TDEqualObjects(@"<foo bar=\"baz\" ", tok.stringValue);
//    TDEquals(tok.floatValue, (double)0.0);
//
//    tok = [t nextToken];
//    TDTrue(tok.isDelimitedString);
//    TDEqualObjects(@"<bat ", tok.stringValue);
//    TDEquals(tok.floatValue, (double)0.0);
//}

@end