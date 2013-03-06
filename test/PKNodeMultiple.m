//
//  PKNodeMultiple.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKNodeMultiple.h"

@implementation PKNodeMultiple

- (int)type {
    return PKNodeTypeMultiple;
}


- (void)visit:(PKNodeVisitor *)v {
    [v visitMultiple:self];
}

@end
