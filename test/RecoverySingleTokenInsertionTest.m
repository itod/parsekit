//
//  RecoverySingleTokenInsertionTest.m
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "RecoverySingleTokenInsertionTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "ElementAssignParser.h"

@interface RecoverySingleTokenInsertionTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) ElementAssignParser *parser;
@end

@implementation RecoverySingleTokenInsertionTest

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

- (void)testMissingBracket {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = NO;
    
    input = @"[3;";
    res = [_parser parseString:input assembler:nil error:&err];
    TDNotNil(err);
    TDNil(res);
}

- (void)testMissingBracketWithRecovery {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[3;";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 3, ;][/3/;^", [res description]);
}

- (void)testMissingBracketWithRecovery2 {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[3[";
    res = [_parser parseString:input assembler:nil error:&err];
//    TDNotNil(err);
//    TDNil(res);

    // this one works but not because of single token insertion. it works because of resyncSet
    TDEqualObjects(@"[[, 3, [][/3/[^", [res description]);
}

@end
