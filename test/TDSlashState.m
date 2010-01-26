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

#import <ParseKit/TDSlashState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/TDSlashSlashState.h>
#import <ParseKit/TDSlashStarState.h>

@interface TDSlashState ()
@property (nonatomic, retain) TDSlashSlashState *slashSlashState;
@property (nonatomic, retain) TDSlashStarState *slashStarState;
@end

@implementation TDSlashState

- (id)init {
    if (self = [super init]) {
        self.slashSlashState = [[[TDSlashSlashState alloc] init] autorelease];
        self.slashStarState  = [[[TDSlashStarState alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.slashSlashState = nil;
    self.slashStarState = nil;
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    NSInteger c = [r read];
    if ('/' == c) {
        return [slashSlashState nextTokenFromReader:r startingWith:c tokenizer:t];
    } else if ('*' == c) {
        return [slashStarState nextTokenFromReader:r startingWith:c tokenizer:t];
    } else {
        if (-1 != c) {
            [r unread];
        }
        return [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0.0];
    }
}

@synthesize slashSlashState;
@synthesize slashStarState;
@synthesize reportsCommentTokens;
@end
