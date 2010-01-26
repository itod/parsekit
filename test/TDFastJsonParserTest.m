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

#import "TDFastJsonParserTest.h"
#import "TDFastJsonParser.h"

@implementation TDFastJsonParserTest

- (void)testRun {
    NSString *s = @"{\"foo\":\"bar\"}";
    TDFastJsonParser *p = [[[TDFastJsonParser alloc] init] autorelease];
    id result = [p parse:s];
    
    NSLog(@"result");
    TDNotNil(result);
}


- (void)testCrunchBaseJsonParser {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"yahoo" ofType:@"json"];
    NSString *s = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TDFastJsonParser *parser = [[[TDFastJsonParser alloc] init] autorelease];
    [parser parse:s];
    //    id res = [parser parse:s];
    //NSLog(@"res %@", res);
}

@end
