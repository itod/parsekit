//
//  TDParserFactoryParserTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "TDParserFactoryParserTest.h"
#import "PKParserFactory.h"
#import "PKAST.h"

@interface PKParserFactory ()
- (NSDictionary *)symbolTableFromGrammar:(NSString *)g error:(NSError **)outError;
@end

@interface PKDelimitedString ()
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@end

@interface TDParserFactoryParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@end

@implementation TDParserFactoryParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
}


- (void)tearDown {
    self.factory = nil;
}


- (void)testDifferenceAST {
    NSString *g = @"start=Number - '1';";
    //    NSString *g = @"start=foo foo foo? foo?;foo=Number;";
    
    NSError *err = nil;
    PKCollectionParser *p = (PKCollectionParser *)[_factory parserFromGrammar:g assembler:nil error:&err];
    
    TDNotNil(p);
    TDTrue([p isKindOfClass:[PKParser class]]);
    
    NSString *input = @"1";
    PKAssembly *a = [PKTokenAssembly assemblyWithString:input];
    a = [p completeMatchFor:a];
    
    TDNil(a);
    
    input = @"2 2";
    a = [PKTokenAssembly assemblyWithString:input];
    a = [p bestMatchFor:a];
    
    TDEqualObjects([a description], @"[2]2^2");
}


- (void)testNegationAST {
    NSString *g = @"start=~Word;";
    //    NSString *g = @"start=foo foo foo? foo?;foo=Number;";
    
    NSError *err = nil;
    PKCollectionParser *p = (PKCollectionParser *)[_factory parserFromGrammar:g assembler:nil error:&err];
    
    TDNotNil(p);
    TDTrue([p isKindOfClass:[PKParser class]]);
    
    NSString *input = @"foo";
    PKAssembly *a = [PKTokenAssembly assemblyWithString:input];
    a = [p completeMatchFor:a];
    
    TDNil(a);
    
    input = @"2 2";
    a = [PKTokenAssembly assemblyWithString:input];
    a = [p bestMatchFor:a];
    
    TDEqualObjects([a description], @"[2]2^2");
}


- (void)testDelimitAST {
    NSString *g = @"@symbols='<?=';@delimitState='<';@delimitedString='<?=' '>' nil;start=%{'<?=', '>'};";
    
    NSError *err = nil;
    PKAST *root = [_factory ASTFromGrammar:g error:nil];
    TDEqualObjects(@"(ROOT ($start %{'<?=', '>'}))", [root treeDescription]);
    
    NSDictionary *symTab = [_factory symbolTableFromGrammar:g error:nil];
    PKDelimitedString *start = symTab[symTab[@"$$"]];
    TDNotNil(start);
    TDTrue([start isKindOfClass:[PKDelimitedString class]]);
    
    TDEqualObjects(@"<?=", start.startMarker);
    TDEqualObjects(@">", start.endMarker);
    
    PKDelimitedString *p = (id)[_factory parserFromGrammar:g assembler:nil error:&err];
    
    TDNotNil(p);
    
    TDNotNil(p);
    TDTrue([p isKindOfClass:[PKDelimitedString class]]);
    
    TDEqualObjects(@"<?=", p.startMarker);
    TDEqualObjects(@">", p.endMarker);

    NSString *input = @"<?= foobar baz >";
    
    PKTokenizer *t = p.tokenizer;
    t.string = input;
    PKAssembly *a = [PKTokenAssembly assemblyWithTokenizer:t];
    
    TDEqualObjects(@"[]^<?= foobar baz >", [a description]);
    
    a = [p completeMatchFor:a];

    TDEqualObjects(@"[<?= foobar baz >]<?= foobar baz >^", [a description]);
}


- (void)testTokDirectiveAST {
    NSString *g = @"@symbols='!==';start=foo;foo=Symbol;";
    
    NSError *err = nil;
    PKCollectionParser *p = (PKCollectionParser *)[_factory parserFromGrammar:g assembler:nil error:&err];
    
    TDNotNil(p);
    TDTrue([p isKindOfClass:[PKSequence class]]);
    
    NSString *input = @"!==";
    p.tokenizer.string = input;
    PKAssembly *a = [PKTokenAssembly assemblyWithTokenizer:p.tokenizer];
    a = [p bestMatchFor:a];
    
    TDEqualObjects([a description], @"[!==]!==^");
}

@end
