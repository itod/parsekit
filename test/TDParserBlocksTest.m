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

#import "TDParserBlocksTest.h"

@implementation TDParserBlocksTest

- (void)setUp {
}


- (void)tearDown {
}


#ifdef TARGET_OS_SNOW_LEOPARD
- (void)testMath {
    s = @"2 4 6 8";
    start = [PKTokenAssembly assemblyWithString:s];
    
    PKNumber *n = [PKNumber number];
    p = [PKRepetition repetitionWithSubparser:n];
    
    n.assemblerBlock = ^(PKAssembly *a) {
        if (![a isStackEmpty]) {
            PKToken *tok = [a pop];
            [a push:[NSNumber numberWithFloat:tok.floatValue]];
        }
    };
    
    p.assemblerBlock = ^(PKAssembly *a) {
        NSNumber *total = [a pop];
        if (!total) {
            total = [NSNumber numberWithFloat:0];
        }

        while (![a isStackEmpty]) {
            NSNumber *n = [a pop];
            total = [NSNumber numberWithFloat:[total floatValue] + [n floatValue]];
        }
        
        [a push:total];
    };
             
    PKAssembly *result = [p completeMatchFor:start];
    TDNotNil(result);
    TDEqualObjects(@"[20]2/4/6/8^", [result description]);
    TDEquals((double)20.0, [[result pop] doubleValue]);
}


- (void)testMath2 {
    PKParser *addParser = [PKRepetition repetitionWithSubparser:[PKNumber number]];
    
    addParser.assemblerBlock = ^(PKAssembly *a) {
        NSArray *toks = [a objectsAbove:nil];
        double total = 0.0;
        
        for (PKToken *tok in toks) {
            total += [tok floatValue];
        }
        
        [a push:[NSNumber numberWithDouble:total]];
    };
    
    s = @"2.5 -5.5 8";

//    NSNumber *result = [addParser parse:s];
//    NSAssert([result doubleValue] == 5.0, @"");

    start = [PKTokenAssembly assemblyWithString:s];
    PKAssembly *result = [addParser completeMatchFor:start];
    TDNotNil(result);
    TDEqualObjects(@"[5]2.5/-5.5/8^", [result description]);
    TDEquals(5.0, [(NSNumber *)[result pop] doubleValue]);
}
#endif

@end
