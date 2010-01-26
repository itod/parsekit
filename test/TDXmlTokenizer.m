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

#import "TDXmlTokenizer.h"
#import "XMLReader.h"
#import "TDXmlToken.h"

@interface TDXmlTokenizer ()
@property (nonatomic, retain) XMLReader *reader;
@end

@implementation TDXmlTokenizer

+ (id)tokenizerWithContentsOfFile:(NSString *)path {
    return [[[self alloc] initWithContentsOfFile:path] autorelease];
}


- (id)init {
    return nil;
}


- (id)initWithContentsOfFile:(NSString *)path {
    if (self = [super init]) {
        self.reader = [[[XMLReader alloc] initWithContentsOfFile:path] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.reader = nil;
    [super dealloc];
}


- (TDXmlToken *)nextToken {
    TDXmlToken *tok = nil;
    NSInteger ret = -1;
    NSInteger nodeType = -1;
    
    do {
        ret = [reader read];    
        nodeType = reader.nodeType;
    } while (nodeType == TDTT_XML_SIGNIFICANT_WHITESPACE || nodeType == TDTT_XML_WHITESPACE);

    if (ret <= 0) {
        tok = [TDXmlToken EOFToken];
    } else {
        tok = [TDXmlToken tokenWithTokenType:reader.nodeType stringValue:reader.name];
    }
    
    return tok;
}

@synthesize reader;
@end
