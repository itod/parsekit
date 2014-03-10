//
//  TDTwitterStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/1/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#if PK_PLATFORM_TWITTER_STATE
#import "TDTwitterStateTest.h"

@implementation TDTwitterStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
    twitterState = t.twitterState;
    [t setTokenizerState:twitterState from:'@' to:'@'];
}


- (void)tearDown {
    [t release];
}


- (void)testAtiTod {
    s = @"@iTod";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isTwitter);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testPareniTodParen {
    s = @"(@iTod)";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isTwitter);
    TDEqualObjects(tok.stringValue, @"@iTod");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @")");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testiTodAposSQuote {
    s = @"@iTod's";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isTwitter);
    TDEqualObjects(tok.stringValue, @"@iTod");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isQuotedString);
    TDEqualObjects(tok.stringValue, @"'s");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


//- (void)testiTodAposS {
//    t.quoteState.allowsEOFTerminatedQuotes = NO;
//    s = @"@iTod's";
//    t.string = s;
//    
//    tok = [t nextToken];
//    TDTrue(tok.isTwitter);
//    TDEqualObjects(tok.stringValue, @"@iTod");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @"'");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"s");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects([PKToken EOFToken], tok);
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
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"something");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isWord);
//    TDEqualObjects(tok.stringValue, @"like");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isEmail);
//    TDEqualObjects(tok.stringValue, @"todd@gmail.com");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @".");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDTrue(tok.isSymbol);
//    TDEqualObjects(tok.stringValue, @")");
//    TDEquals(tok.floatValue, (PKFloat)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects([PKToken EOFToken], tok);
//}

@end
#endif
