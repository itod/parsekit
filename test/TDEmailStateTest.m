//
//  TDEmailStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/31/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDEmailStateTest.h"

@implementation TDEmailStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
    emailState = t.emailState;
}


- (void)tearDown {
    [t release];
}


- (void)testToddAtGmail {
    s = @"todd@gmail.com";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isEmail);
    TDEqualObjects(tok.stringValue, s);
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}


- (void)testParenToddAtGmailParen {
    s = @"(todd@gmail.com)";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isEmail);
    TDEqualObjects(tok.stringValue, @"todd@gmail.com");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @")");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}


- (void)testParenSomethingLikeToddAtGmailDotParen {
    s = @"(something like todd@gmail.com.)";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"something");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"like");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isEmail);
    TDEqualObjects(tok.stringValue, @"todd@gmail.com");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @")");
    TDEquals(tok.floatValue, (CGFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects(tok, [PKToken EOFToken]);
}

@end
