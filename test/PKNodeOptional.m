//
//  PKNodeOptional.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKNodeOptional.h"

@implementation PKNodeOptional

- (int)type {
    return PKNodeTypeOptional;
}


- (void)visit:(PKNodeVisitor *)v {
    [v visitOptional:self];
}

@end
