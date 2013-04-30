//
//  RecoverySingleTokenInsertionTest.m
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "RecoverySingleTokenDeletionTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "ElementAssignParser.h"

@interface RecoverySingleTokenDeletionTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) ElementAssignParser *parser;
@end

@implementation RecoverySingleTokenDeletionTest

- (void)setUp {
    self.parser = [[[ElementAssignParser alloc] init] autorelease];
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testCorrectExpr {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"[3];[2];";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 3, ;, [, 2, ;][/3/]/;/[/2/]/;^", [res description]);
}

- (void)testExtraBracket {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = NO;
    
    input = @"[3]];";
    res = [_parser parseString:input assembler:nil error:&err];
    TDNotNil(err);
    TDNil(res);
}

- (void)testExtraBracketWithRecovery {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[3]];";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 3, ], ;][/3/]/]/;^", [res description]);
}

@end
