//
//  TDTwitterStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/1/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTwitterStateTest.h"

@implementation TDTwitterStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
    twitterState = t.twitterState;
}


- (void)tearDown {
    [t release];
}


- (void)testAtiTod {
    s = @"@iTod";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isTwitter);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}


- (void)testPareniTodParen {
    s = @"(@iTod)";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isTwitter);
    TDEqualObjects(tok.stringValue, @"@iTod");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @")");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}


- (void)testiTodAposSQuote {
    s = @"@iTod's";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isTwitter);
    TDEqualObjects(tok.stringValue, @"@iTod");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isQuotedString);
    TDEqualObjects(tok.stringValue, @"'s");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}


//- (void)testiTodAposS {
//    t.quoteState.allowsEOFTerminatedQuotes = NO;
//    s = @"@iTod's";
//    t.string = s;
//    
//    tok = [t nextToken];
//    TDTrue(tok.isTwitter);
//    TDEqualObjects(tok.stringValue, @"@iTod");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @"'");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"s");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects(tok, [PKToken EOFToken]);
//}
//
//
//- (void)testParenSomethingLikeToddAtGmailDotParen {
//    s = @"(something like todd@gmail.com.)";
//    t.string = s;
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @"(");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"something");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"like");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isEmail);
//    TDEqualObjects(tok.stringValue, @"todd@gmail.com");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @".");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @")");
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects(tok, [PKToken EOFToken]);
//}

@end
