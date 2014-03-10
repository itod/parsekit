
//
//  GreedyFailureNestedParserTest.m
//  JavaScript
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "GreedyFailureNestedParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "GreedyFailureNestedParser.h"

@interface GreedyFailureNestedParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) GreedyFailureNestedParser *parser;
@property (nonatomic, retain) id mock;
@end

@implementation GreedyFailureNestedParserTest

- (void)parser:(PEGParser *)p didFailToMatch:(PKAssembly *)a {}

- (void)parser:(PEGParser *)p didMatchLcurly:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchRcurly:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchName:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchColon:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchValue:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchComma:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchStructure:(PKAssembly *)a {}
- (void)parser:(PEGParser *)p didMatchStructs:(PKAssembly *)a {}

- (void)dealloc {
    self.factory = nil;
    self.root = nil;
    self.visitor = nil;
    self.parser = nil;
    self.mock = nil;
    [super dealloc];
}


- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"greedy_failure_nested" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"GreedyFailureNested";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorAll;
    _visitor.enableAutomaticErrorRecovery = YES;
    _visitor.enableMemoization = NO;
    
    [_root visit:_visitor];
    
#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/GreedyFailureNestedParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/GreedyFailureNestedParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif

    self.parser = [[[GreedyFailureNestedParser alloc] init] autorelease];
    _parser.enableAutomaticErrorRecovery = YES;

    self.mock = [OCMockObject mockForClass:[GreedyFailureNestedParserTest class]];
    
    // return YES to -respondsToSelector:
    [[[_mock stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] respondsToSelector:(SEL)OCMOCK_ANY];
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testCompleteStruct {
    
    [[_mock expect] parser:_parser didMatchLcurly:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchName:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchColon:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchValue:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchRcurly:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStructure:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDTrue(0); // should never reach
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':bar}" assembler:_mock error:&err];
    TDEqualObjects(@"[{, 'foo', :, bar, }]{/'foo'/:/bar/}^", [res description]);
    
    VERIFY();
}

- (void)testIncompleteStruct {
    
    [[_mock expect] parser:_parser didMatchLcurly:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchName:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchColon:OCMOCK_ANY];
    [[_mock expect] parser:_parser didMatchValue:OCMOCK_ANY];

//    [[_mock expect] parser:_parser didMatchRcurly:OCMOCK_ANY];
//    [[_mock expect] parser:_parser didMatchStructure:OCMOCK_ANY];

    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[{, 'foo', :, bar]{/'foo'/:/bar^", [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':bar" assembler:_mock error:&err];
    TDEqualObjects(@"[{, 'foo', :, bar]{/'foo'/:/bar^", [res description]);
    
    VERIFY();
}

- (void)testIncompleteStruct1 {
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[{]{^", [a description]);
        [a pop]; // pop {
        
    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
    
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"['foo']{/'foo'^", [a description]);
        [a pop]; // pop 'foo'
        
    }] parser:_parser didMatchName:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[:]{/'foo'/:^", [a description]);
        [a pop]; // pop :
        
    }] parser:_parser didMatchColon:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[bar]{/'foo'/:/bar^", [a description]);
        [a pop]; // pop bar
        
    }] parser:_parser didMatchValue:OCMOCK_ANY];
    
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[]{/'foo'/:/bar^", [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':bar" assembler:_mock error:&err];
    TDEqualObjects(@"[]{/'foo'/:/bar^", [res description]);
    
    VERIFY();
}

//- (void)testIncompleteStruct1_1 {
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(@"[{]{^", [a description]);
//        [a pop]; // pop {
//        
//    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
//    
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(@"['foo']{/'foo'^", [a description]);
//        [a pop]; // pop 'foo'
//        
//    }] parser:_parser didMatchName:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(@"[:]{/'foo'/:^", [a description]);
//        [a pop]; // pop :
//        
//    }] parser:_parser didMatchColon:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(@"[bar]{/'foo'/:/bar^", [a description]);
//        [a pop]; // pop bar
//        
//    }] parser:_parser didMatchValue:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(@"[,]{/'foo'/:/bar/,^", [a description]);
//        [a pop]; // pop ,
//        
//    }] parser:_parser didMatchComma:OCMOCK_ANY];
//    
//    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
//    
//    [[[_mock stub] andDo:^(NSInvocation *invoc) {
//        PKAssembly *a = nil;
//        [invoc getArgument:&a atIndex:3];
//        NSLog(@"%@", a);
//        
//        TDEqualObjects(@"[]{/'foo'/:/bar/,^", [a description]);
//        NSLog(@"");
//        
//    }] parser:_parser didFailToMatch:OCMOCK_ANY];
//    
//    NSError *err = nil;
//    PKAssembly *res = [_parser parseString:@"{'foo':bar," assembler:_mock error:&err];
//    TDEqualObjects(@"[]{/'foo'/:/bar/,^", [res description]);
//    
//    VERIFY();
//}

- (void)testIncompleteStruct2 {
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[{]{^", [a description]);
        [a pop]; // pop {
        
    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
    
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"['foo']{/'foo'^", [a description]);
        [a pop]; // pop 'foo'
        
    }] parser:_parser didMatchName:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[:]{/'foo'/:^", [a description]);
        [a pop]; // pop :
        
    }] parser:_parser didMatchColon:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[]{/'foo'/:^", [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

//    [[_mock expect] parser:_parser didMatchValue:OCMOCK_ANY];

    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[}]{/'foo'/:/}^", [a description]);
        [a pop]; // pop }
        
    }] parser:_parser didMatchRcurly:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[]{/'foo'/:/}^", [a description]);
        
    }] parser:_parser didMatchStructure:OCMOCK_ANY];
    
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];

    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{'foo':}" assembler:_mock error:&err];
    TDEqualObjects(@"[]{/'foo'/:/}^", [res description]);
    
    VERIFY();
}


- (void)testIncompleteStruct3 {
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[{]{^", [a description]);
        [a pop]; // pop {
        
    }] parser:_parser didMatchLcurly:OCMOCK_ANY];
    
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[]{^", [a description]);
        
    }] parser:_parser didFailToMatch:OCMOCK_ANY];

//    [[_mock expect] parser:_parser didMatchName:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[:]{/:^", [a description]);
        [a pop]; // pop :
        
    }] parser:_parser didMatchColon:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[bar]{/:/bar^", [a description]);
        [a pop]; // pop bar
        
    }] parser:_parser didMatchValue:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[}]{/:/bar/}^", [a description]);
        [a pop]; // pop }
        
    }] parser:_parser didMatchRcurly:OCMOCK_ANY];
    
    [[[_mock stub] andDo:^(NSInvocation *invoc) {
        PKAssembly *a = nil;
        [invoc getArgument:&a atIndex:3];
        //NSLog(@"%@", a);
        
        TDEqualObjects(@"[]{/:/bar/}^", [a description]);
        
    }] parser:_parser didMatchStructure:OCMOCK_ANY];
    
    [[_mock expect] parser:_parser didMatchStructs:OCMOCK_ANY];
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"{:bar}" assembler:_mock error:&err];
    TDEqualObjects(@"[]{/:/bar/}^", [res description]);
    
    VERIFY();
}

@end
