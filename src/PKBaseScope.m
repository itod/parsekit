//
//  PKBaseScope.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKBaseScope.h"
#import "PKBaseSymbol.h"

@interface PKBaseScope ()
@property (nonatomic, copy, readwrite) NSString *scopeName;
@property (nonatomic, copy, readwrite) id <PKScope>enclosingScope;
@property (nonatomic, retain) NSMutableDictionary *symbols;
@end

@implementation PKBaseScope

- (id)init {
    self = [super init];
    if (self) {
        self.symbols = [NSMutableDictionary dictionary];
    }
    return self;
}


- (void)dealloc {
    self.scopeName = nil;
    self.enclosingScope = nil;
    self.symbols = nil;
    [super dealloc];
}


- (void)define:(PKBaseSymbol *)sym {
    NSParameterAssert(sym);
    NSParameterAssert(sym.name);
    
    _symbols[sym.name] = sym;
}


- (PKBaseSymbol *)resolve:(NSString *)name {
    NSParameterAssert(name);
    
    PKBaseSymbol *sym = _symbols[name];
    return sym;
}

@end
