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

#import "TDArithmeticAssembler.h"
#import <ParseKit/ParseKit.h>

@implementation TDArithmeticAssembler

- (void)didMatchPlus:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue + tok2.floatValue]];
}


- (void)didMatchMinus:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue - tok2.floatValue]];
}


- (void)didMatchTimes:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue * tok2.floatValue]];
}


- (void)didMatchDivide:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    [a push:[NSNumber numberWithDouble:tok1.floatValue / tok2.floatValue]];
}


- (void)didMatchExp:(PKAssembly *)a {
    PKToken *tok2 = [a pop];
    PKToken *tok1 = [a pop];
    
    CGFloat n1 = tok1.floatValue;
    CGFloat n2 = tok2.floatValue;
    
    CGFloat res = n1;
    NSUInteger i = 1;
    for ( ; i < n2; i++) {
        res *= n1;
    }
    
    [a push:[NSNumber numberWithDouble:res]];
}

@end
