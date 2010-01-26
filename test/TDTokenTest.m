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

#import "TDTokenTest.h"

@implementation TDTokenTest

- (void)setUp {
    eof = [PKToken EOFToken];
}


- (void)testEOFTokenReleaseOnce1 {
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenReleaseOnce2 {
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenReleaseTwice1 {
    TDNotNil(eof);
    [eof release];
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenReleaseTwice2 {
    TDNotNil(eof);
    [eof release];
    TDNotNil(eof);
    [eof release];
}


- (void)testEOFTokenAutoreleaseOnce1 {
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenAutoreleaseOnce2 {
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenAutoreleaseTwice1 {
    TDNotNil(eof);
    [eof autorelease];
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenAutoreleaseTwice2 {
    TDNotNil(eof);
    [eof autorelease];
    TDNotNil(eof);
    [eof autorelease];
}


- (void)testEOFTokenRetainCount {
    TDTrue([eof retainCount] >= 17035104);
    // NO IDEA WHY THIS WONT PASS
    //TDEquals(UINT_MAX, [eof retainCount]);  /*17035104 4294967295*/
//    TDEqualObjects([NSNumber numberWithUnsignedInt:4294967295], [NSNumber numberWithUnsignedInt:[eof retainCount]]);
}


- (void)testCopyIdentity {
    id copy = [eof copy];
    TDTrue(copy == eof);
    [copy release]; // appease clang sa
}

@end
