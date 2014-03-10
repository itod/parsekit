//
//  MethodsParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "MethodsParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "MethodsParser.h"

@interface MethodsParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) MethodsParser *parser;
@end

@implementation MethodsParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"methods" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"Methods";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[MethodsParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/MethodsParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/MethodsParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}


- (void)tearDown {
    self.factory = nil;
}


- (void)testAddDecl {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"int add(int a);" assembler:nil error:&err];
    
    //TDEqualObjects(@"[int, add, (, int, a, ), ;]int/add/(/int/a/)/;^", [res description]);
    TDNil(res); // hard coded predicate
}

- (void)testAddDef {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"int add(int a) { }" assembler:nil error:&err];
    
    TDEqualObjects(@"[int, add, (, int, a, ), {, }]int/add/(/int/a/)/{/}^", [res description]);
}

- (void)testNoArgDecl {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"int add();" assembler:nil error:&err];
    
    //TDEqualObjects(@"[int, add, (, ), ;]int/add/(/)/;^", [res description]);
    TDNil(res); // hard coded predicate
}

- (void)testNoArgDef {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"int add() { }" assembler:nil error:&err];
    
    TDEqualObjects(@"[int, add, (, ), {, }]int/add/(/)/{/}^", [res description]);
}

@end
