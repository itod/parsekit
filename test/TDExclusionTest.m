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

#import "TDExclusionTest.h"

@implementation TDExclusionTest

- (void)testFoo {
    PKExclusion *ex = [PKExclusion exclusion];
    [ex add:[PKWord word]];
    [ex add:[PKNum num]];
    
    s = @"'foo'";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDNil(res);
    
    s = @"$";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDNil(res);
    
    s = @"foo";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDEqualObjects(@"[foo]foo^", [res description]);
    
    s = @"2";
    a = [PKTokenAssembly assemblyWithString:s];
    res = [ex bestMatchFor:a];
    TDEqualObjects(@"[2]2^", [res description]);
}

@end
