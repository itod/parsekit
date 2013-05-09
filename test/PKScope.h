//
//  PKScope.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import <Foundation/Foundation.h>

@class PKBaseSymbol;

@protocol PKScope <NSObject>

- (void)define:(PKBaseSymbol *)sym;
- (PKBaseSymbol *)resolve:(NSString *)name;

@property (nonatomic, copy, readonly) NSString *scopeName;
@property (nonatomic, copy, readonly) id <PKScope>enclosingScope;
@end
