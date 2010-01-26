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

#import "TDTokenArraySourceTest.h"

@implementation TDTokenArraySourceTest

- (void)setUp {
}


- (void)testFoo {
    d = @";";
    s = @"I came; I saw; I left in peace.;";
    t = [[[PKTokenizer alloc] initWithString:s] autorelease];
    tas = [[[PKTokenArraySource alloc] initWithTokenizer:t delimiter:d] autorelease];
    
    TDTrue([tas hasMore]);
    NSArray *a = [tas nextTokenArray];
    TDNotNil(a);
    TDEquals((NSUInteger)2, [a count]);
    TDEqualObjects(@"I", [[a objectAtIndex:0] stringValue]);
    TDEqualObjects(@"came", [[a objectAtIndex:1] stringValue]);

    TDTrue([tas hasMore]);
    a = [tas nextTokenArray];
    TDNotNil(a);
    TDEquals((NSUInteger)2, [a count]);
    TDEqualObjects(@"I", [[a objectAtIndex:0] stringValue]);
    TDEqualObjects(@"saw", [[a objectAtIndex:1] stringValue]);

    TDTrue([tas hasMore]);
    a = [tas nextTokenArray];
    TDNotNil(a);
    TDEquals((NSUInteger)5, [a count]);
    TDEqualObjects(@"I", [[a objectAtIndex:0] stringValue]);
    TDEqualObjects(@"left", [[a objectAtIndex:1] stringValue]);
    TDEqualObjects(@"in", [[a objectAtIndex:2] stringValue]);
    TDEqualObjects(@"peace", [[a objectAtIndex:3] stringValue]);
    TDEqualObjects(@".", [[a objectAtIndex:4] stringValue]);

    TDFalse([tas hasMore]);
    a = [tas nextTokenArray];
    TDNil(a);
}
@end
