//
//  PKNodeDelimited.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKNodeTypes.h"

@interface PKNodeDelimited : PKNodeBase
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@end
