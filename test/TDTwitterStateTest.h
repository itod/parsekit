//
//  TDTwitterStateTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/1/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#if PK_PLATFORM_TWITTER_STATE
#import "TDTestScaffold.h"

@interface TDTwitterStateTest : SenTestCase {
    PKTwitterState *twitterState;
    PKTokenizer *t;
    NSString *s;
    PKToken *tok;
}

@end
#endif
