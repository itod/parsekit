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

#import "TDLiteralTest.h"

@implementation TDLiteralTest

- (void)tearDown {
    [a release];
}

- (void)testTrueCompleteMatchForLiteral123 {
    s = @"123";
    a = [[PKTokenAssembly alloc] initWithString:s];
    NSLog(@"a: %@", a);
    
    p = [PKNumber number];
    PKAssembly *result = [p completeMatchFor:a];
    
    // -[PKParser completeMatchFor:]
    // -[PKParser bestMatchFor:]
    // -[PKParser matchAndAssemble:]
    // -[PKTerminal allMatchesFor:]
    // -[PKTerminal matchOneAssembly:]
    // -[PKLiteral qualifies:]
    // -[PKParser best:]
    
    NSLog(@"result: %@", result);
    TDNotNil(result);
    TDEqualObjects(@"[123]123^", [result description]);
}


- (void)testFalseCompleteMatchForLiteral123 {
    s = @"1234";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKLiteral literalWithString:@"123"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
    TDEqualObjects(@"[]^1234", [a description]);
}


- (void)testTrueCompleteMatchForLiteralFoo {
    s = @"Foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKLiteral literalWithString:@"Foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[Foo]Foo^", [result description]);
}


- (void)testFalseCompleteMatchForLiteralFoo {
    s = @"Foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKLiteral literalWithString:@"foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testFalseCompleteMatchForCaseInsensitiveLiteralFoo {
    s = @"Fool";
    a = [[PKTokenAssembly alloc] initWithString:s];
    
    p = [PKCaseInsensitiveLiteral literalWithString:@"Foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNil(result);
}


- (void)testTrueCompleteMatchForCaseInsensitiveLiteralFoo {
    s = @"Foo";
    a = [[PKTokenAssembly alloc] initWithString:s];
        
    p = [PKCaseInsensitiveLiteral literalWithString:@"foo"];
    PKAssembly *result = [p completeMatchFor:a];
    TDNotNil(result);
    TDEqualObjects(@"[Foo]Foo^", [result description]);
}

@end
