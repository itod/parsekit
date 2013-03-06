//
//  PKNodeVariable.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKNodeVariable.h"

@implementation PKNodeVariable

- (void)dealloc {
    self.callbackName = nil;
    [super dealloc];
}


- (int)type {
    return PKNodeTypeVariable;
}


- (void)visit:(PKNodeVisitor *)v {
    [v visitVariable:self];
}

@end
