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

#import <ParseKit/PKPattern.h>
#import "RegexKitLite.h"

@implementation PKPattern

+ (PKPattern *)patternWithString:(NSString *)s {
    return [self patternWithString:s options:PKPatternOptionsNone];
}


+ (PKPattern *)patternWithString:(NSString *)s options:(PKPatternOptions)opts {
    return [[[self alloc] initWithString:s options:opts] autorelease];
}


- (id)initWithString:(NSString *)s {
    return [self initWithString:s options:PKPatternOptionsNone];
}

    
- (id)initWithString:(NSString *)s options:(PKPatternOptions)opts {
    if ((self = [super initWithString:s])) {
        options = opts;
    }
    return self;
}


- (BOOL)qualifies:(id)obj {
    PKToken *tok = (PKToken *)obj;

    NSRange r = NSMakeRange(0, [tok.stringValue length]);

    return NSEqualRanges(r, [tok.stringValue rangeOfRegex:self.string options:(uint32_t)options inRange:r capture:0 error:nil]);
}

@end
