//
//  PKNodeDifference.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKNodeDifference.h"

@implementation PKNodeDifference

- (NSInteger)type {
    return PKNodeTypeDifference;
}


- (void)visit:(PKParserVisitor *)v {
    [v visitDifference:self];
}

@end
