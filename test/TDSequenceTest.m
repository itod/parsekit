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

#import "TDSequenceTest.h"

@interface PKParser ()
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@implementation TDSequenceTest

- (void)tearDown {
}

- (void)testDiscard {
    s = @"foo -";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]foo/-^", [result description]);
}


- (void)testDiscard2 {
    s = @"foo foo -";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, foo]foo/foo/-^", [result description]);
}


- (void)testDiscard3 {
    s = @"foo - foo";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, foo]foo/-/foo^", [result description]);
}


- (void)testDiscard1 {
    s = @"- foo";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]-/foo^", [result description]);
}


- (void)testDiscard4 {
    s = @"- foo -";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]-/foo/-^", [result description]);
}


- (void)testDiscard5 {
    s = @"- foo + foo";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[[PKSymbol symbolWithString:@"-"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[[PKSymbol symbolWithString:@"+"] discard]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, foo]-/foo/+/foo^", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz1 {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];

    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    PKParser *baz = [PKLiteral literalWithString:@"baz"];
    p = [PKSequence sequenceWithSubparsers:foo, baz, bar, nil];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNil(result);
}


- (void)testFalseLiteralBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testTrueLiteralCompleteMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testTrueLiteralCompleteMatchForFooSpaceBarSpaceBaz1 {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKWord word]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo, bar, baz]foo/bar/baz^", [result description]);
}


- (void)testFalseLiteralCompleteMatchForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testFalseLiteralCompleteMatchForFooSpaceBarSpaceBaz1 {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKNumber number]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testTrueLiteralAllMatchsForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
}


- (void)testFalseLiteralAllMatchsForFooSpaceBarSpaceBaz {
    s = @"foo bar baz";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSequence sequence];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"123"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    NSSet *result = [p allMatchesFor:[NSSet setWithObject:a]];
    
    TDNotNil(result);
    NSUInteger c = [result count];
    TDEquals((NSUInteger)0, c);
}

@end
