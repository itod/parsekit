//
//  PKNodeTypes.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#ifndef ParseKit_PKASTNodeType_h
#define ParseKit_PKASTNodeType_h

#import <Foundation/Foundation.h>
#import "PKNodeBase.h"

typedef enum {
    PKNodeTypeVariable = 0,
    PKNodeTypeConstant,
    PKNodeTypeDelimited,
    PKNodeTypePattern,
    PKNodeTypeComposite,
    PKNodeTypeCollection,
    PKNodeTypeCardinal,
    PKNodeTypeOptional,
    PKNodeTypeMultiple,
//    PKNodeTypeRepetition,
//    PKNodeTypeDifference,
//    PKNodeTypeNegation,
} PKNodeType;

#endif
