//
//  PKTwitterState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/1/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#if PK_PLATFORM_TWITTER_STATE
#import <Foundation/Foundation.h>
#if PEGKIT
#import <PEGKit/PKTokenizerState.h>
#else
#import <ParseKit/PKTokenizerState.h>
#endif

/*!
    @class      PKTwitterState
    @brief      A twitter state returns a twitter handle from a reader.
    @details    
*/    
@interface PKTwitterState : PKTokenizerState {

}

@end
#endif
