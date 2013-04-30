//
//  PKSParseTreeAssembler.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/25/13.
//
//

#import <Foundation/Foundation.h>

@class PKParseTree;

@interface PKSParseTreeAssembler : NSObject

@property (nonatomic, retain) PKParseTree *root;
@property (nonatomic, retain) PKParseTree *currentNode;
@property (nonatomic, retain) NSMutableArray *stack;
@end
