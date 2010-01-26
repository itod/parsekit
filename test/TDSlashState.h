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

#import <Foundation/Foundation.h>
#import <ParseKit/PKTokenizerState.h>

@class TDSlashSlashState;
@class TDSlashStarState;

/*!
    @class      TDSlashState 
    @brief      This state will either delegate to a comment-handling state, or return a <tt>PKSymbol</tt> token with just a slash in it.
*/
@interface TDSlashState : PKTokenizerState {
    TDSlashSlashState *slashSlashState;
    TDSlashStarState *slashStarState;
    BOOL reportsCommentTokens;
}


@property (nonatomic) BOOL reportsCommentTokens;
@end
