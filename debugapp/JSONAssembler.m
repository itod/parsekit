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

#import "JSONAssembler.h"
#import "NSArray+ParseKitAdditions.h"
#import <ParseKit/ParseKit.h>

@implementation JSONAssembler

- (id)init {
    self = [super init];
    if (self != nil) {
        NSColor *textColor = [NSColor whiteColor];
        NSColor *tagColor = [NSColor colorWithDeviceRed:.70 green:.14 blue:.53 alpha:1.];
        NSColor *attrNameColor = [NSColor colorWithDeviceRed:.33 green:.45 blue:.48 alpha:1.];
        NSColor *attrValueColor = [NSColor colorWithDeviceRed:.77 green:.18 blue:.20 alpha:1.];
        NSColor *commentColor = [NSColor colorWithDeviceRed:.24 green:.70 blue:.27 alpha:1.];
        NSColor *piColor = [NSColor colorWithDeviceRed:.09 green:.62 blue:.74 alpha:1.];

        NSFont *monacoFont = [NSFont fontWithName:@"Monaco" size:11.0];
            
        self.defaultAttrs      = [NSDictionary dictionaryWithObjectsAndKeys:
                                  textColor, NSForegroundColorAttributeName,
                                  monacoFont, NSFontAttributeName,
                                  nil];
        self.objectAttrs       = [NSDictionary dictionaryWithObjectsAndKeys:
                                  tagColor, NSForegroundColorAttributeName,
                                  monacoFont, NSFontAttributeName,
                                  nil];
        self.propertyNameAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                                  attrNameColor, NSForegroundColorAttributeName,
                                  monacoFont, NSFontAttributeName,
                                  nil];
        self.valueAttrs        = [NSDictionary dictionaryWithObjectsAndKeys:
                                  attrValueColor, NSForegroundColorAttributeName,
                                  monacoFont, NSFontAttributeName,
                                  nil];
        self.constantAttrs     = [NSDictionary dictionaryWithObjectsAndKeys:
                                  piColor, NSForegroundColorAttributeName,
                                  monacoFont, NSFontAttributeName,
                                  nil];
        self.arrayAttrs        = [NSDictionary dictionaryWithObjectsAndKeys:
                                  commentColor, NSForegroundColorAttributeName,
                                  monacoFont, NSFontAttributeName,
                                  nil];

        self.displayString = [[[NSMutableAttributedString alloc] initWithString:@"" attributes:defaultAttrs] autorelease];
        
        self.comma = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"," floatValue:0];
        self.curly = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0];
        self.bracket = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"[" floatValue:0];
    }
    return self;
}


- (void)dealloc {
    self.displayString = nil;
    self.defaultAttrs = nil;
    self.objectAttrs = nil;
    self.arrayAttrs = nil;
    self.propertyNameAttrs = nil;
    self.valueAttrs = nil;
    self.constantAttrs = nil;
    self.comma = nil;
    self.curly = nil;
    self.bracket = nil;
    [super dealloc];
}


- (void)appendAttributedStringForObjects:(NSArray *)objs withAttrs:(id)attrs {
    for (id obj in objs) {
        NSAttributedString *as = [[NSAttributedString alloc] initWithString:[obj stringValue] attributes:attrs];
        [displayString appendAttributedString:as];
        [as release];
    }
}


- (void)consumeWhitespaceFrom:(PKAssembly *)a {
    NSMutableArray *whitespaceToks = [NSMutableArray array];
    PKToken *tok = nil;
    for (;;) {
        tok = [a pop];
        if (PKTokenTypeWhitespace == tok.tokenType) {
            [whitespaceToks addObject:tok];
        } else {
            [a push:tok];
            break;
        }
    }
    
    if ([whitespaceToks count]) {
        whitespaceToks = [whitespaceToks reversedMutableArray];
        [self appendAttributedStringForObjects:whitespaceToks withAttrs:defaultAttrs];
    }
}


- (void)parser:(PKParser *)p didMatchSymbolChar:(PKAssembly *)a {
    NSArray *objs = [NSArray arrayWithObject:[a pop]];
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:objs withAttrs:objectAttrs];
}


- (void)parser:(PKParser *)p didMatchPropertyName:(PKAssembly *)a {
    NSArray *objs = [NSArray arrayWithObject:[a pop]];
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:objs withAttrs:propertyNameAttrs];
}


- (void)parser:(PKParser *)p didMatchString:(PKAssembly *)a {
    NSArray *objs = [NSArray arrayWithObject:[a pop]];
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:objs withAttrs:arrayAttrs];
}


- (void)parser:(PKParser *)p didMatchNumber:(PKAssembly *)a {
    NSArray *objs = [NSArray arrayWithObject:[a pop]];
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:objs withAttrs:valueAttrs];
}


- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a {
    NSArray *objs = [NSArray arrayWithObject:[a pop]];
    [self consumeWhitespaceFrom:a];
    [self appendAttributedStringForObjects:objs withAttrs:constantAttrs];
}


- (void)parser:(PKParser *)p didMatchNull:(PKAssembly *)a { [self parser:p didMatchConstant:a]; }
- (void)parser:(PKParser *)p didMatchTrue:(PKAssembly *)a { [self parser:p didMatchConstant:a]; }
- (void)parser:(PKParser *)p didMatchFalse:(PKAssembly *)a { [self parser:p didMatchConstant:a]; }

- (void)parser:(PKParser *)p didMatchColon:(PKAssembly *)a { [self parser:p didMatchSymbolChar:a]; }
- (void)parser:(PKParser *)p didMatchComma:(PKAssembly *)a { [self parser:p didMatchSymbolChar:a]; }
- (void)parser:(PKParser *)p didMatchOpenCurly:(PKAssembly *)a { [self parser:p didMatchSymbolChar:a]; }
- (void)parser:(PKParser *)p didMatchCloseCurly:(PKAssembly *)a { [self parser:p didMatchSymbolChar:a]; }
- (void)parser:(PKParser *)p didMatchOpenBracket:(PKAssembly *)a { [self parser:p didMatchSymbolChar:a]; }
- (void)parser:(PKParser *)p didMatchCloseBracket:(PKAssembly *)a { [self parser:p didMatchSymbolChar:a]; }

@synthesize displayString;
@synthesize defaultAttrs;
@synthesize objectAttrs;
@synthesize arrayAttrs;
@synthesize propertyNameAttrs;
@synthesize valueAttrs;
@synthesize constantAttrs;
@synthesize comma;
@synthesize curly;
@synthesize bracket;
@end

