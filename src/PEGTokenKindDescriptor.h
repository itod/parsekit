//
//  PEGTokenKindDescriptor.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import <Foundation/Foundation.h>

@interface PEGTokenKindDescriptor : NSObject

+ (PEGTokenKindDescriptor *)descriptorWithStringValue:(NSString *)s name:(NSString *)name;
+ (PEGTokenKindDescriptor *)anyDescriptor;
+ (PEGTokenKindDescriptor *)eofDescriptor;

+ (void)clearCache;

@property (nonatomic, copy) NSString *stringValue;
@property (nonatomic, copy) NSString *name;
@end
