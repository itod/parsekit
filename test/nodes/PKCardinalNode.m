//
//  PKNodeCardinal.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/6/12.
//
//

#import "PKCardinalNode.h"
#import <ParseKit/PKSequence.h>

@implementation PKCardinalNode

- (id)copyWithZone:(NSZone *)zone {
    PKCardinalNode *that = (PKCardinalNode *)[super copyWithZone:zone];
    that->_rangeStart = _rangeStart;
    that->_rangeEnd = _rangeEnd;
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }
    
    PKCardinalNode *that = (PKCardinalNode *)obj;
    
    if (_rangeStart != that->_rangeStart) {
        return NO;
    }
    
    if (_rangeEnd != that->_rangeEnd) {
        return NO;
    }
    
    return YES;
}


- (NSUInteger)type {
    return PKNodeTypeCardinal;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitCardinal:self];
}


- (Class)parserClass {
    return [PKSequence class];
}

@end
