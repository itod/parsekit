//
//  PKNodeTerminal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseNode.h"

@class PEGTokenKindDescriptor;

@interface PKConstantNode : PKBaseNode

@property (nonatomic, copy) NSString *literal;
@property (nonatomic, retain) PEGTokenKindDescriptor *tokenKind;
@end
