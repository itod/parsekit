//
//  PKNodePattern.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import <ParseKit/PKPattern.h>
#import "PKNodeTypes.h"

@interface PKNodePattern : PKNodeBase

@property (nonatomic, retain) NSString *string;
@property (nonatomic, assign) PKPatternOptions options;
@end
