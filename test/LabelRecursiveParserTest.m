
//
//  LabelRecursiveParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "LabelRecursiveParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "LabelRecursiveParser.h"

@interface LabelRecursiveParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) LabelRecursiveParser *parser;
@end

@implementation LabelRecursiveParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"label_recursive" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"LabelRecursive";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    [_root visit:_visitor];
    
    self.parser = [[[LabelRecursiveParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/LabelRecursiveParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/LabelRecursiveParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testAlt1 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo: bar = 1" assembler:nil error:&err];
    
    TDEqualObjects(nil, res); // TAIL RECURSION NOT SUPPORTED
    
    //TDEqualObjects(@"[foo, :, bar, =, 1]foo/:/bar/=/1^", [res description]);
}

- (void)testAlt2 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo: return 1" assembler:nil error:&err];
    
    TDEqualObjects(@"[foo, :, return, 1]foo/:/return/1^", [res description]);
}

@end
