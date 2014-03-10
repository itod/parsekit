//
//  MethodsFactoredParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "MethodsFactoredParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "MethodsFactoredParser.h"

@interface MethodsFactoredParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) MethodsFactoredParser *parser;
@end

@implementation MethodsFactoredParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"methods_factored" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"MethodsFactored";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[MethodsFactoredParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/MethodsFactoredParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/MethodsFactoredParser.m", getenv("PWD")] stringByExpandingTildeInPath];
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
    
    TDEqualObjects(@"[int, add, (, int, a, ), ;]int/add/(/int/a/)/;^", [res description]);
}


- (void)testAddDef {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"int add(int a) { }" assembler:nil error:&err];
    
    TDEqualObjects(@"[int, add, (, int, a, ), {, }]int/add/(/int/a/)/{/}^", [res description]);
}

@end
