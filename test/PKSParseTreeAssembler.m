//
//  PKSParseTreeAssembler.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/25/13.
//
//

#import "PKSParseTreeAssembler.h"
#import <ParseKit/PEGParser.h>
#import <ParseKit/PEGTokenAssembly.h>
#import <ParseKit/PKToken.h>

#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"

@implementation PKSParseTreeAssembler

- (id)init {
    self = [super init];
    if (self) {
        self.stack = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.root = nil;
    self.currentNode = nil;
    self.stack = nil;
    [super dealloc];
}


- (void)parser:(PEGParser *)p willMatchInterior:(NSString *)ruleName {
    PKRuleNode *r = [PKRuleNode ruleNodeWithName:ruleName];
    if (!_root) {
        self.root = r;
    } else {
        [_currentNode addChild:r];
    }
    
    if (_currentNode) {
        [_stack addObject:_currentNode];
    }
    
    self.currentNode = r;
}


- (void)parser:(PEGParser *)p didMatchInterior:(NSString *)ruleName {
    self.currentNode = [_stack lastObject];
    [_stack removeLastObject];
}


- (void)parser:(PEGParser *)p willMatchLeaf:(NSString *)ruleName {
    NSAssert(_currentNode, @"");
    
    [_currentNode addChildToken:[p LT:1]];
}


- (void)parser:(PEGParser *)p didMatchLeaf:(NSString *)ruleName {
    
}

@end
