//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "TDParserFactoryTest3.h"

@implementation TDParserFactoryTest3

- (void)setUp {
    factory = [PKParserFactory factory];
}


- (void)testOrVsAndPrecendence {
    g = @" @start ( didMatchFoo: ) = foo;\n"
    @"  foo = Word & /foo/ | Number! { 1 } ( DelimitedString ( '/' , '/' ) Symbol- '%' ) * /bar/ ;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[foo]foo^", [res description]);
}


- (void)testNegation {
    g = @"@start = ~'foo';";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"foo";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    s = @"'bar'";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar']'bar'^", [res description]);
    
    s = @"bar";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[bar]bar^", [res description]);
}


- (void)testNegateSymbol {
    g = @"@start = ~Symbol;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"1";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[1]1^", [res description]);
    
    s = @"'bar'";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"['bar']'bar'^", [res description]);
    
    s = @"bar";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDEqualObjects(@"[bar]bar^", [res description]);

    s = @"$";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
}


- (void)testNegateMore {
    g = @"@start = ~Symbol & ~Number;";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"1";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);

    s = @"$";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
}    


- (void)testNegateMore2 {
    g = @"@start = ~(Symbol|Number);";
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    
    s = @"1";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
    
    s = @"$";
    res = [lp completeMatchFor:[PKTokenAssembly assemblyWithString:s]];
    TDNil(res);
}


- (void)testNcName {
    g = @"@wordChars=':' '_'; @wordState='_';"
    @"@start = name;"
    @"ncName = name & /[^:]+/;"
    @"name = Word;";
    //        @"nameTest = '*' | ncName ':' '*' | qName;"
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    t.string = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    t.string = @"foo:bar";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo:bar]foo:bar^", [res description]);
}


- (void)testFunctionName {
    g = 
    @"@wordState = '_';"
    @"@wordChars = '_' '.' '-';"
    @"@start = functionName;"
    @"functionName = qName - nodeType;"
    @"nodeType = 'comment' | 'text' | 'processing-instruction' | 'node';"
    @"qName = prefixedName | unprefixedName;"
    @"prefixedName = prefix ':' localPart;"
    @"unprefixedName = localPart;"
    @"localPart = ncName;"
    @"prefix = ncName;"
    @"ncName = Word;";
    
    lp = [factory parserFromGrammar:g assembler:nil];
    TDNotNil(lp);
    t = lp.tokenizer;
    
    t.string = @"foo";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    t.string = @"foo:bar";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[foo, :, bar]foo/:/bar^", [res description]);
    
    t.string = @":bar";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"text";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"comment";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"node";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"processing-instruction";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNil(res);
    
    t.string = @"texts";
    res = [lp bestMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[texts]texts^", [res description]);
    
}

@end
