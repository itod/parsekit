//
//  PKNodeRepetition.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKNodeRepetition.h"

@implementation PKNodeRepetition

- (NSInteger)type {
    return PKNodeTypeRepetition;
}


- (void)visit:(PKParserVisitor *)v {
    [v visitRepetition:self];
}

@end
