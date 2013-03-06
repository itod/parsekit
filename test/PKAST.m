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

#import "PKAST.h"

@interface PKAST ()
@end

@implementation PKAST

+ (PKAST *)ASTWithToken:(PKToken *)tok {
    return [[[self alloc] initWithToken:tok] autorelease];
}


- (id)init {
    return [self initWithToken:nil];
}


- (id)initWithToken:(PKToken *)tok {
    self = [super init];
    if (self) {
        self.token = tok;
    }
    return self;
}


- (void)dealloc {
    self.token = nil;
    self.children = nil;
    [super dealloc];
}


- (NSString *)description {
    return [self treeDescription];
}


- (NSString *)treeDescription {
    if (![_children count]) {
        return [_token stringValue];
    }
    
    NSMutableString *ms = [NSMutableString string];
    
    if (![self isNil]) {
        [ms appendFormat:@"(%@ ", [_token stringValue]];
    }

    NSInteger i = 0;
    for (PKAST *child in _children) {
        if (i++) {
            [ms appendFormat:@" %@", [child treeDescription]];
        } else {
            [ms appendFormat:@"%@", [child treeDescription]];
        }
    }
    
    if (![self isNil]) {
        [ms appendString:@")"];
    }
    
    return [[ms copy] autorelease];
}


- (int)type {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return -1;
}


- (void)addChild:(PKAST *)c {
    if (!_children) {
        self.children = [NSMutableArray array];
    }
    [_children addObject:c];
}


- (BOOL)isNil {
    return !_token;
}

@end
