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

#import "XPathParserGrammarTest.h"

@implementation XPathParserGrammarTest

- (void)setUp {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"xpath1_0" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    p = [[PKParserFactory factory] parserFromGrammar:g assembler:nil];
    t = p.tokenizer;
}


- (void)testFoo {
    t.string = @"foo";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDNotNil(res);
    TDEqualObjects(@"[foo]foo^", [res description]);
}


- (void)test {
    t.string = @"child::foo";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    //    NSLog(@"\n\n res: %@ \n\n", res);
    //TDEqualObjects(@"[/, foo]//foo^", [res description]);
    
    
    t.string = @"/foo";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
//    NSLog(@"\n\n res: %@ \n\n", res);
    TDEqualObjects(@"[/, foo]//foo^", [res description]);
    
    t.string = @"/foo/bar";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, foo, /, bar]//foo///bar^", [res description]);
    
    t.string = @"/foo/bar/baz";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, foo, /, bar, /, baz]//foo///bar///baz^", [res description]);
    
    t.string = @"/foo/bar[baz]";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, foo, /, bar, [, baz, ]]//foo///bar/[/baz/]^", [res description]);
    
    t.string = @"/foo/bar[@baz]";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, foo, /, bar, [, @, baz, ]]//foo///bar/[/@/baz/]^", [res description]);
    
    t.string = @"/foo/bar[@baz='foo']";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, foo, /, bar, [, @, baz, =, 'foo', ]]//foo///bar/[/@/baz/=/'foo'/]^", [res description]);
    
    t.string = @"/foo/bar[baz]/foo";
    res = [p completeMatchFor:[PKTokenAssembly assemblyWithTokenizer:t]];
    TDEqualObjects(@"[/, foo, /, bar, [, baz, ], /, foo]//foo///bar/[/baz/]///foo^", [res description]);
    
    // not supported
    t.string = @"//foo";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [p bestMatchFor:a];
    NSLog(@"\n\n res: %@ \n\n", res);
    TDEqualObjects(@"[//, foo]///foo^", [res description]);
}


- (void)testAxisName {
    t.string = @"child";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"axisName"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[child]child^", [res description]);
    
    t.string = @"preceding-sibling";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"axisName"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[preceding-sibling]preceding-sibling^", [res description]);
}


- (void)testAxisSpecifier {
    t.string = @"child::";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"axisSpecifier"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[child, ::]child/::^", [res description]);
    t.string = @"preceding-sibling::";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"axisSpecifier"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[preceding-sibling, ::]preceding-sibling/::^", [res description]);
}


- (void)testQName {
    t.string = @"foo:bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"qName"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, :, bar]foo/:/bar^", [res description]);
    
    t.string = @"foo:bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    //TDAssertThrowsSpecificNamed([p.QName bestMatchFor:a], [NSException class], @"PKTrackException");
}


- (void)testNameTest {
    t.string = @"foo:bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nameTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, :, bar]foo/:/bar^", [res description]);
    
    t.string = @"*";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nameTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[*]*^", [res description]);
    
    t.string = @"foo:*";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nameTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, :, *]foo/:/*^", [res description]);
    
    t.string = @"*:bar"; // NOT ALLOWED
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nameTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[*]*^:/bar", [res description]);
    
    t.string = @"foo";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nameTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    t.string = @"foo:bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    //TDAssertThrowsSpecificNamed([p.nameTest bestMatchFor:a], [NSException class], @"PKTrackException");
}


- (void)testNodeType {
    t.string = @"comment";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeType"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[comment]comment^", [res description]);
    
    t.string = @"node";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeType"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[node]node^", [res description]);
    
}


- (void)testNodeTest {
    t.string = @"comment()";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[comment, (, )]comment/(/)^", [res description]);
    
    t.string = @"processing-instruction()";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[processing-instruction, (, )]processing-instruction/(/)^", [res description]);
    
    t.string = @"processing-instruction('baz')";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[processing-instruction, (, 'baz', )]processing-instruction/(/'baz'/)^", [res description]);
    
    t.string = @"node()";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[node, (, )]node/(/)^", [res description]);
    
    t.string = @"text()";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[text, (, )]text/(/)^", [res description]);
    
    t.string = @"*";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[*]*^", [res description]);
    
    t.string = @"foo:*";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, :, *]foo/:/*^", [res description]);
    
    t.string = @"bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"nodeTest"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[bar]bar^", [res description]);
}


- (void)testVariableReference {
    t.string = @"$foo";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    p = [p parserNamed:@"pathExpr"];
    res = [p bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[$, foo]$/foo^", [res description]);
    
    t.string = @"$bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    p = [p parserNamed:@"pathExpr"];
    res = [p bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[$, bar]$/bar^", [res description]);
}


- (void)testFunctionCall {
    t.string = @"foo()";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [p bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, (, )]foo/(/)^", [res description]);
    
    t.string = @"foo('bar')";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [p bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, (, 'bar', )]foo/(/'bar'/)^", [res description]);
    
    t.string = @"foo('bar', 'baz')";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [p bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, (, 'bar', ,, 'baz', )]foo/(/'bar'/,/'baz'/)^", [res description]);
    
    t.string = @"foo('bar', 1)";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [p bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, (, 'bar', ,, 1, )]foo/(/'bar'/,/1/)^", [res description]);
}

- (void)testOrExpr {
    t.string = @"foo or bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"orExpr"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, or, bar]foo/or/bar^", [res description]);
}


- (void)testAndExpr {
    t.string = @"foo() and bar()";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"andExpr"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, (, ), and, bar, (, )]foo/(/)/and/bar/(/)^", [res description]);
    
    t.string = @"foo and bar";
    a = [PKTokenAssembly assemblyWithTokenizer:t];
    res = [[p parserNamed:@"andExpr"] bestMatchFor:a];
    TDNotNil(res);
    TDEqualObjects(@"[foo, and, bar]foo/and/bar^", [res description]);
}

@end
