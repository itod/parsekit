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

#import "PKExclusion.h"
#import <ParseKit/PKAssembly.h>

@interface NSMutableSet (PKExclusionAdditions)
- (void)exclusiveSetTestingEquality:(NSSet *)s;
@end

@implementation NSMutableSet (PKExclusionAdditions)

- (void)exclusiveSetTestingEquality:(NSSet *)s {
    for (id a1 in self) {
        BOOL found = NO;
        for (id a2 in s) {
            if ([a1 isEqual:a2 ]) {
                found = YES;
                break;
            }
        }
        if (found) {
            [self removeObject:a1];
        }
    }
    
    for (id a2 in s) {
        BOOL found = NO;
        for (id a1 in self) {
            if ([a2 isEqual:a1]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [self addObject:a2];
        }
    }
}

@end

@interface PKParser ()
- (NSSet *)matchAndAssemble:(NSSet *)inAssemblies;
- (NSSet *)allMatchesFor:(NSSet *)inAssemblies;
@end

@implementation PKExclusion

+ (PKExclusion *)exclusion {
    return [[[self alloc] init] autorelease];
}


- (NSSet *)allMatchesFor:(NSSet *)inAssemblies {
    NSParameterAssert(inAssemblies);
    NSMutableSet *outAssemblies = [NSMutableSet set];
    
    NSInteger i = 0;
    for (PKParser *p in subparsers) {
        if (0 == i++) {
            outAssemblies = [[[p matchAndAssemble:inAssemblies] mutableCopy] autorelease];
        } else {
            [outAssemblies exclusiveSetTestingEquality:[p allMatchesFor:inAssemblies]];
        }
    }
    
    return outAssemblies;
}

@end
