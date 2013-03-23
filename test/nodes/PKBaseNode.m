//
//  PKNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseNode.h"

@implementation PKBaseNode

+ (id)nodeWithToken:(PKToken *)tok {
    return [[[self alloc] initWithToken:tok] autorelease];
}


- (void)dealloc {
    self.parser = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKBaseNode *that = (PKBaseNode *)[super copyWithZone:zone];
    that->_discard = _discard;
    that->_parser = _parser;
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }

    PKBaseNode *that = (PKBaseNode *)obj;
    
    if (_discard != that->_discard) {
        return NO;
    }
    
    if (_parser != that->_parser) {
        return NO;
    }
    
    return YES;
}


- (void)replaceChild:(PKBaseNode *)oldChild withChild:(PKBaseNode *)newChild {
    NSParameterAssert(oldChild);
    NSParameterAssert(newChild);
    NSUInteger idx = [self.children indexOfObject:oldChild];
    NSAssert(NSNotFound != idx, @"");
    [self.children replaceObjectAtIndex:idx withObject:newChild];
}


- (void)replaceChild:(PKBaseNode *)oldChild withChildren:(NSArray *)newChildren {
    NSParameterAssert(oldChild);
    NSParameterAssert(newChildren);

    NSUInteger idx = [self.children indexOfObject:oldChild];
    NSAssert(NSNotFound != idx, @"");
    
    [self.children replaceObjectsInRange:NSMakeRange(idx, 1) withObjectsFromArray:newChildren];
}


- (void)visit:(id <PKNodeVisitor>)v; {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
}


- (Class)parserClass {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return Nil;
}

@end
