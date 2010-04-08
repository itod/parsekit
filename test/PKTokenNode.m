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

#import "PKTokenNode.h"
#import <ParseKit/PKToken.h>

@interface PKTokenNode ()
@property (nonatomic, retain, readwrite) PKToken *token;
@end

@implementation PKTokenNode

+ (PKTokenNode *)tokenNodeWithToken:(PKToken *)s {
    return [[[self alloc] initWithToken:s] autorelease];
}


- (id)initWithToken:(PKToken *)s {
    if (self = [super init]) {
        self.token = s;
    }
    return self;
}


- (void)dealloc {
    self.token = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKTokenNode *n = [super copyWithZone:zone];
    n->token = [token copyWithZone:zone];
    return n;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKTokenNode '%@'>", token];
}

@synthesize token;
@end
