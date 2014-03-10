//
//  TDParserFactoryASTTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/3/12.
//
//

#import "TDParserFactoryASTTest.h"
#import "PKParserFactory.h"
#import "PKAST.h"

@interface PKParserFactory ()
@property (nonatomic, retain, readonly) NSDictionary *directiveTab;
@end

@interface TDParserFactoryASTTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@end

@implementation TDParserFactoryASTTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
}


- (void)tearDown {
    self.factory = nil;
}


- (void)testSemanticPredicateNumber {
    NSString *g = @"start=foo;foo= {YES}? Number;";
    //NSLog(@"%@", g);
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo Number))", [rootNode treeDescription]);
}


- (void)testSemanticPredicateAlt {
    NSString *g = @"start=foo;foo= {YES}? Number | {NO}? Word;";
    //NSLog(@"%@", g);
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Number Word)))", [rootNode treeDescription]);
}


- (void)testAction {
    NSString *g = @"start=foo;foo=Word {NSLog(@\"hi\");};";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo Word))", [rootNode treeDescription]);
}


- (void)testAlternationAST2 {
    NSString *g = @"start=foo;foo=Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo Word))", [rootNode treeDescription]);
}


- (void)testAlternationAST2_1 {
    NSString *g = @"start=foo;foo=Word|Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word Number)))", [rootNode treeDescription]);
}


- (void)testAlternationAST2_1_0 {
    NSString *g = @"start=foo;foo=Word|Number Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word (. Number Symbol))))", [rootNode treeDescription]);
}


- (void)testAlternationAST2_1_1 {
    NSString *g = @"start=foo;foo=Word Number|Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| (. Word Number) Symbol)))", [rootNode treeDescription]);
}


- (void)testAlternationAST2_2 {
    NSString *g = @"start=foo;foo=Word|Number Symbol QuotedString;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word (. Number Symbol QuotedString))))", [rootNode treeDescription]);
}


- (void)testSubExpr {
    NSString *g = @"start=foo;foo=(Word Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. Word Number)))", [rootNode treeDescription]);
}


- (void)testTrackExpr {
    NSString *g = @"start=foo;foo=[Word Number];";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo ([ Word Number)))", [rootNode treeDescription]);
}


- (void)testTrackExpr2 {
    NSString *g = @"start=foo;foo=[Word];";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo ([ Word)))", [rootNode treeDescription]);
}


- (void)testTrackExpr3 {
    NSString *g = @"start=foo;foo=[(Word|Number) Symbol];";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo ([ (| Word Number) Symbol)))", [rootNode treeDescription]);
}


- (void)testTrackExpr4 {
    NSString *g = @"start=foo;foo=[(Word Number) Symbol];";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo ([ (. Word Number) Symbol)))", [rootNode treeDescription]);
}


- (void)testSubExpr2 {
    NSString *g = @"start=foo;foo=(Word Number) Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. (. Word Number) Symbol)))", [rootNode treeDescription]);
}


- (void)testSubExpr3 {
    NSString *g = @"start=foo;foo=Symbol (Word Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. Symbol (. Word Number))))", [rootNode treeDescription]);
}


- (void)testSubExpr4 {
    NSString *g = @"start=foo;foo=(Word|Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word Number)))", [rootNode treeDescription]);
}


- (void)testSubExpr5 {
    NSString *g = @"start=foo;foo=Symbol (Word|Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. Symbol (| Word Number))))", [rootNode treeDescription]);
}


- (void)testSubExpr6 {
    NSString *g = @"start=foo;foo=(Word|Number) Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. (| Word Number) Symbol)))", [rootNode treeDescription]);
}


- (void)testSubExpr7 {
    NSString *g = @"start=foo;foo=Word|Number Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word (. Number Symbol))))", [rootNode treeDescription]);
}


- (void)testSubExpr8 {
    NSString *g = @"start=foo;foo=(Word|Number Symbol);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word (. Number Symbol))))", [rootNode treeDescription]);
}


- (void)testSubExpr9 {
    NSString *g = @"start=foo;foo=Word|(Number Symbol);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word (. Number Symbol))))", [rootNode treeDescription]);
}


- (void)testAlternationAST {
    NSString *g = @"start=foo;foo=bar;bar=baz|bat;baz=Word;bat=Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo #bar) ($bar (| #baz #bat)) ($baz Word) ($bat Number))", [rootNode treeDescription]);
}


- (void)testAlternationAST3 {
    NSString *g = @"start=foo;foo=bar|baz;bar=Word;baz=Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| #bar #baz)) ($bar Word) ($baz Number))", [rootNode treeDescription]);
}


- (void)testSequenceAST {
    NSString *g = @"start=foo;foo=QuotedString Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. QuotedString Number)))", [rootNode treeDescription]);
}


- (void)testSubExprSequenceAST {
    NSString *g = @"start=foo;foo=(QuotedString Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. QuotedString Number)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=( QuotedString Number );";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. QuotedString Number)))", [rootNode treeDescription]);
    
    g = @"start=foo; foo = ( QuotedString Number );";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. QuotedString Number)))", [rootNode treeDescription]);
}


- (void)testDifferenceAST {
    NSString *g = @"start=foo;foo=Any-Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (- Any Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=Any - Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (- Any Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=Any -Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (- Any Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=Any- Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (- Any Word)))", [rootNode treeDescription]);
}


- (void)testStarAST {
    NSString *g = @"start=foo;foo=Word*;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (* Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=Word *;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (* Word)))", [rootNode treeDescription]);
}


- (void)testQuestionAST {
    NSString *g = @"start=foo;foo=Word?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (? Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=Word ?;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (? Word)))", [rootNode treeDescription]);
}


- (void)testPlusAST {
    NSString *g = @"start=foo;foo=Word+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (+ Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo=Word +;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (+ Word)))", [rootNode treeDescription]);
}


- (void)testNegationAST {
    NSString *g = @"start=foo;foo=~Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (~ Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo= ~Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (~ Word)))", [rootNode treeDescription]);
    
    g = @"start=foo;foo= ~ Word;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (~ Word)))", [rootNode treeDescription]);
}


- (void)testPatternAST {
    NSString *g = @"start=foo;foo=/\\w/;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo /\\w/))", [rootNode treeDescription]);
    
    g = @"start=foo;foo = /\\w/;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo /\\w/))", [rootNode treeDescription]);
}


- (void)testPatternOptsAST {
    NSString *g = @"start=foo;foo=/\\w/i;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo /\\w/i))", [rootNode treeDescription]);
    
    g = @"start=foo;foo = /\\w/i;";
    
    err = nil;
    rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo /\\w/i))", [rootNode treeDescription]);
}


//- (void)testPatternMultiOptsAST {
//    NSString *g = @"start=foo;foo=/\\w/im;";
//    
//    NSError *err = nil;
//    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
//    TDNotNil(rootNode);
//    TDEqualObjects(@"(ROOT ($start #foo) ($foo /\\w/im))", [rootNode treeDescription]);
//    
//    g = @"start=foo;foo = /\\w/im;";
//    
//    err = nil;
//    rootNode = [_factory ASTFromGrammar:g error:&err];
//    TDNotNil(rootNode);
//    TDEqualObjects(@"(ROOT ($start #foo) ($foo /\\w/im))", [rootNode treeDescription]);
//}


- (void)testSimplifyAST {
    NSString *g = @"start=foo;foo=Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo Symbol))", [rootNode treeDescription]);
}


- (void)testSubExprAST {
    NSString *g = @"start = (Number)*;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (* Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST1 {
    NSString *g = @"start = Number*;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (* Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST2 {
    NSString *g = @"start = (Number)+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (+ Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST3 {
    NSString *g = @"start = Number+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (+ Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST3_1 {
    NSString *g = @"start = Word ~Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. Word (~ Number))))", [rootNode treeDescription]);
}


- (void)testSubExprAST3_2 {
    NSString *g = @"start = Number+ Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. (+ Number) Word)))", [rootNode treeDescription]);
}


- (void)testSubExprAST3_4 {
    NSString *g = @"start = Word Number+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. Word (+ Number))))", [rootNode treeDescription]);
}


- (void)testSubExprAST3_3 {
    NSString *g = @"start = Word Number?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. Word (? Number))))", [rootNode treeDescription]);
}


- (void)testSubExprAST4 {
    NSString *g = @"start = (Number)?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (? Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST5 {
    NSString *g = @"start = Number?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (? Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST6 {
    NSString *g = @"start = ~(Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (~ Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST7 {
    NSString *g = @"start = ~Number;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (~ Number)))", [rootNode treeDescription]);
}


- (void)testSubExprAST8 {
    NSString *g = @"start = ~(Word Number);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (~ (. Word Number))))", [rootNode treeDescription]);
}


- (void)testSubExprAST9 {
    NSString *g = @"start = (Word Number)+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (+ (. Word Number))))", [rootNode treeDescription]);
}


- (void)testSubExprAST10 {
    NSString *g = @"start = (Word Number)*;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (* (. Word Number))))", [rootNode treeDescription]);
}


- (void)testSubExprAST11 {
    NSString *g = @"start = (Word Number)?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (? (. Word Number))))", [rootNode treeDescription]);
}


- (void)testSeqRepAST {
    NSString *g = @"start = (Word | Number)* QuotedString;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. (* (| Word Number)) QuotedString)))", [rootNode treeDescription]);
}


- (void)testSeqRepAST2 {
    NSString *g = @"start = foo; foo=(Word | Number)* QuotedString;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. (* (| Word Number)) QuotedString)))", [rootNode treeDescription]);
}


- (void)testSeqRepAST3 {
    NSString *g = @"start = foo; foo=(Word | Number)* QuotedString Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. (* (| Word Number)) QuotedString Symbol)))", [rootNode treeDescription]);
}


- (void)testAltPrecedenceAST {
    NSString *g = @"start = foo; foo=Word | Number Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word (. Number Symbol))))", [rootNode treeDescription]);
}


- (void)testAltPrecedenceAST2 {
    NSString *g = @"start = foo; foo=Word Number | Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| (. Word Number) Symbol)))", [rootNode treeDescription]);
}


- (void)testLiteral {
    NSString *g = @"start = '$' '%';";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. '$' '%')))", [rootNode treeDescription]);
}


- (void)testLiteral2 {
    NSString *g = @"start = ('$' '%')+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (+ (. '$' '%'))))", [rootNode treeDescription]);
}


- (void)testLiteral3 {
    NSString *g = @"start = ((Word | Number)* | ('$' '%')) QuotedString+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. (| (* (| Word Number)) (. '$' '%')) (+ QuotedString))))", [rootNode treeDescription]);
}


- (void)testLiteral3_1 {
    NSString *g = @"start = Word QuotedString+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. Word (+ QuotedString))))", [rootNode treeDescription]);
}


- (void)testLiteral6 {
    NSString *g = @"start = QuotedString+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (+ QuotedString)))", [rootNode treeDescription]);
}


- (void)testLiteral4 {
    NSString *g = @"start = ((Word | Number)* | ('$' '%')+);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (| (* (| Word Number)) (+ (. '$' '%')))))", [rootNode treeDescription]);
}


- (void)testLiteral5 {
    NSString *g = @"start = ((Word | Number)* | ('$' '%')+) QuotedString;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (. (| (* (| Word Number)) (+ (. '$' '%'))) QuotedString)))", [rootNode treeDescription]);
}


- (void)testDelimited {
    NSString *g = @"start=%{'<', '>'};";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start %{'<', '>'}))", [rootNode treeDescription]);
}


- (void)testDelimited2 {
    NSString *g = @"start=foo;foo=%{'<', '>'};";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo %{'<', '>'}))", [rootNode treeDescription]);
}


- (void)testWhitespace {
    NSString *g = @"start=S;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start S))", [rootNode treeDescription]);
}


- (void)testWhitespaceRep {
    NSString *g = @"start=S*;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start (* S)))", [rootNode treeDescription]);
}


//
//- (void)testSepcificConstantSymbol {
//    NSString *g = @"start=Symbol('%');";
//    
//    NSError *err = nil;
//    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
//    
//    TDNotNil(rootNode);
//    TDEqualObjects(@"(ROOT ($start Symbol('%')))", [rootNode treeDescription]);
//}
//
//
//- (void)testSepcificConstantWord {
//    NSString *g = @"start=Word('foo');";
//    
//    NSError *err = nil;
//    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
//    
//    TDNotNil(rootNode);
//    TDEqualObjects(@"(ROOT ($start Word('foo')))", [rootNode treeDescription]);
//}
//
//
- (void)testDirective {
    
    // TODO
    NSString *g = @"@wordState='@';start=Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start Word))", [rootNode treeDescription]);
    
    NSDictionary *tab = _factory.directiveTab;
    NSArray *toks = tab[@"@wordState"];
    TDEquals((NSUInteger)1, [toks count]);
    
    PKToken *tok = [toks lastObject];
    TDTrue(tok.isQuotedString);
    TDEqualObjects(@"'@'", tok.stringValue);
}


- (void)testMultiAlternationAST0 {
    NSString *g = @"start=foo;foo=Word|Number|Symbol;"; // problem????
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Word Number Symbol)))", [rootNode treeDescription]);
}


- (void)testMultiAlternationAST1 {
    NSString *g = @"start=foo;foo=QuotedString Word|Number|Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| (. QuotedString Word) Number Symbol)))", [rootNode treeDescription]);
}


- (void)testMultiAlternationAST2 {
    NSString *g = @"start=foo;foo=Number|QuotedString Word|Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| Number (. QuotedString Word) Symbol)))", [rootNode treeDescription]);
}


- (void)testMultiAlternationAST3 {
    NSString *g = @"start=foo;foo=QuotedString|Number|(Word Symbol);";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| QuotedString Number (. Word Symbol))))", [rootNode treeDescription]);
}


- (void)testMultiAlternationAST4 {
    NSString *g = @"start=foo;foo=QuotedString|Number|Word Symbol;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (| QuotedString Number (. Word Symbol))))", [rootNode treeDescription]);
}

@end
