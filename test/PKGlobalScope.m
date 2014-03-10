//
//  PKGlobalScope.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKGlobalScope.h"
#import "PKBuiltInTypeSymbol.h"

@interface PKGlobalScope ()
- (void)setUpBuiltInTypes;
@end

@implementation PKGlobalScope

- (id)init {
    self = [super init];
    if (self) {
        [self setUpBuiltInTypes];
    }
    return self;
}


- (NSString *)scopeName {
    return @"globals";
}


- (id <PKScope>)enclosingScope {
    return nil;
}


- (void)setUpBuiltInTypes {
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Number"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Word"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"LowercaseWord"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"UppercaseWord"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"QuotedString"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Symbol"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Literal"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Comment"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Whitespace"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Pattern"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"DelimitedString"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Sequence"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Alternation"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Repetition"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Negation"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Intersction"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Difference"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"URL"]];
    [self define:[PKBuiltInTypeSymbol symbolWithName:@"Email"]];
}

@end
