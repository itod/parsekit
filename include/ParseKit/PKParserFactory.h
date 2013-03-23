//
//  PKParserFactory.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKParser;
@class PKAST;

void PKReleaseSubparserTree(PKParser *p);

typedef enum {
    PKParserFactoryAssemblerSettingBehaviorOnNone       = 0,
    PKParserFactoryAssemblerSettingBehaviorOnTerminals  = 1,
    PKParserFactoryAssemblerSettingBehaviorOnExplicit   = 2,
    PKParserFactoryAssemblerSettingBehaviorOnAll        = 4, // Default
} PKParserFactoryAssemblerSettingBehavior;

@interface PKParserFactory : NSObject

+ (PKParserFactory *)factory;

- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a error:(NSError **)outError;
- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a preassembler:(id)pa error:(NSError **)outError;

- (PKAST *)ASTFromGrammar:(NSString *)g error:(NSError **)outError;

@property (nonatomic, assign) PKParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;
@end
