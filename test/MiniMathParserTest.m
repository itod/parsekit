//
//  MiniMathParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "MiniMathParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "MiniMathParser.h"

@interface MiniMathParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) MiniMathParser *parser;
@end

@implementation MiniMathParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"minimath" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"MiniMath";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[MiniMathParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/MiniMathParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/MiniMathParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testAddDisableActions {
    _parser.enableActions = NO;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"1+2" assembler:nil error:&err];
    
    TDEqualObjects(@"[1, 2]1/+/2^", [res description]);
}

- (void)testMultDisableActions {
    _parser.enableActions = NO;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"3*4" assembler:nil error:&err];
    
    TDEqualObjects(@"[3, 4]3/*/4^", [res description]);
}

- (void)testAddMultDisableActions {
    _parser.enableActions = NO;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"1+2*3+4" assembler:nil error:&err];
    
    TDEqualObjects(@"[1, 2, 3, 4]1/+/2/*/3/+/4^", [res description]);
}

- (void)testAddMultPowDisableActions {
    _parser.enableActions = NO;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"1+2*3^5+4" assembler:nil error:&err];
    
    TDEqualObjects(@"[1, 2, 3, 5, 4]1/+/2/*/3/^/5/+/4^", [res description]);
}

- (void)testAddEnableActions {
    _parser.enableActions = YES;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"1+2" assembler:nil error:&err];
    
    TDEqualObjects(@"[3]1/+/2^", [res description]);
}

- (void)testMultEnableActions {
    _parser.enableActions = YES;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"3*4" assembler:nil error:&err];
    
    TDEqualObjects(@"[12]3/*/4^", [res description]);
}

- (void)testAddMultEnableActions {
    _parser.enableActions = YES;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"1+2*3+4" assembler:nil error:&err];
    
    TDEqualObjects(@"[11]1/+/2/*/3/+/4^", [res description]);
}

- (void)testPowEnableActions {
    _parser.enableActions = YES;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"3^3" assembler:nil error:&err];
    
    TDEqualObjects(@"[27]3/^/3^", [res description]);
}

- (void)testAddMultPowEnableActions {
    _parser.enableActions = YES;
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"1+2*3^5+4" assembler:nil error:&err];
    
    TDEqualObjects(@"[491]1/+/2/*/3/^/5/+/4^", [res description]);
}


@end
