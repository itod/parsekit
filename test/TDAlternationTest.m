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

#import "TDAlternationTest.h"

@implementation TDAlternationTest

- (void)tearDown {
    [a release];
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz {
    s = @"foo baz bar";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKAlternation alternation];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[foo]foo^baz/bar", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz1 {
    s = @"123 baz bar";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKAlternation alternation];
    [p add:[PKLiteral literalWithString:@"bar"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    [p add:[PKNumber number]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[123]123^baz/bar", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz2 {
    s = @"123 baz bar";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    PKParser *w = [PKWord word];
    PKParser *baz = [PKLiteral literalWithString:@"baz"];
    PKParser *n = [PKNumber number];
    p = [PKAlternation alternationWithSubparsers:w, baz, n, nil];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[123]123^baz/bar", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz3 {
    s = @"123 baz bar";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKAlternation alternation];
    [p add:[PKWord word]];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKNumber number]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[123]123^baz/bar", [result description]);
}


- (void)testTrueLiteralBestMatchForFooSpaceBarSpaceBaz4 {
    s = @"123 baz bar";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKAlternation alternation];
    [p add:[PKLiteral literalWithString:@"foo"]];
    [p add:[PKLiteral literalWithString:@"baz"]];
    [p add:[PKNumber number]];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[123]123^baz/bar", [result description]);
}

@end
