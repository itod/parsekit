#import "HTMLParser.h"
#import <PEGKit/PEGKit.h>

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]
#define LS(i) [self LS:(i)]
#define LF(i) [self LF:(i)]

#define POP()       [self.assembly pop]
#define POP_STR()   [self popString]
#define POP_TOK()   [self popToken]
#define POP_BOOL()  [self popBool]
#define POP_INT()   [self popInteger]
#define POP_FLOAT() [self popDouble]

#define PUSH(obj)     [self.assembly push:(id)(obj)]
#define PUSH_BOOL(yn) [self pushBool:(BOOL)(yn)]
#define PUSH_INT(i)   [self pushInteger:(NSInteger)(i)]
#define PUSH_FLOAT(f) [self pushDouble:(double)(f)]

#define EQ(a, b) [(a) isEqual:(b)]
#define NE(a, b) (![(a) isEqual:(b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a) compare:(b)])

#define MATCHES(pattern, str)               ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:0                                  error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)
#define MATCHES_IGNORE_CASE(pattern, str)   ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:NSRegularExpressionCaseInsensitive error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PEGParser ()
@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
@property (nonatomic, retain) NSString *startRuleName;
@property (nonatomic, retain) NSString *statementTerminator;
@property (nonatomic, retain) NSString *singleLineCommentMarker;
@property (nonatomic, retain) NSString *blockStartMarker;
@property (nonatomic, retain) NSString *blockEndMarker;
@property (nonatomic, retain) NSString *braces;

- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;
@end

@interface HTMLParser ()
@property (nonatomic, retain) NSMutableDictionary *start_memo;
@property (nonatomic, retain) NSMutableDictionary *anything_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptElement_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptStartTag_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptEndTag_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptTagName_memo;
@property (nonatomic, retain) NSMutableDictionary *scriptElementContent_memo;
@property (nonatomic, retain) NSMutableDictionary *styleElement_memo;
@property (nonatomic, retain) NSMutableDictionary *styleStartTag_memo;
@property (nonatomic, retain) NSMutableDictionary *styleEndTag_memo;
@property (nonatomic, retain) NSMutableDictionary *styleTagName_memo;
@property (nonatomic, retain) NSMutableDictionary *styleElementContent_memo;
@property (nonatomic, retain) NSMutableDictionary *procInstr_memo;
@property (nonatomic, retain) NSMutableDictionary *doctype_memo;
@property (nonatomic, retain) NSMutableDictionary *text_memo;
@property (nonatomic, retain) NSMutableDictionary *tag_memo;
@property (nonatomic, retain) NSMutableDictionary *emptyTag_memo;
@property (nonatomic, retain) NSMutableDictionary *startTag_memo;
@property (nonatomic, retain) NSMutableDictionary *endTag_memo;
@property (nonatomic, retain) NSMutableDictionary *tagName_memo;
@property (nonatomic, retain) NSMutableDictionary *attr_memo;
@property (nonatomic, retain) NSMutableDictionary *attrName_memo;
@property (nonatomic, retain) NSMutableDictionary *attrValue_memo;
@property (nonatomic, retain) NSMutableDictionary *eq_memo;
@property (nonatomic, retain) NSMutableDictionary *lt_memo;
@property (nonatomic, retain) NSMutableDictionary *gt_memo;
@property (nonatomic, retain) NSMutableDictionary *fwdSlash_memo;
@property (nonatomic, retain) NSMutableDictionary *comment_memo;
@end

@implementation HTMLParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"start";
        self.tokenKindTab[@"script"] = @(HTML_TOKEN_KIND_SCRIPTTAGNAME);
        self.tokenKindTab[@"style"] = @(HTML_TOKEN_KIND_STYLETAGNAME);
        self.tokenKindTab[@"<!DOCTYPE,>"] = @(HTML_TOKEN_KIND_DOCTYPE);
        self.tokenKindTab[@"<"] = @(HTML_TOKEN_KIND_LT);
        self.tokenKindTab[@"<?,?>"] = @(HTML_TOKEN_KIND_PROCINSTR);
        self.tokenKindTab[@"="] = @(HTML_TOKEN_KIND_EQ);
        self.tokenKindTab[@"/"] = @(HTML_TOKEN_KIND_FWDSLASH);
        self.tokenKindTab[@">"] = @(HTML_TOKEN_KIND_GT);

        self.tokenKindNameTab[HTML_TOKEN_KIND_SCRIPTTAGNAME] = @"script";
        self.tokenKindNameTab[HTML_TOKEN_KIND_STYLETAGNAME] = @"style";
        self.tokenKindNameTab[HTML_TOKEN_KIND_DOCTYPE] = @"<!DOCTYPE,>";
        self.tokenKindNameTab[HTML_TOKEN_KIND_LT] = @"<";
        self.tokenKindNameTab[HTML_TOKEN_KIND_PROCINSTR] = @"<?,?>";
        self.tokenKindNameTab[HTML_TOKEN_KIND_EQ] = @"=";
        self.tokenKindNameTab[HTML_TOKEN_KIND_FWDSLASH] = @"/";
        self.tokenKindNameTab[HTML_TOKEN_KIND_GT] = @">";

        self.start_memo = [NSMutableDictionary dictionary];
        self.anything_memo = [NSMutableDictionary dictionary];
        self.scriptElement_memo = [NSMutableDictionary dictionary];
        self.scriptStartTag_memo = [NSMutableDictionary dictionary];
        self.scriptEndTag_memo = [NSMutableDictionary dictionary];
        self.scriptTagName_memo = [NSMutableDictionary dictionary];
        self.scriptElementContent_memo = [NSMutableDictionary dictionary];
        self.styleElement_memo = [NSMutableDictionary dictionary];
        self.styleStartTag_memo = [NSMutableDictionary dictionary];
        self.styleEndTag_memo = [NSMutableDictionary dictionary];
        self.styleTagName_memo = [NSMutableDictionary dictionary];
        self.styleElementContent_memo = [NSMutableDictionary dictionary];
        self.procInstr_memo = [NSMutableDictionary dictionary];
        self.doctype_memo = [NSMutableDictionary dictionary];
        self.text_memo = [NSMutableDictionary dictionary];
        self.tag_memo = [NSMutableDictionary dictionary];
        self.emptyTag_memo = [NSMutableDictionary dictionary];
        self.startTag_memo = [NSMutableDictionary dictionary];
        self.endTag_memo = [NSMutableDictionary dictionary];
        self.tagName_memo = [NSMutableDictionary dictionary];
        self.attr_memo = [NSMutableDictionary dictionary];
        self.attrName_memo = [NSMutableDictionary dictionary];
        self.attrValue_memo = [NSMutableDictionary dictionary];
        self.eq_memo = [NSMutableDictionary dictionary];
        self.lt_memo = [NSMutableDictionary dictionary];
        self.gt_memo = [NSMutableDictionary dictionary];
        self.fwdSlash_memo = [NSMutableDictionary dictionary];
        self.comment_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.start_memo = nil;
    self.anything_memo = nil;
    self.scriptElement_memo = nil;
    self.scriptStartTag_memo = nil;
    self.scriptEndTag_memo = nil;
    self.scriptTagName_memo = nil;
    self.scriptElementContent_memo = nil;
    self.styleElement_memo = nil;
    self.styleStartTag_memo = nil;
    self.styleEndTag_memo = nil;
    self.styleTagName_memo = nil;
    self.styleElementContent_memo = nil;
    self.procInstr_memo = nil;
    self.doctype_memo = nil;
    self.text_memo = nil;
    self.tag_memo = nil;
    self.emptyTag_memo = nil;
    self.startTag_memo = nil;
    self.endTag_memo = nil;
    self.tagName_memo = nil;
    self.attr_memo = nil;
    self.attrName_memo = nil;
    self.attrValue_memo = nil;
    self.eq_memo = nil;
    self.lt_memo = nil;
    self.gt_memo = nil;
    self.fwdSlash_memo = nil;
    self.comment_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_start_memo removeAllObjects];
    [_anything_memo removeAllObjects];
    [_scriptElement_memo removeAllObjects];
    [_scriptStartTag_memo removeAllObjects];
    [_scriptEndTag_memo removeAllObjects];
    [_scriptTagName_memo removeAllObjects];
    [_scriptElementContent_memo removeAllObjects];
    [_styleElement_memo removeAllObjects];
    [_styleStartTag_memo removeAllObjects];
    [_styleEndTag_memo removeAllObjects];
    [_styleTagName_memo removeAllObjects];
    [_styleElementContent_memo removeAllObjects];
    [_procInstr_memo removeAllObjects];
    [_doctype_memo removeAllObjects];
    [_text_memo removeAllObjects];
    [_tag_memo removeAllObjects];
    [_emptyTag_memo removeAllObjects];
    [_startTag_memo removeAllObjects];
    [_endTag_memo removeAllObjects];
    [_tagName_memo removeAllObjects];
    [_attr_memo removeAllObjects];
    [_attrName_memo removeAllObjects];
    [_attrValue_memo removeAllObjects];
    [_eq_memo removeAllObjects];
    [_lt_memo removeAllObjects];
    [_gt_memo removeAllObjects];
    [_fwdSlash_memo removeAllObjects];
    [_comment_memo removeAllObjects];
}

- (void)start {
    [self start_];
}

- (void)__start {
    
    [self execute:(id)^{
    
    PKTokenizer *t = self.tokenizer;

    // whitespace
//    self.silentlyConsumesWhitespace = YES;
//    t.whitespaceState.reportsWhitespaceTokens = YES;
//    self.assembly.preservesWhitespaceTokens = YES;

    // symbols
    [t.symbolState add:@"<!--"];
    [t.symbolState add:@"-->"];
    [t.symbolState add:@"<?"];
    [t.symbolState add:@"?>"];

	// comments	
    [t setTokenizerState:t.commentState from:'<' to:'<'];
    [t.commentState addMultiLineStartMarker:@"<!--" endMarker:@"-->"];
    [t.commentState setFallbackState:t.delimitState from:'<' to:'<'];
	t.commentState.reportsCommentTokens = YES;

	// pi
	[t.delimitState addStartMarker:@"<?" endMarker:@"?>" allowedCharacterSet:nil];
	
	// doctype
	[t.delimitState addStartMarker:@"<!DOCTYPE" endMarker:@">" allowedCharacterSet:nil];
	
    [t.delimitState setFallbackState:t.symbolState from:'<' to:'<'];

    }];
    while ([self speculate:^{ [self anything_]; }]) {
        [self anything_]; 
    }
    [self matchEOF:YES]; 

}

- (void)start_ {
    [self parseRule:@selector(__start) withMemo:_start_memo];
}

- (void)__anything {
    
    if ([self speculate:^{ [self scriptElement_]; }]) {
        [self scriptElement_]; 
    } else if ([self speculate:^{ [self styleElement_]; }]) {
        [self styleElement_]; 
    } else if ([self speculate:^{ [self tag_]; }]) {
        [self tag_]; 
    } else if ([self speculate:^{ [self procInstr_]; }]) {
        [self procInstr_]; 
    } else if ([self speculate:^{ [self comment_]; }]) {
        [self comment_]; 
    } else if ([self speculate:^{ [self doctype_]; }]) {
        [self doctype_]; 
    } else if ([self speculate:^{ [self text_]; }]) {
        [self text_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'anything'."];
    }

}

- (void)anything_ {
    [self parseRule:@selector(__anything) withMemo:_anything_memo];
}

- (void)__scriptElement {
    
    [self scriptStartTag_]; 
    [self scriptElementContent_]; 
    [self scriptEndTag_]; 

}

- (void)scriptElement_ {
    [self parseRule:@selector(__scriptElement) withMemo:_scriptElement_memo];
}

- (void)__scriptStartTag {
    
    [self lt_]; 
    [self scriptTagName_]; 
    while ([self speculate:^{ [self attr_]; }]) {
        [self attr_]; 
    }
    [self gt_]; 

}

- (void)scriptStartTag_ {
    [self parseRule:@selector(__scriptStartTag) withMemo:_scriptStartTag_memo];
}

- (void)__scriptEndTag {
    
    [self lt_]; 
    [self fwdSlash_]; 
    [self scriptTagName_]; 
    [self gt_]; 

}

- (void)scriptEndTag_ {
    [self parseRule:@selector(__scriptEndTag) withMemo:_scriptEndTag_memo];
}

- (void)__scriptTagName {
    
    [self match:HTML_TOKEN_KIND_SCRIPTTAGNAME discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchScriptTagName:)];
}

- (void)scriptTagName_ {
    [self parseRule:@selector(__scriptTagName) withMemo:_scriptTagName_memo];
}

- (void)__scriptElementContent {
    
    if (![self speculate:^{ [self scriptEndTag_]; }]) {
        [self match:TOKEN_KIND_BUILTIN_ANY discard:NO];
    } else {
        [self raise:@"negation test failed in scriptElementContent"];
    }

}

- (void)scriptElementContent_ {
    [self parseRule:@selector(__scriptElementContent) withMemo:_scriptElementContent_memo];
}

- (void)__styleElement {
    
    [self styleStartTag_]; 
    [self styleElementContent_]; 
    [self styleEndTag_]; 

}

- (void)styleElement_ {
    [self parseRule:@selector(__styleElement) withMemo:_styleElement_memo];
}

- (void)__styleStartTag {
    
    [self lt_]; 
    [self styleTagName_]; 
    while ([self speculate:^{ [self attr_]; }]) {
        [self attr_]; 
    }
    [self gt_]; 

}

- (void)styleStartTag_ {
    [self parseRule:@selector(__styleStartTag) withMemo:_styleStartTag_memo];
}

- (void)__styleEndTag {
    
    [self lt_]; 
    [self fwdSlash_]; 
    [self styleTagName_]; 
    [self gt_]; 

}

- (void)styleEndTag_ {
    [self parseRule:@selector(__styleEndTag) withMemo:_styleEndTag_memo];
}

- (void)__styleTagName {
    
    [self match:HTML_TOKEN_KIND_STYLETAGNAME discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStyleTagName:)];
}

- (void)styleTagName_ {
    [self parseRule:@selector(__styleTagName) withMemo:_styleTagName_memo];
}

- (void)__styleElementContent {
    
    if (![self speculate:^{ [self styleEndTag_]; }]) {
        [self match:TOKEN_KIND_BUILTIN_ANY discard:NO];
    } else {
        [self raise:@"negation test failed in styleElementContent"];
    }

}

- (void)styleElementContent_ {
    [self parseRule:@selector(__styleElementContent) withMemo:_styleElementContent_memo];
}

- (void)__procInstr {
    
    [self match:HTML_TOKEN_KIND_PROCINSTR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchProcInstr:)];
}

- (void)procInstr_ {
    [self parseRule:@selector(__procInstr) withMemo:_procInstr_memo];
}

- (void)__doctype {
    
    [self match:HTML_TOKEN_KIND_DOCTYPE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDoctype:)];
}

- (void)doctype_ {
    [self parseRule:@selector(__doctype) withMemo:_doctype_memo];
}

- (void)__text {
    
    [self matchAny:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchText:)];
}

- (void)text_ {
    [self parseRule:@selector(__text) withMemo:_text_memo];
}

- (void)__tag {
    
    if ([self speculate:^{ [self emptyTag_]; }]) {
        [self emptyTag_]; 
    } else if ([self speculate:^{ [self startTag_]; }]) {
        [self startTag_]; 
    } else if ([self speculate:^{ [self endTag_]; }]) {
        [self endTag_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'tag'."];
    }

}

- (void)tag_ {
    [self parseRule:@selector(__tag) withMemo:_tag_memo];
}

- (void)__emptyTag {
    
    [self lt_]; 
    [self tagName_]; 
    while ([self speculate:^{ [self attr_]; }]) {
        [self attr_]; 
    }
    [self fwdSlash_]; 
    [self gt_]; 

}

- (void)emptyTag_ {
    [self parseRule:@selector(__emptyTag) withMemo:_emptyTag_memo];
}

- (void)__startTag {
    
    [self lt_]; 
    [self tagName_]; 
    while ([self speculate:^{ [self attr_]; }]) {
        [self attr_]; 
    }
    [self gt_]; 

}

- (void)startTag_ {
    [self parseRule:@selector(__startTag) withMemo:_startTag_memo];
}

- (void)__endTag {
    
    [self lt_]; 
    [self fwdSlash_]; 
    [self tagName_]; 
    [self gt_]; 

}

- (void)endTag_ {
    [self parseRule:@selector(__endTag) withMemo:_endTag_memo];
}

- (void)__tagName {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTagName:)];
}

- (void)tagName_ {
    [self parseRule:@selector(__tagName) withMemo:_tagName_memo];
}

- (void)__attr {
    
    [self attrName_]; 
    if ([self speculate:^{ [self eq_]; if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {[self attrValue_]; }}]) {
        [self eq_]; 
        if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self attrValue_]; 
        }
    }

}

- (void)attr_ {
    [self parseRule:@selector(__attr) withMemo:_attr_memo];
}

- (void)__attrName {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAttrName:)];
}

- (void)attrName_ {
    [self parseRule:@selector(__attrName) withMemo:_attrName_memo];
}

- (void)__attrValue {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self matchWord:NO]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self matchQuotedString:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'attrValue'."];
    }

}

- (void)attrValue_ {
    [self parseRule:@selector(__attrValue) withMemo:_attrValue_memo];
}

- (void)__eq {
    
    [self match:HTML_TOKEN_KIND_EQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)eq_ {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__lt {
    
    [self match:HTML_TOKEN_KIND_LT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)lt_ {
    [self parseRule:@selector(__lt) withMemo:_lt_memo];
}

- (void)__gt {
    
    [self match:HTML_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)gt_ {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__fwdSlash {
    
    [self match:HTML_TOKEN_KIND_FWDSLASH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFwdSlash:)];
}

- (void)fwdSlash_ {
    [self parseRule:@selector(__fwdSlash) withMemo:_fwdSlash_memo];
}

- (void)__comment {
    
    [self matchComment:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComment:)];
}

- (void)comment_ {
    [self parseRule:@selector(__comment) withMemo:_comment_memo];
}

@end