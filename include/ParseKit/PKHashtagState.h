//
//  PKHashtagState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/22/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#if PK_PLATFORM_TWITTER_STATE
#import <Foundation/Foundation.h>
#if PEGKIT
#import <PEGKit/PKTokenizerState.h>
#else
#import <ParseKit/PKTokenizerState.h>
#endif

/*!
 @class      PKHashtagState
 @brief      A hashtag state returns a hashtag from a reader.
 @details    
 */    
@interface PKHashtagState : PKTokenizerState {
    
}

@end
#endif
