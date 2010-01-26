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

#import "PKScientificNumberState.h"
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTypes.h>

@interface PKTokenizerState ()
- (void)append:(PKUniChar)c;
@end

@interface PKNumberState ()
- (CGFloat)absorbDigitsFromReader:(PKReader *)r isFraction:(BOOL)isFraction;
- (void)parseRightSideFromReader:(PKReader *)r;
- (void)reset:(PKUniChar)cin;
- (CGFloat)value;
@end

@implementation PKScientificNumberState

- (id)init {
    if (self = [super init]) {
        self.allowsScientificNotation = YES;
    }
    return self;
}


- (void)parseRightSideFromReader:(PKReader *)r {
    NSParameterAssert(r);
    [super parseRightSideFromReader:r];
    if (!allowsScientificNotation) {
        return;
    }
    
    if ('e' == c || 'E' == c) {
        PKUniChar e = c;
        c = [r read];
        
        BOOL hasExp = isdigit(c);
        negativeExp = ('-' == c);
        BOOL positiveExp = ('+' == c);

        if (!hasExp && (negativeExp || positiveExp)) {
            c = [r read];
            hasExp = isdigit(c);
        }
        if (PKEOF != c) {
            [r unread];
        }
        if (hasExp) {
            [self append:e];
            if (negativeExp) {
                [self append:'-'];
            } else if (positiveExp) {
                [self append:'+'];
            }
            c = [r read];
            exp = [super absorbDigitsFromReader:r isFraction:NO];
        }
    }
}


- (void)reset:(PKUniChar)cin {
    [super reset:cin];
    exp = (CGFloat)0.0;
    negativeExp = NO;
}


- (CGFloat)value {
    CGFloat result = (CGFloat)floatValue;
    
    NSUInteger i = 0;
    for ( ; i < exp; i++) {
        if (negativeExp) {
            result /= (CGFloat)10.0;
        } else {
            result *= (CGFloat)10.0;
        }
    }
    
    return (CGFloat)result;
}

@synthesize allowsScientificNotation;
@end
