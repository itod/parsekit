
//
//  OptionalParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "OptionalParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "OptionalParser.h"

@interface OptionalParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) OptionalParser *parser;
@end

@implementation OptionalParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"optional" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"Optional";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[OptionalParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/OptionalParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/OptionalParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testFoo {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo bar" assembler:nil error:&err];
    
    TDEqualObjects(@"[foo, bar]foo/bar^", [res description]);
}

- (void)testFoo2 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo bar bar foo bar" assembler:nil error:&err];
    
    TDEqualObjects(@"[foo, bar, bar, foo, bar]foo/bar/bar/foo/bar^", [res description]);
}

- (void)testFoo3 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo bar bar foo bar bar foo bar" assembler:nil error:&err];

    // junk at end
    TDNil(res);
}

- (void)testIncompleteSequence {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo bar bar foo" assembler:nil error:&err];
    
    TDNil(res);
    //TDEqualObjects(@"[foo, bar, bar, foo]foo/bar/bar/foo^", [res description]);
}

@end
