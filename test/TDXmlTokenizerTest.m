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

#import "TDXmlTokenizerTest.h"
#import "TDXmlDecl.h"
#import "TDXmlStartTag.h"
#import "TDXmlEndTag.h"
#import "TDXmlText.h"
#import "TDXmlSignificantWhitespace.h"
#import "TDXmlTokenAssembly.h"


@implementation TDXmlTokenizerTest

- (void)testFoo {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"apple-boss" ofType:@"xml"];

    TDXmlTokenizer *t = [TDXmlTokenizer tokenizerWithContentsOfFile:path];
    NSLog(@"\n\n %@\n\n", t);
    
    TDXmlToken *eof = [TDXmlToken EOFToken];
    TDXmlToken *tok = nil;
    
    while ((tok = [t nextToken]) != eof) {
        //NSLog(@" %@", [tok debugDescription]);
    }
}


- (void)testAppleBoss {
    PKSequence *s = [PKSequence sequence];
    s.name = @"parent sequence";
    [s add:[TDXmlStartTag startTagWithString:@"result"]];
    [s add:[TDXmlStartTag startTagWithString:@"url"]];
    [s add:[TDXmlText text]];
    [s add:[TDXmlEndTag endTagWithString:@"url"]];
    [s add:[TDXmlEndTag endTagWithString:@"result"]];
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"small-xml-file" ofType:@"xml"];
    TDXmlTokenAssembly *a = (TDXmlTokenAssembly *)[TDXmlTokenAssembly assemblyWithString:path];
    
    PKAssembly *result = [s bestMatchFor:a];
    NSLog(@"\n\n\n result: %@ \n\n\n", result);
}

@end
