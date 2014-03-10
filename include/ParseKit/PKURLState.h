//
//  PKURLState.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/26/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#if PEGKIT
#import <PEGKit/PKTokenizerState.h>
#else
#import <ParseKit/PKTokenizerState.h>
#endif

/*!
    @class      PKURLState 
    @brief      A URL state returns a URL from a reader.
    @details    
*/    
@interface PKURLState : PKTokenizerState {
    PKUniChar c;
    PKUniChar lastChar;
    BOOL allowsWWWPrefix;
}

@property (nonatomic) BOOL allowsWWWPrefix;
@end
