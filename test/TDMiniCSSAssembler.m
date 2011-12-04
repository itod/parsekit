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

#import "TDMiniCSSAssembler.h"
#import "NSString+ParseKitAdditions.h"
#import <ParseKit/ParseKit.h>

@interface TDMiniCSSAssembler ()
- (void)gatherPropertiesIn:(id)props;
@end

@implementation TDMiniCSSAssembler

- (id)init {
    if (self = [super init]) {
        self.attributes = [NSMutableDictionary dictionary];
        self.paren = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0.0];
        self.curly = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0.0];
    }
    return self;
}


- (void)dealloc {
    self.attributes = nil;
    self.paren = nil;
    self.curly = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Assembler Callbacks

//    @start      = ruleset*;
//    ruleset     = selector '{' decls >'}';
//    selector    = LowercaseWord;            // forcing selectors to be lowercase words for use in a future syntax-highlight framework where i want that
//    decls       = Empty | actualDecls;
//    actualDecls = decl decl*;
//    decl        = property >':' expr >';'?;
//    property    = 'color' | 'background-color' | 'font-family' | 'font-size';
//    expr        = pixelValue | rgb | string | constants;
//    pixelValue  = Number >'px';
//    rgb         = >'rgb' '(' Number >',' Number >',' Number >')';
//    string      = QuotedString;
//    constants   = 'bold' | 'normal' | 'italic';

- (void)parser:(PKParser *)p didMatchProperty:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:tok.stringValue];
}


- (void)parser:(PKParser *)p didMatchString:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:[tok.stringValue stringByTrimmingQuotes]];
}


- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:tok.stringValue];
}


- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:[NSNumber numberWithFloat:tok.floatValue]];
}


- (void)parser:(PKParser *)p didMatchPixelValue:(PKAssembly *)a {
    PKToken *tok = [a pop];
    [a push:[NSNumber numberWithFloat:tok.floatValue]];
}


- (void)parser:(PKParser *)p didMatchRgb:(PKAssembly *)a {
    NSArray *objs = [a objectsAbove:paren];
    [a pop]; // discard '('
    CGFloat blue  = [(PKToken *)[objs objectAtIndex:0] floatValue]/255.0;
    CGFloat green = [(PKToken *)[objs objectAtIndex:1] floatValue]/255.0;
    CGFloat red   = [(PKToken *)[objs objectAtIndex:2] floatValue]/255.0;
    [a push:[NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0]];
}


- (void)parser:(PKParser *)p didMatchActualDecls:(PKAssembly *)a {
    id d = [NSMutableDictionary dictionary];
    NSArray *objs = [a objectsAbove:curly];
    [a pop]; // discard curly

    NSInteger i = 0;
    NSInteger count = [objs count];
    for ( ; i < count - 1; i++) {
        id propVal = [objs objectAtIndex:i];
        id propName = [objs objectAtIndex:++i];
        [d setObject:propVal forKey:propName];
    }
    
    [a push:d];
}


- (void)parser:(PKParser *)p didMatchRuleset:(PKAssembly *)a {
    id props = [a pop];
    [self gatherPropertiesIn:props];

    for (PKToken *selectorTok in [a objectsAbove:nil]) {
        NSString *selector = selectorTok.stringValue;
        [attributes setObject:props forKey:selector];
    }
}


- (void)gatherPropertiesIn:(id)props {
    NSColor *color = [props objectForKey:@"color"];
    if (!color) {
        color = [NSColor blackColor];
    }
    [props setObject:color forKey:NSForegroundColorAttributeName];
    [props removeObjectForKey:@"color"];

    color = [props objectForKey:@"background-color"];
    if (!color) {
        color = [NSColor whiteColor];
    }
    [props setObject:color forKey:NSBackgroundColorAttributeName];
    [props removeObjectForKey:@"background-color"];
    
    NSString *fontFamily = [props objectForKey:@"font-family"];
    if (![fontFamily length]) {
        fontFamily = @"Monaco";
    }
    
    CGFloat fontSize = [[props objectForKey:@"font-size"] doubleValue];
    if (fontSize < 9.0) {
        fontSize = 9.0;
    }
    
    NSFont *font = [NSFont fontWithName:fontFamily size:fontSize];
    [props setObject:font forKey:NSFontAttributeName];
    [props removeObjectForKey:@"font-family"];
    [props removeObjectForKey:@"font-size"];
}

@synthesize attributes;
@synthesize paren;
@synthesize curly;
@end


//- (NSUInteger)hexValueFor:(NSString *)inStr {
//    NSUInteger i = [[inStr substringWithRange:NSMakeRange(0, 1)] integerValue];
//    i = i *= 16;
//    i += [[inStr substringWithRange:NSMakeRange(1, 1)] integerValue];
//    return i;
//}
//
//- (void)parser:(PKParser *)p didMatchHexcolor:(PKAssembly *)a {
//    PKToken *tok = [a pop];
//    NSString *s = tok.stringValue;
//    NSColor *color = nil;
//    
//    if (6 == [s length]) {
//        NSString *redStr   = [s substringWithRange:NSMakeRange(0, 2)];
//        NSString *greenStr = [s substringWithRange:NSMakeRange(2, 2)];
//        NSString *blueStr  = [s substringWithRange:NSMakeRange(4, 2)];
//        
//        NSUInteger red   = [self hexValueFor:redStr];
//        NSUInteger green = [self hexValueFor:greenStr];
//        NSUInteger blue  = [self hexValueFor:blueStr];
//        
//        color = [NSColor colorWithDeviceRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
//    } else {
//        color = [NSColor magentaColor]; // signals incorrect value in stylesheet
//    }
//    [a push:color];
//}
