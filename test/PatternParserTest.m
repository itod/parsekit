
//
//  PatternParserTest.m
//  Pattern
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "PatternParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "PatternParser.h"

@interface PatternParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) PatternParser *parser;
@end

@implementation PatternParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"pattern" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"Pattern";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[PatternParser alloc] init] autorelease];

//#if TD_EMIT
//    path = [[NSString stringWithFormat:@"%s/test/PatternParser.h", getenv("PWD")] stringByExpandingTildeInPath];
//    err = nil;
//    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
//        NSLog(@"%@", err);
//    }
//
//    path = [[NSString stringWithFormat:@"%s/test/PatternParser.m", getenv("PWD")] stringByExpandingTildeInPath];
//    err = nil;
//    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
//        NSLog(@"%@", err);
//    }
//#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testFoo1 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo" assembler:nil error:&err];
    
    TDEqualObjects(@"[foo]foo^", [res description]);
}

@end
