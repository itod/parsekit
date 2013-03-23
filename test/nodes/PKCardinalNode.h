//
//  PKNodeCardinal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/6/12.
//
//

#import "PKCollectionNode.h"

@interface PKCardinalNode : PKCollectionNode
@property (nonatomic, assign) NSUInteger rangeStart;
@property (nonatomic, assign) NSUInteger rangeEnd;
@end
