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

#import "TDDifferenceTest.h"

@implementation TDDifferenceTest

- (void)testFoo {
    PKWord *word = [PKWord word];
    PKLiteral *foo = [PKLiteral literalWithString:@"foo"];
    d = [PKDifference differenceWithSubparser:word minus:foo];
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[bar]bar^", [res description]);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    NSLog(@"res: %@", res);
    TDNil(res);

    s = @"wee";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[wee]wee^", [res description]);
}


- (void)testAlt {
    PKWord *word = [PKWord word];
    PKAlternation *list = [PKAlternation alternation];
    [list add:[PKLiteral literalWithString:@"foo"]];
    [list add:[PKLiteral literalWithString:@"bar"]];
    
    d = [PKDifference differenceWithSubparser:word minus:list];
    
    s = @"baz";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
    
    s = @"%";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
    
    s = @"wee";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[wee]wee^", [res description]);
}


- (void)testAlt2 {
    PKAlternation *ok = [PKAlternation alternation];
    [ok add:[PKLiteral literalWithString:@"foo"]];
    [ok add:[PKLiteral literalWithString:@"baz"]];
    
    PKAlternation *list = [PKAlternation alternation];
    [list add:[PKLiteral literalWithString:@"foo"]];
    [list add:[PKLiteral literalWithString:@"bar"]];
    
    d = [PKDifference differenceWithSubparser:ok minus:list];
    
    s = @"baz";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDEqualObjects(@"[baz]baz^", [res description]);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);

    s = @"wee";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [d bestMatchFor:a];
    TDNil(res);
}


- (void)testParserNamed {
    PKWord *w = [PKWord word];
    w.name = @"w";

    PKCollectionParser *m = [PKAlternation alternation];
    m.name = @"m";
    
    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    foo.name = @"foo";
    [m add:foo];

    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    bar.name = @"bar";
    [m add:bar];
    
    d = [PKDifference differenceWithSubparser:w minus:m];
    
    TDEquals(w, [d parserNamed:@"w"]);
    TDEquals(m, [d parserNamed:@"m"]);
    TDEquals(foo, [d parserNamed:@"foo"]);
    TDEquals(bar, [d parserNamed:@"bar"]);
}

@end
