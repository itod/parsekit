//
//  RecoveryResyncSetTest.m
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "RecoveryResyncSetTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "ElementAssignParser.h"

@interface RecoveryResyncSetTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) ElementAssignParser *parser;
@end

@implementation RecoveryResyncSetTest

- (void)setUp {
    self.parser = [[[ElementAssignParser alloc] init] autorelease];
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testCorrectExpr {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    input = @"[3];";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 3, ;][/3/]/;^", [res description]);
}

- (void)testMissingElement {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[];";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, ;][/]/;^", [res description]);
}

- (void)testMissingRbracketInAssign {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    // not sure if this uses single token insertion or resync ??
    
    input = @"[=[2].";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, =, [, 2, .][/=/[/2/]/.^", [res description]);
}

- (void)testMissingLbracketInAssign {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"1]=[2].";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[1, ], =, [, 2, .]1/]/=/[/2/]/.^", [res description]);
}

- (void)testJunkBeforeSemi {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[1]foobar baz bat ;";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 1, foobar, baz, bat, ;][/1/]/foobar/baz/bat/;^", [res description]);
}

- (void)testJunkBeforeSemi2 {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[1]foobar baz ;[2];";
    res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[[, 1, foobar, baz, ;, [, 2, ;][/1/]/foobar/baz/;/[/2/]/;^", [res description]);
}


- (void)parser:(PEGParser *)p didMatchStat:(PKAssembly *)a {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    [a push:@"flag"];
}
- (void)testStatments {
    NSError *err = nil;
    PKAssembly *res = nil;
    NSString *input = nil;
    
    _parser.enableAutomaticErrorRecovery = YES;
    
    input = @"[1];[2";
    res = [_parser parseString:input assembler:self error:&err];
    TDEqualObjects(@"[[, 1, ;, flag, [, 2][/1/]/;/[/2^", [res description]);
    
    input = @"[1];[2;[3];";
    res = [_parser parseString:input assembler:self error:&err];
    TDEqualObjects(@"[[, 1, ;, flag, [, 2, ;, flag, [, 3, ;, flag][/1/]/;/[/2/;/[/3/]/;^", [res description]);
    
    input = @"[1];[2,;[3];";
    res = [_parser parseString:input assembler:self error:&err];
    TDEqualObjects(@"[[, 1, ;, flag, [, 2, ,, ;, flag, [, 3, ;, flag][/1/]/;/[/2/,/;/[/3/]/;^", [res description]);
    
    input = @"[1];[;[3];";
    res = [_parser parseString:input assembler:self error:&err];
    TDEqualObjects(@"[[, 1, ;, flag, [, ;, flag, [, 3, ;, flag][/1/]/;/[/;/[/3/]/;^", [res description]);
    
    input = @"[1];;[3];";
    res = [_parser parseString:input assembler:self error:&err];
    TDEqualObjects(@"[[, 1, ;, flag, ;, flag, [, 3, ;, flag][/1/]/;/;/[/3/]/;^", [res description]);
}

@end
