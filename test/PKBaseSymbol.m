//
//  PKBaseSymbol.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKBaseSymbol.h"

@interface PKBaseSymbol ()
@property (nonatomic, copy, readwrite) NSString *name;
@end

@implementation PKBaseSymbol

+ (id)symbolWithName:(NSString *)name {
    return [self symbolWithName:name type:nil];
}


+ (id)symbolWithName:(NSString *)name type:(id <PKType>)type {
    return [[[self alloc] initWithName:name type:type] autorelease];
}


- (id)initWithName:(NSString *)name {
    self = [self initWithName:name type:nil];
    return self;
}


- (id)initWithName:(NSString *)name type:(id <PKType>)type {
    self = [super init];
    if (self) {
        self.name = name;
        self.type = type;
    }
    return self;
}


- (void)dealloc {
    self.name = nil;
    self.type = nil;
    self.def = nil;
    self.scope = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKBaseSymbol *that = [[[self class] alloc] initWithName:_name];
    that->_type = _type; // don't copy, just ref
    that->_def = _def;
    that->_scope = _scope;
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }
    
    PKBaseSymbol *that = (PKBaseSymbol *)obj;
    
    if (![_name isEqual:that->_name]) {
        return NO;
    }
    
    if (_type != _type) {
        return NO;
    }
    
    if (_def != _def) {
        return NO;
    }
    
    if (_scope != _scope) {
        return NO;
    }
    
    return YES;
}


- (NSString *)description {
    NSString *str = nil;

    if (_type) {
        str = [NSString stringWithFormat:@"<%@:%@>", _name, _type];
    } else {
        str = _name;
    }
    
    return str;
}

@end
