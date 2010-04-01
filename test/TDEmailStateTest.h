//
//  TDEmailStateTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/31/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTestScaffold.h"

@interface TDEmailStateTest : SenTestCase {
    PKEmailState *emailState;
    PKTokenizer *t;
    NSString *s;
    PKToken *tok;
}

@end
