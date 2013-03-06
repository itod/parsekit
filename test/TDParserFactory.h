//
//  TDParserFactory.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/3/12.
//
//

#import <Foundation/Foundation.h>

@class PKParser;
@class PKAST;

void PKReleaseSubparserTree(PKParser *p);

typedef enum {
    TDParserFactoryAssemblerSettingBehaviorOnAll        = 1 << 1, // Default
    TDParserFactoryAssemblerSettingBehaviorOnTerminals  = 1 << 2,
    TDParserFactoryAssemblerSettingBehaviorOnExplicit   = 1 << 3,
    TDParserFactoryAssemblerSettingBehaviorOnNone       = 1 << 4
} TDParserFactoryAssemblerSettingBehavior;

@interface TDParserFactory : NSObject

+ (TDParserFactory *)factory;

- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a error:(NSError **)outError;
- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a preassembler:(id)pa error:(NSError **)outError;

- (PKAST *)ASTFromGrammar:(NSString *)g error:(NSError **)outError;

@property (nonatomic, assign) TDParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;
@end
