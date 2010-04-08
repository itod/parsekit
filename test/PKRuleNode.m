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

#import "PKRuleNode.h"

@interface PKRuleNode ()
@property (nonatomic, copy, readwrite) NSString *name;
@end

@implementation PKRuleNode

+ (PKRuleNode *)ruleNodeWithName:(NSString *)s {
    return [[[self alloc] initWithName:s] autorelease];
}


- (id)initWithName:(NSString *)s {
    if (self = [super init]) {
        self.name = s;
    }
    return self;
}


- (void)dealloc {
    self.name = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKRuleNode *n = [super copyWithZone:zone];
    n->name = [name copyWithZone:zone];
    return n;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKRuleNode '%@' %@>", name, children];
}

@synthesize name;
@end
