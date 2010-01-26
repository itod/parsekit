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

#import <Cocoa/Cocoa.h>

@class PKTokenizer;
@class PKToken;

@interface TDHtmlSyntaxHighlighter : NSObject {
    BOOL isDarkBG;
    BOOL inScript;
    PKTokenizer *tokenizer;
    NSMutableArray *stack;
    PKToken *ltToken;
    PKToken *gtToken;
    PKToken *startCommentToken;
    PKToken *endCommentToken;
    PKToken *startCDATAToken;
    PKToken *endCDATAToken;
    PKToken *startPIToken;
    PKToken *endPIToken;
    PKToken *startDoctypeToken;
    PKToken *fwdSlashToken;
    PKToken *eqToken;
    PKToken *scriptToken;
    PKToken *endScriptToken;
    
    NSMutableAttributedString *highlightedString;
    NSDictionary *tagAttributes;
    NSDictionary *textAttributes;
    NSDictionary *attrNameAttributes;
    NSDictionary *attrValueAttributes;
    NSDictionary *eqAttributes;
    NSDictionary *commentAttributes;
    NSDictionary *piAttributes;
}
- (id)initWithAttributesForDarkBackground:(BOOL)isDark;

- (NSAttributedString *)attributedStringForString:(NSString *)s;

@property (nonatomic, retain) NSMutableAttributedString *highlightedString;
@property (nonatomic, retain) NSDictionary *tagAttributes;
@property (nonatomic, retain) NSDictionary *textAttributes;
@property (nonatomic, retain) NSDictionary *attrNameAttributes;
@property (nonatomic, retain) NSDictionary *attrValueAttributes;
@property (nonatomic, retain) NSDictionary *eqAttributes;
@property (nonatomic, retain) NSDictionary *commentAttributes;
@property (nonatomic, retain) NSDictionary *piAttributes;
@end
