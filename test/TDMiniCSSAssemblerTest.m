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

#import "TDMiniCSSAssemblerTest.h"

@implementation TDMiniCSSAssemblerTest

- (void)setUp {
    path = [[NSBundle bundleForClass:[self class]] pathForResource:@"mini_css" ofType:@"grammar"];
    grammarString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    ass = [[TDMiniCSSAssembler alloc] init];
    factory = [PKParserFactory factory];
    lp = [factory parserFromGrammar:grammarString assembler:ass];
}


- (void)tearDown {
    [ass release];
}


- (void)testColor {
    TDNotNil(lp);
    
    s = @"bar { color:rgb(10, 200, 30); }";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]bar/{/color/:/rgb/(/10/,/200/,/30/)/;/}^", [a description]);
    TDNotNil(ass.attributes);
    id props = [ass.attributes objectForKey:@"bar"];
    TDNotNil(props);
    
    NSColor *color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(10.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(200.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(30.0/255.0), 0.001, @"");
}


- (void)testMultiSelectorColor {
    TDNotNil(lp);
    
    s = @"foo, bar { color:rgb(10, 200, 30); }";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]foo/,/bar/{/color/:/rgb/(/10/,/200/,/30/)/;/}^", [a description]);
    TDNotNil(ass.attributes);

    id props = [ass.attributes objectForKey:@"bar"];
    TDNotNil(props);
    
    NSColor *color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(10.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(200.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(30.0/255.0), 0.001, @"");

    props = [ass.attributes objectForKey:@"foo"];
    TDNotNil(props);
    
    color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(10.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(200.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(30.0/255.0), 0.001, @"");
}


- (void)testBackgroundColor {
    TDNotNil(lp);
    
    s = @"foo { background-color:rgb(255.0, 0.0, 255.0) }";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]foo/{/background-color/:/rgb/(/255.0/,/0.0/,/255.0/)/}^", [a description]);
    TDNotNil(ass.attributes);
    
    id props = [ass.attributes objectForKey:@"foo"];
    TDNotNil(props);
    
    NSColor *color = [props objectForKey:NSBackgroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(255.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(0.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(255.0/255.0), 0.001, @"");
}


- (void)testFontSize {
    TDNotNil(lp);
    
    s = @"decl { font-size:12px }";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]decl/{/font-size/:/12/px/}^", [a description]);
    TDNotNil(ass.attributes);
    
    id props = [ass.attributes objectForKey:@"decl"];
    TDNotNil(props);
    
    NSFont *font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEquals((CGFloat)[font pointSize], (CGFloat)12.0);
    TDEqualObjects([font familyName], @"Monaco");
}


- (void)testSmallFontSize {
    TDNotNil(lp);
    
    s = @"decl { font-size:8px }";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]decl/{/font-size/:/8/px/}^", [a description]);
    TDNotNil(ass.attributes);
    
    id props = [ass.attributes objectForKey:@"decl"];
    TDNotNil(props);
    
    NSFont *font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEquals((CGFloat)[font pointSize], (CGFloat)9.0);
    TDEqualObjects([font familyName], @"Monaco");
}


- (void)testFont {
    TDNotNil(lp);
    
    s = @"expr { font-size:16px; font-family:'Helvetica' }";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]expr/{/font-size/:/16/px/;/font-family/:/'Helvetica'/}^", [a description]);
    TDNotNil(ass.attributes);
    
    id props = [ass.attributes objectForKey:@"expr"];
    TDNotNil(props);
        
    NSFont *font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEqualObjects([font familyName], @"Helvetica");
    TDEquals((CGFloat)[font pointSize], (CGFloat)16.0);
}


- (void)testAll {
    TDNotNil(lp);
    
    s = @"expr { font-size:9.0px; font-family:'Courier'; background-color:rgb(255.0, 0.0, 255.0) ;  color:rgb(10, 200, 30);}";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]expr/{/font-size/:/9.0/px/;/font-family/:/'Courier'/;/background-color/:/rgb/(/255.0/,/0.0/,/255.0/)/;/color/:/rgb/(/10/,/200/,/30/)/;/}^", [a description]);
    TDNotNil(ass.attributes);
    
    id props = [ass.attributes objectForKey:@"expr"];
    TDNotNil(props);
    
    NSFont *font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEqualObjects([font familyName], @"Courier");
    TDEquals((CGFloat)[font pointSize], (CGFloat)9.0);

    NSColor *bgColor = [props objectForKey:NSBackgroundColorAttributeName];
    TDNotNil(bgColor);
    STAssertEqualsWithAccuracy([bgColor redComponent], (CGFloat)(255.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor greenComponent], (CGFloat)(0.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor blueComponent], (CGFloat)(255.0/255.0), 0.001, @"");

    NSColor *color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(10.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(200.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(30.0/255.0), 0.001, @"");
}


- (void)testMultiAll {
    TDNotNil(lp);
    
    s = @"expr, decl { font-size:9.0px; font-family:'Courier'; background-color:rgb(255.0, 0.0, 255.0) ;  color:rgb(10, 200, 30);}";
    a = [PKTokenAssembly assemblyWithString:s];
    a = [lp bestMatchFor:a];
    TDEqualObjects(@"[]expr/,/decl/{/font-size/:/9.0/px/;/font-family/:/'Courier'/;/background-color/:/rgb/(/255.0/,/0.0/,/255.0/)/;/color/:/rgb/(/10/,/200/,/30/)/;/}^", [a description]);
    TDNotNil(ass.attributes);
    
    id props = [ass.attributes objectForKey:@"expr"];
    TDNotNil(props);
    
    NSFont *font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEqualObjects([font familyName], @"Courier");
    TDEquals((CGFloat)[font pointSize], (CGFloat)9.0);
    
    NSColor *bgColor = [props objectForKey:NSBackgroundColorAttributeName];
    TDNotNil(bgColor);
    STAssertEqualsWithAccuracy([bgColor redComponent], (CGFloat)(255.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor greenComponent], (CGFloat)(0.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor blueComponent], (CGFloat)(255.0/255.0), 0.001, @"");
    
    NSColor *color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(10.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(200.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(30.0/255.0), 0.001, @"");

    props = [ass.attributes objectForKey:@"decl"];
    TDNotNil(props);
    
    font = [props objectForKey:NSFontAttributeName];
    TDNotNil(font);
    TDEqualObjects([font familyName], @"Courier");
    TDEquals((CGFloat)[font pointSize], (CGFloat)9.0);
    
    bgColor = [props objectForKey:NSBackgroundColorAttributeName];
    TDNotNil(bgColor);
    STAssertEqualsWithAccuracy([bgColor redComponent], (CGFloat)(255.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor greenComponent], (CGFloat)(0.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([bgColor blueComponent], (CGFloat)(255.0/255.0), 0.001, @"");
    
    color = [props objectForKey:NSForegroundColorAttributeName];
    TDNotNil(color);
    STAssertEqualsWithAccuracy([color redComponent], (CGFloat)(10.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color greenComponent], (CGFloat)(200.0/255.0), 0.001, @"");
    STAssertEqualsWithAccuracy([color blueComponent], (CGFloat)(30.0/255.0), 0.001, @"");
}

@end
