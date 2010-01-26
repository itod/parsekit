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
#import <ParseKit/PKWhitespaceState.h>
#import <ParseKit/PKToken.h>

// NOTE: this class is not currently in use or included in the Framework. It is an example of how to add a new token type

static const NSInteger PKTokenTypeWhitespace = 5;

@interface PKToken (TDSignificantWhitespaceStateAdditions)
@property (nonatomic, readonly, getter=isWhitespace) BOOL whitespace;
@end

@interface TDSignificantWhitespaceState : PKWhitespaceState {

}
@end
