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

#import "TDXmlText.h"
#import "TDXmlToken.h"

@implementation TDXmlText

+ (id)text {
    return [[[self alloc] initWithString:nil] autorelease];
}


+ (id)textWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


- (id)initWithString:(NSString *)s {
    NSLog(@"%s", _cmd);
    self = [super initWithString:s];
    if (self) {
        self.tok = [TDXmlToken tokenWithTokenType:TDTT_XML_TEXT stringValue:s];
        NSLog(@"tok : %@", tok);
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (BOOL)qualifies:(id)obj {
    TDXmlToken *other = (TDXmlToken *)obj;
    NSLog(@"%s obj: %@ isText: %d", _cmd, obj, other.isText);
    
    if ([string length]) {
        return [tok isEqual:other];
    } else {
        return other.isText;
    }
}

@end
