//
//  PKNodeNegation.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKNodeNegation.h"

@implementation PKNodeNegation

- (NSInteger)type {
    return PKNodeTypeNegation;
}


- (void)visit:(PKParserVisitor *)v {
    [v visitNegation:self];
}

@end
