//
//  PKNodeTerminal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseNode.h"

@interface PKConstantNode : PKBaseNode

@property (nonatomic, copy) NSString *literal;
@end
