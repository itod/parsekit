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

#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"

@interface PKParseTree ()
@property (nonatomic, assign, readwrite) PKParseTree *parent;
@property (nonatomic, retain, readwrite) NSMutableArray *children;
@end

@implementation PKParseTree

+ (PKParseTree *)parseTree {
    return [[[self alloc] init] autorelease];
}


- (void)dealloc {
    self.parent = nil;
    self.children = nil;
    self.userInfo = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKParseTree *t = [[[self class] allocWithZone:zone] init];

    // assign parent
    if (parent) {
        t->parent = parent;
    
        // put new copy in new parent's children array
        NSInteger i = [[parent children] indexOfObject:self];
        if (NSNotFound != i) {
            [[t->parent children] replaceObjectAtIndex:i withObject:t];    
        }
    }

    // copy children
    if (children) {
        t->children = [children mutableCopyWithZone:zone];
    }
    return t;
}


- (PKRuleNode *)addChildRule:(NSString *)name {
    NSParameterAssert([name length]);
    PKRuleNode *n = [PKRuleNode ruleNodeWithName:name];
    [self addChild:n];
    return n;
}


- (PKTokenNode *)addChildToken:(PKToken *)tok {
    NSParameterAssert([[tok stringValue] length]);
    PKTokenNode *n = [PKTokenNode tokenNodeWithToken:tok];
    [self addChild:n];
    return n;
}


- (void)addChild:(PKParseTree *)tr {
    NSParameterAssert(tr);
    if (!children) {
        self.children = [NSMutableArray array];
    }
    tr.parent = self;
    [children addObject:tr];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKParseTree '%@'>", children];
}

@synthesize parent;
@synthesize children;
@synthesize userInfo;
@synthesize matched;
@end

