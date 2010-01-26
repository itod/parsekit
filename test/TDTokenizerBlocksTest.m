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

#import "TDTokenizerBlocksTest.h"

@implementation TDTokenizerBlocksTest

- (void)setUp {
}


- (void)tearDown {
}


#ifdef TARGET_OS_SNOW_LEOPARD
- (void)testBlastOff {
    s = @"\"It's 123 blast-off!\", she said, // watch out!\n"
    @"and <= 3 'ticks' later /* wince */, it's blast-off!";
    t = [PKTokenizer tokenizerWithString:s];
    
    NSLog(@"\n\n starting!!! \n\n");

    [t enumerateTokensUsingBlock:^(PKToken *tok, BOOL *stop) {
        NSLog(@"(%@)", tok.stringValue);
    }];
                                         
    
    NSLog(@"\n\n done!!! \n\n");
}
#endif

@end
