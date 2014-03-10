
//
//  JSONParserTest.m
//  JSON
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "JSONParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "JSONParser.h"

@interface JSONParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) JSONParser *parser;
@end

@implementation JSONParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"json_with_comments" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"JSON";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorTerminals;
    _visitor.enableMemoization = NO;
    [_root visit:_visitor];
#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/JSONParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/JSONParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif

    self.parser = [[[JSONParser alloc] init] autorelease];
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testDict {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;

    input = @"{'foo':'bar'}";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[{, 'foo', :, 'bar', }]{/'foo'/:/'bar'/}^", [res description]);
}

- (void)testDict1 {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"{'foo':{}}";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[{, 'foo', :, {, }, }]{/'foo'/:/{/}/}^", [res description]);
}

- (void)testDict2 {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"{'foo':{'bar':[]}}";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[{, 'foo', :, {, 'bar', :, [, ], }, }]{/'foo'/:/{/'bar'/:/[/]/}/}^", [res description]);
}

- (void)testArray {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"['foo', true, null]";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 'foo', ,,  , true, ,,  , null, ]][/'foo'/,/ /true/,/ /null/]^", [res description]);
}

- (void)testArray1 {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"[[]]";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, [, ], ]][/[/]/]^", [res description]);
}

- (void)testArray2 {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"[[[1]]]";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, [, [, 1, ], ], ]][/[/[/1/]/]/]^", [res description]);
}

@end
