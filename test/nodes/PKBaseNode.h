//
//  PKNode.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKAST.h"
#import "PKNodeVisitor.h" // convenience

typedef enum NSUInteger {
    PKNodeTypeRoot = 0,
    PKNodeTypeDefinition,
    PKNodeTypeReference,
    PKNodeTypeConstant,
    PKNodeTypeLiteral,
    PKNodeTypeDelimited,
    PKNodeTypePattern,
    PKNodeTypeWhitespace,
    PKNodeTypeComposite,
    PKNodeTypeCollection,
    PKNodeTypeAlternation,
    PKNodeTypeCardinal,
    PKNodeTypeOptional,
    PKNodeTypeMultiple,
} PKNodeType;

@class PKParser;

@interface PKBaseNode : PKAST
+ (id)nodeWithToken:(PKToken *)tok;

- (void)visit:(id <PKNodeVisitor>)v;

- (void)replaceChild:(PKBaseNode *)oldChild withChild:(PKBaseNode *)newChild;
- (void)replaceChild:(PKBaseNode *)oldChild withChildren:(NSArray *)newChildren;

@property (nonatomic, assign) BOOL discard;
@property (nonatomic, retain) Class parserClass;
@property (nonatomic, retain) PKParser *parser;
@end
