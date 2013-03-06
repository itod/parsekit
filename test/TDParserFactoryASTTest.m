//
//  TDParserFactoryASTTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/3/12.
//
//

#import "TDParserFactoryASTTest.h"
#import "TDParserFactory.h"
#import "PKAST.h"

@interface TDParserFactoryASTTest ()
@property (nonatomic, retain) TDParserFactory *factory;
@end

@implementation TDParserFactoryASTTest

- (void)setUp {
    self.factory = [TDParserFactory factory];
}


- (void)tearDown {
    self.factory = nil;
}


- (void)testAlternationAST {
    NSString *g = @"@start=foo;foo=bar;bar=baz|bat;baz=Word;bat=Number;";

    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (bar (| (baz Word) (bat Number)))))");    
}


- (void)testSequenceAST {
    NSString *g = @"@start=foo;foo=QuotedString Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo QuotedString Number))");
}


- (void)testSubExprSequenceAST {
    NSString *g = @"@start=foo;foo=(QuotedString Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (SEQ QuotedString Number)))");

    g = @"@start=foo;foo=( QuotedString Number );";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (SEQ QuotedString Number)))");

    g = @"@start=foo; foo = ( QuotedString Number );";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (SEQ QuotedString Number)))");
}


- (void)testDifferenceAST {
    NSString *g = @"@start=foo;foo=Any-Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (- Any Word)))");

    g = @"@start=foo;foo=Any - Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (- Any Word)))");

    g = @"@start=foo;foo=Any -Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (- Any Word)))");

    g = @"@start=foo;foo=Any- Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (- Any Word)))");
}


- (void)testIntersectionAST {
    NSString *g = @"@start=foo;foo=Word&LowercaseWord;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (& Word LowercaseWord)))");
    
    g = @"@start=foo;foo=Word & LowercaseWord;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (& Word LowercaseWord)))");
    
    g = @"@start=foo;foo=Word &LowercaseWord;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (& Word LowercaseWord)))");
    
    g = @"@start=foo;foo=Word& LowercaseWord;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (& Word LowercaseWord)))");
}


- (void)testStarAST {
    NSString *g = @"@start=foo;foo=Word*;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (* Word)))");
    
    g = @"@start=foo;foo=Word *;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (* Word)))");
}


- (void)testQuestionAST {
    NSString *g = @"@start=foo;foo=Word?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (? Word)))");
    
    g = @"@start=foo;foo=Word ?;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (? Word)))");
}


- (void)testPlusAST {
    NSString *g = @"@start=foo;foo=Word+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (+ Word)))");
    
    g = @"@start=foo;foo=Word +;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (+ Word)))");
}


- (void)testNegationAST {
    NSString *g = @"@start=foo;foo=~Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (~ Word)))");
    
    g = @"@start=foo;foo= ~Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (~ Word)))");

    g = @"@start=foo;foo= ~ Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo (~ Word)))");
}


- (void)testPatternAST {
    NSString *g = @"@start=foo;foo=/\\w/;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo /\\w/))");
    
    g = @"@start=foo;foo = /\\w/;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects([rootNode treeDescription], @"(@start (foo /\\w/))");
}

@end
