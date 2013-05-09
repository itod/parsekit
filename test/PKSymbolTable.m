//
//  PKSymbolTable.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKSymbolTable.h"
#import "PKGlobalScope.h"

@interface PKSymbolTable ()
@property (nonatomic, retain) PKGlobalScope *globals;
@end

@implementation PKSymbolTable

- (id)init {
    self = [super init];
    if (self) {
        self.globals = [[[PKGlobalScope alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.globals = nil;
    [super dealloc];
}


- (void)define:(PKBaseSymbol *)sym {
    [_globals define:sym];
}


- (PKBaseSymbol *)resolve:(NSString *)name {
    return [_globals resolve:name];
}


- (NSString *)scopeName {
    return [_globals scopeName];
}


- (id <PKScope>)enclosingScope {
    return [_globals enclosingScope];
}

@end
