//
//  ElementParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "ElementParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "ElementParser.h"

@interface ElementParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@end

@implementation ElementParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;
    
    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"elements" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"Element";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.enableMemoization = YES;
    [_root visit:_visitor];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/ElementParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/ElementParser.m", getenv("PWD")] stringByExpandingTildeInPath];
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
    ElementParser *p = [[[ElementParser alloc] init] autorelease];
    
    NSError *err = nil;
    PKAssembly *res = [p parseString:@"[1, [2,3],4]" assembler:self error:&err];
    if (err) NSLog(@"%@", [err localizedDescription]);
    
    TDEqualObjects(@"[[, 1, [, 2, 3, 4][/1/,/[/2/,/3/]/,/4/]^", [res description]);
}


- (void)parser:(PEGParser *)p didMatchList:(PKAssembly *)a {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
}

@end
