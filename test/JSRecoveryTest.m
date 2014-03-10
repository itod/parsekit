//
//  JSRecoveryTest.m
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "JSRecoveryTest.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "JavaScriptParser.h"
#import "JavaScriptWhitespaceParser.h"

@interface JSRecoveryTest ()
@property (nonatomic, retain) PEGParser *parser;
@property (nonatomic, retain) id mock;
@end

@implementation JSRecoveryTest

- (void)dealloc {
    self.parser = nil;
    self.mock = nil;
    [super dealloc];
}

- (void)parser:(PEGParser *)p didMatchVar:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchIdentifier:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchVariable:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchVariables:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchVarVariables:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchVariablesOrExpr:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchSemi:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchVariablesOrExprStmt:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchStmt:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchFunction:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchOpenParen:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchCloseParen:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchParamListOpt:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchFunc:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchElement:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchProgram:(PKAssembly *)a {}

- (void)parser:(PEGParser *)p didFailToMatch:(PKAssembly *)a {}

- (void)setUp {
    self.mock = [OCMockObject mockForClass:[JSRecoveryTest class]];
    
    // return YES to -respondsToSelector:
    [[[_mock stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] respondsToSelector:(SEL)OCMOCK_ANY];
}

- (void)tearDown {

}

- (void)testCorrectExpr {
    self.parser = [[[JavaScriptParser alloc] init] autorelease];

    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    [[_mock expect] parser:_parser didMatchVar:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchIdentifier:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchVariable:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchVariables:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchVarVariables:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchVariablesOrExpr:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchSemi:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStmt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchVariablesOrExprStmt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchElement:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchProgram:OCMOCK_ANY];
    
    input = @"var foo;";
    res = [_parser parseString:input assembler:_mock error:&err];
    TDEqualObjects(@"[var, foo, ;]var/foo/;^", [res description]);
    
    VERIFY();
}

- (void)testBorkedVarMissingSemi {
    self.parser = [[[JavaScriptParser alloc] init] autorelease];

    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDNotNil(a);
        TDEqualObjects(@"[var, foo]var/foo^", [a description]);
        
        [a pop]; // var
        [a pop]; // foo
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
          PKAssembly *a = nil;
          [invoc getArgument:&a atIndex:3];
          
          TDNotNil(a);
          TDEqualObjects(@"[]var/foo^", [a description]);
    }] parser:_parser didMatchProgram:OCMOCK_ANY];
        
    input = @"var foo";
    res = [_parser parseString:input assembler:_mock error:&err];
    TDEqualObjects(@"[]var/foo^", [res description]);
    
    VERIFY();
}

- (void)testMissingVarIdentifier {
    self.parser = [[[JavaScriptParser alloc] init] autorelease];

    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDNotNil(a);
        TDEqualObjects(@"[1, -]1/-^", [a description]);
        
        [a pop]; // `-`
        [a pop]; // 1
    }] parser:_parser didFailToMatch:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchSemi:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStmt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchElement:OCMOCK_ANY];

    [[_mock expect] parser:_parser didMatchVariablesOrExpr:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchSemi:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchVariablesOrExprStmt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStmt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchElement:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchProgram:OCMOCK_ANY];
    
    input = @"1-;;";
    res = [_parser parseString:input assembler:_mock error:&err];
    TDEqualObjects(@"[;, ;]1/-/;/;^", [res description]);
    
    VERIFY();
}

- (void)testBorkedFunc1 {
    self.parser = [[[JavaScriptWhitespaceParser alloc] init] autorelease];

    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDNotNil(a);
        TDEqualObjects(@"[function,  , foo, (, ), {, v]function/ /foo/(/)/{/v^", [a description]);
        
        [a pop]; // `v`
    }] parser:_parser didFailToMatch:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchFunction:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchIdentifier:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchOpenParen:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchCloseParen:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchParamListOpt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchFunc:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchElement:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchProgram:OCMOCK_ANY];
    
    input = @"function foo(){v}";
    res = [_parser parseString:input assembler:_mock error:&err];
    TDEqualObjects(@"[function,  , foo, (, ), {, }]function/ /foo/(/)/{/v/}^", [res description]);
    
    VERIFY();
}

- (void)testBorkedFunc2 {
    self.parser = [[[JavaScriptWhitespaceParser alloc] init] autorelease];

    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDNotNil(a);
        TDEqualObjects(@"[function,  , foo, (, ), {, \n\t , v, \n]function/ /foo/(/)/{/\n\t /v/\n^", [a description]);
        
        [a pop]; // trailing whitespace
        [a pop]; // `v`
        [a pop]; // leading whitespace
    }] parser:_parser didFailToMatch:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchFunction:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchIdentifier:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchOpenParen:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchCloseParen:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchParamListOpt:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchFunc:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchElement:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchProgram:OCMOCK_ANY];
    
    input = @"function foo(){\n\t v\n}";
    res = [_parser parseString:input assembler:_mock error:&err];
    TDEqualObjects(@"[function,  , foo, (, ), {, }]function/ /foo/(/)/{/\n\t /v/\n/}^", [res description]);
    
    VERIFY();
}

@end