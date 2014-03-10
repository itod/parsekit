
//
//  GreedParserTest.m
//  Greed
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "GreedParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "GreedParser.h"

@interface GreedParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) GreedParser *parser;
@end

@implementation GreedParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"greed" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"Greed";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[GreedParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/GreedParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/GreedParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testACACA {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"a C a C a" assembler:nil error:&err];
    
    //TDEqualObjects(@"[a, C, a]a/C/a^", [res description]);
    TDNil(res);
}

- (void)testACA {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"a C a" assembler:nil error:&err];
    
    
    //TDEqualObjects(@"[a, C, a]a/C/a^", [res description]);
    TDNil(res);
}

- (void)testBCBCB {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"b C b C b" assembler:nil error:&err];
    
    //TDEqualObjects(@"[b, C, b]b/C/b^", [res description]);
    TDNil(res);
}

- (void)testBCB {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"b C b" assembler:nil error:&err];
    
    //TDEqualObjects(@"[b, C, b]b/C/b^", [res description]);
    TDNil(res);
}

@end
