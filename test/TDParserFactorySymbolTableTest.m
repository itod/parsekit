//
//  TDParserFactorySymbolTableTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "TDParserFactorySymbolTableTest.h"
#import "PKParserFactory.h"
#import "PKAST.h"

@interface PKParserFactory ()
- (NSDictionary *)symbolTableFromGrammar:(NSString *)g error:(NSError **)outError;
@end

@interface PKPattern ()
@property (nonatomic, assign) PKPatternOptions options;
@end

@interface PKDelimitedString ()
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@end

@interface TDParserFactorySymbolTableTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@end

@implementation TDParserFactorySymbolTableTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
}


- (void)tearDown {
    self.factory = nil;
}


- (void)testDelimitState {
    //NSString *g = @"@delimitState='[';@delimitedString='[' ']' nil; start=%{'[', ']'};";
    NSString *g = @"@symbols='<?=';@delimitState='<';@delimitedString='<?=' '>' nil;start=%{'<?=', '>'};";
    
    PKCollectionParser *start = (id)[_factory parserFromGrammar:g assembler:nil error:nil];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKDelimitedString class]]);
    
    NSString *input = @"<?= foobar >";
    PKTokenizer *t = start.tokenizer;
    TDNotNil(t);
    t.string = input;
    PKAssembly *a = [PKTokenAssembly assemblyWithTokenizer:t];
    a = [start bestMatchFor:a];
    TDEqualObjects(@"[<?= foobar >]<?= foobar >^", [a description]);
}

    
- (void)testWordAST {
    NSString *g = @"start=foo;foo=Word;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    TDTrue(1 == [start.subparsers count]);
    
    PKParser *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKWord class]]);
    
    TDEquals(start.subparsers[0], foo);
    
    TDNil(foo.assembler);
    TDEquals((SEL)NULL, foo.assemblerSelector);
    TDNil(foo.assemblerBlock);
    TDNil(foo.preassembler);
    TDEquals((SEL)NULL, foo.preassemblerSelector);
    TDNil(foo.preassemblerBlock);
    
    NSString *input = @"hello";
    PKAssembly *a = [PKTokenAssembly assemblyWithString:input];
    PKAssembly *res = [start completeMatchFor:a];
    
    TDEqualObjects(@"[hello]hello^", [res description]);
}


- (void)testLiteralStringAST {
    NSString *g = @"start=foo;foo='bar';";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    TDTrue(1 == [start.subparsers count]);
    
    PKParser *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKLiteral class]]);
    
    TDEquals(start.subparsers[0], foo);
    
    TDNil(foo.assembler);
    TDEquals((SEL)NULL, foo.assemblerSelector);
    TDNil(foo.assemblerBlock);
    TDNil(foo.preassembler);
    TDEquals((SEL)NULL, foo.preassemblerSelector);
    TDNil(foo.preassemblerBlock);
    
    NSString *input = @"bar";
    PKAssembly *a = [PKTokenAssembly assemblyWithString:input];
    PKAssembly *res = [start completeMatchFor:a];
    
    TDEqualObjects(@"[bar]bar^", [res description]);
}


- (void)testEmptyAST {
    NSString *g = @"start=foo;foo=Empty;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKParser *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKEmpty class]]);
    
    TDEquals(start.subparsers[0], foo);
    
    TDNil(foo.assembler);
    TDEquals((SEL)NULL, foo.assemblerSelector);
    TDNil(foo.assemblerBlock);
    TDNil(foo.preassembler);
    TDEquals((SEL)NULL, foo.preassemblerSelector);
    TDNil(foo.preassemblerBlock);
}


- (void)testAlternationAST {
    NSString *g = @"start=foo;foo=Word|Number;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKAlternation *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKAlternation class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKNumber class]]);
}


- (void)testSequenceAST {
    NSString *g = @"start=foo;foo=(Word|Number) Symbol;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKAlternation class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKSymbol class]]);
}


- (void)testTrackAST {
    NSString *g = @"start=foo;foo=[Word Number] Symbol;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKTrack class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKSymbol class]]);
    
    PKTrack *tr = foo.subparsers[0];
    TDTrue([tr.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([tr.subparsers[1] isKindOfClass:[PKNumber class]]);
}


- (void)testRepetitionAST {
    NSString *g = @"start=foo;foo=Word* Symbol;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKRepetition class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKSymbol class]]);
}


- (void)testNegationAST {
    NSString *g = @"start=foo;foo=~Word;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (~ Word)))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKNegation *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKNegation class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparser isKindOfClass:[PKWord class]]);
}


- (void)testDifferenceAST {
    NSString *g = @"start=foo;foo=Word - 'foo';";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (- Word 'foo')))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKDifference *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKDifference class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparser isKindOfClass:[PKWord class]]);
    TDTrue([foo.minus isKindOfClass:[PKLiteral class]]);
}


- (void)testIntersectionAST {
    NSString *g = @"start=foo;foo=Word & 'foo';";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (& Word 'foo')))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKIntersection *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKIntersection class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKLiteral class]]);
}


- (void)testOptionalAST {
    NSString *g = @"start=foo;foo=Word?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (? Word)))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKAlternation *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKAlternation class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKEmpty class]]);
}


- (void)testOptionalAST2 {
    NSString *g = @"start=foo;foo=Symbol Word?;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. Symbol (? Word))))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKSymbol class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKAlternation class]]);
    
    PKAlternation *alt = foo.subparsers[1];
    TDTrue([alt.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([alt.subparsers[1] isKindOfClass:[PKEmpty class]]);
}


- (void)testMultiAST1 {
    NSString *g = @"start=foo;foo=Word+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (+ Word)))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKRepetition class]]);
    
    PKRepetition *rep = foo.subparsers[1];
    TDTrue([rep.subparser isKindOfClass:[PKWord class]]);
}


- (void)testMultiAST2 {
    NSString *g = @"start=foo;foo=Symbol Word+;";
    
    NSError *err = nil;
    PKAST *rootNode = [_factory ASTFromGrammar:g error:&err];
    TDNotNil(rootNode);
    TDEqualObjects(@"(ROOT ($start #foo) ($foo (. Symbol (+ Word))))", [rootNode treeDescription]);
    
    err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKSymbol class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKSequence class]]);
    
    PKSequence *seq = foo.subparsers[1];
    TDTrue([seq.subparsers[0] isKindOfClass:[PKWord class]]);
    TDTrue([seq.subparsers[1] isKindOfClass:[PKRepetition class]]);
    
    PKRepetition *rep = seq.subparsers[1];
    TDTrue([rep.subparser isKindOfClass:[PKWord class]]);
}


- (void)testLiteralAST1 {
    NSString *g = @"start='bar';";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKLiteral *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKLiteral class]]);
    
    TDEqualObjects(@"bar", start.string);
}


- (void)testLiteralAST2 {
    NSString *g = @"start=foo;foo='bar' Symbol;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKSequence *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKSequence class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDTrue([foo.subparsers[0] isKindOfClass:[PKLiteral class]]);
    TDTrue([foo.subparsers[1] isKindOfClass:[PKSymbol class]]);
    
    PKLiteral *lit = foo.subparsers[0];
    TDEqualObjects(@"bar", lit.string);
}


- (void)testDelimitedAST1 {
    NSString *g = @"start=foo;foo=%{'<', '>'};";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKDelimitedString *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKDelimitedString class]]);
        
    TDEquals(start.subparsers[0], foo);
    TDEqualObjects(@"<", foo.startMarker);
    TDEqualObjects(@">", foo.endMarker);
}


- (void)testPatternAST1 {
    NSString *g = @"start=foo;foo=/\\w+/i;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKPattern *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKPattern class]]);
    
    TDEquals(start.subparsers[0], foo);
    TDEqualObjects(@"\\w+", foo.string);
    TDTrue(foo.options & PKPatternOptionsIgnoreCase);
}


- (void)testWhitespaceAST1 {
    NSString *g = @"start=foo;foo=S;";
    
    NSError *err = nil;
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:&err];
    TDNotNil(symTab);
    
    PKCollectionParser *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKSequence class]]);
    
    PKWhitespace *foo = symTab[@"foo"];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKWhitespace class]]);
}


- (void)parser:(PKParser *)p didMatchFoo:(PKAssembly *)a {}
- (void)testDefaultAssemblerSetting {
    NSString *g = @"start=foo;foo=Word;";
    
    NSError *err = nil;
    PKCollectionParser *start = (id)[_factory parserFromGrammar:g assembler:self error:&err];
    TDNotNil(start);
    
    PKParser *foo = start.subparsers[0];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKWord class]]);
    
    TDEquals(start.subparsers[0], foo);
    
    TDEqualObjects(self, foo.assembler);
    TDEquals(@selector(parser:didMatchFoo:), foo.assemblerSelector);
    TDNil(foo.assemblerBlock);
    TDNil(foo.preassembler);
    TDEquals((SEL)NULL, foo.preassemblerSelector);
    TDNil(foo.preassemblerBlock);
}


- (void)parser:(PKParser *)p willMatchFoo:(PKAssembly *)a {}
- (void)testDefaultPreassemblerSetting {
    NSString *g = @"start=foo;foo=Word;";
    
    NSError *err = nil;
    PKCollectionParser *start = (id)[_factory parserFromGrammar:g assembler:self preassembler:self error:&err];
    TDNotNil(start);
    
    PKParser *foo = start.subparsers[0];
    TDNotNil(foo);
    TDTrue([foo isKindOfClass:[PKWord class]]);
    
    TDEquals(start.subparsers[0], foo);
    
    TDEqualObjects(self, foo.assembler);
    TDEquals(@selector(parser:didMatchFoo:), foo.assemblerSelector);
    TDNil(foo.assemblerBlock);
    TDEqualObjects(self, foo.preassembler);
    TDEquals(@selector(parser:willMatchFoo:), foo.preassemblerSelector);
    TDNil(foo.preassemblerBlock);
}

@end
