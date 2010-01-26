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

#import "TDNegationTest.h"

@implementation TDNegationTest

- (void)testFoo {
    n = [PKNegation negationWithSubparser:[PKWord word]];
    
    s = @"bar";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [n bestMatchFor:a];
    TDNil(res);

    s = @"'foo'";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [n bestMatchFor:a];
    TDEqualObjects(@"['foo']'foo'^", [res description]);

    n = [PKNegation negationWithSubparser:[PKLiteral literalWithString:@"foo"]];
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [n bestMatchFor:a];
    TDNil(res);
}


- (void)testParserNamed {
    PKWord *w = [PKWord word];
    w.name = @"w";
    n = [PKNegation negationWithSubparser:w];
    
    TDEquals(w, [n parserNamed:@"w"]);

    PKCollectionParser *alt = [PKAlternation alternation];
    alt.name = @"alt";
    
    PKParser *foo = [PKLiteral literalWithString:@"foo"];
    foo.name = @"foo";
    [alt add:foo];
    
    PKParser *bar = [PKLiteral literalWithString:@"bar"];
    bar.name = @"bar";
    [alt add:bar];
    
    n = [PKNegation negationWithSubparser:alt];
    
    TDEquals(alt, [n parserNamed:@"alt"]);
    TDEquals(foo, [n parserNamed:@"foo"]);
    TDEquals(bar, [n parserNamed:@"bar"]);
}
    
@end
