//
//  TDNSPredicateParserTest.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "TDTestScaffold.h"

@protocol TDKeyPathResolver <NSObject>
- (id)resolvedValueForKeyPath:(NSString *)s;
@end

@interface TDNSPredicateParserTest : SenTestCase <TDKeyPathResolver>

@end
