
//
//  ParseKitParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "ParseKitParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "ParseKitParser.h"

@interface ParseKitParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) ParseKitParser *parser;
@end

@implementation ParseKitParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"parsekit" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"ParseKit";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.enableMemoization = NO;
    _visitor.enableHybridDFA = YES;
    _visitor.enableAutomaticErrorRecovery = NO;
    _visitor.enableARC = NO;
    [_root visit:_visitor];
    
    self.parser = [[[ParseKitParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/src/ParseKitParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/src/ParseKitParser.m", getenv("PWD")] stringByExpandingTildeInPath];

    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testFoo1 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"start=foo;foo='bar';" assembler:nil error:&err];
    
    TDEqualObjects(@"[start, =, foo, foo, =, 'bar']start/=/foo/;/foo/=/'bar'/;^", [res description]);
}

@end
