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


//- (void)testFooComBlahBlah {
//    s = @"http://foo.com/blah_blah";
//    t.string = s;
//    
//    tok = [t nextToken];
//    
//    TDTrue(tok.isURL);
//    TDEqualObjects(tok.stringValue, s);
//    TDEquals(tok.floatValue, (CGFloat)0.0);
//    
//    tok = [t nextToken];
//    TDEqualObjects(tok, [PKToken EOFToken]);
//}

@end
