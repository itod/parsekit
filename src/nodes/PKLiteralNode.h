//
//  PKNodeLiteral.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/7/12.
//
//

#import "PKBaseNode.h"

@class PEGTokenKindDescriptor;

@interface PKLiteralNode : PKBaseNode

@property (nonatomic, assign) BOOL wantsCharacters;
@property (nonatomic, retain) PEGTokenKindDescriptor *tokenKind;
@end
