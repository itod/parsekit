//
//  TDRegexMatcher.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/2/12.
//
//

#import <Foundation/Foundation.h>

@interface TDRegexMatcher : NSObject

+ (TDRegexMatcher *)matcherWithRegex:(NSString *)regex;

- (id)initWithRegex:(NSString *)regex;

- (BOOL)matches:(NSString *)inputStr;
//- (NSArray *)capturesFor:(NSString *)inputStr;
@end
