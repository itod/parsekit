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

#import "TDCharacterAssemblyTest.h"

@interface PKAssembly ()
- (id)next;
- (BOOL)hasMore;
@property (nonatomic, readonly) NSUInteger objectsConsumed;
@property (nonatomic, readonly) NSUInteger objectsRemaining;
@end

@implementation TDCharacterAssemblyTest

- (void)testAbc {
    s = @"abc";
    a = [PKCharacterAssembly assemblyWithString:s];

    TDNotNil(a);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)0, a.objectsConsumed);
    TDEquals((NSUInteger)3, a.objectsRemaining);
    TDEquals(YES, [a hasMore]);
    
    id obj = [a next];
    TDEqualObjects(obj, [NSNumber numberWithInteger:'a']);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)1, a.objectsConsumed);
    TDEquals((NSUInteger)2, a.objectsRemaining);
    TDEquals(YES, [a hasMore]);

    obj = [a next];
    TDEqualObjects(obj, [NSNumber numberWithInteger:'b']);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)2, a.objectsConsumed);
    TDEquals((NSUInteger)1, a.objectsRemaining);
    TDEquals(YES, [a hasMore]);

    obj = [a next];
    TDEqualObjects(obj, [NSNumber numberWithInteger:'c']);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)3, a.objectsConsumed);
    TDEquals((NSUInteger)0, a.objectsRemaining);
    TDEquals(NO, [a hasMore]);

    obj = [a next];
    TDNil(obj);
    TDEquals((NSUInteger)3, [s length]);
    TDEquals((NSUInteger)3, a.objectsConsumed);
    TDEquals((NSUInteger)0, a.objectsRemaining);
    TDEquals(NO, [a hasMore]);
}

@end
