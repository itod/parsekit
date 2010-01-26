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

#import "TDSymbolTest.h"


@implementation TDSymbolTest

- (void)tearDown {
}


- (void)testDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSymbol symbolWithString:s];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[-]-^", [result description]);
}


- (void)testFalseDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSymbol symbolWithString:@"+"];
    
    PKAssembly *result = [p bestMatchFor:a];
    TDNil(result);
}


- (void)testTrueDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [PKSymbol symbol];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[-]-^", [result description]);
}


- (void)testDiscardDash {
    s = @"-";
    a = [PKTokenAssembly assemblyWithString:s];
    
    p = [[PKSymbol symbolWithString:s] discard];
    
    PKAssembly *result = [p bestMatchFor:a];
    
    TDNotNil(result);
    TDEqualObjects(@"[]-^", [result description]);
}
@end
