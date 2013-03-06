//
//  PKNodeCardinal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/6/12.
//
//

#import "PKNodeCollection.h"

@interface PKNodeCardinal : PKNodeCollection
@property (nonatomic, assign) NSInteger rangeStart;
@property (nonatomic, assign) NSInteger rangeEnd;
@end
