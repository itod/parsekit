
//
//  SemanticPredicateParserTest.m
//  SemanticPredicate
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "SemanticPredicateParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "SemanticPredicateParser.h"

@interface SemanticPredicateParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) SemanticPredicateParser *parser;
@end

@implementation SemanticPredicateParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"semantic_predicate" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"SemanticPredicate";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[SemanticPredicateParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/SemanticPredicateParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/SemanticPredicateParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testConst {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"const" assembler:nil error:&err];
    
    //TDEqualObjects(@"[a, C, a]a/C/a^", [res description]);
    TDNil(res);
}

- (void)testFoo {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo" assembler:nil error:&err];
    
    TDEqualObjects(@"[foo]foo^", [res description]);
}

- (void)testFooBar {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo bar" assembler:nil error:&err];
    
    TDEqualObjects(@"[foo, bar]foo/bar^", [res description]);
}

- (void)testFooBarConst {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo bar const" assembler:nil error:&err];
    
    TDNil(res);
}

- (void)testFooGotoBar {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo goto bar" assembler:nil error:&err];
    
    TDNil(res);
}

@end
