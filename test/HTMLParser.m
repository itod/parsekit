#import "HTMLParser.h"
#import <ParseKit/ParseKit.h>

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]
#define LS(i) [self LS:(i)]
#define LF(i) [self LF:(i)]

#define POP()       [self.assembly pop]
#define POP_STR()   [self _popString]
#define POP_TOK()   [self _popToken]
#define POP_BOOL()  [self _popBool]
#define POP_INT()   [self _popInteger]
#define POP_FLOAT() [self _popDouble]

#define PUSH(obj)     [self.assembly push:(id)(obj)]
#define PUSH_BOOL(yn) [self _pushBool:(BOOL)(yn)]
#define PUSH_INT(i)   [self _pushInteger:(NSInteger)(i)]
#define PUSH_FLOAT(f) [self _pushDouble:(double)(f)]

#define EQ(a, b) [(a) isEqual:(b)]
#define NE(a, b) (![(a) isEqual:(b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a) compare:(b)])

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PKSParser ()
@property (nonatomic, retain) NSMutableDictionary *_tokenKindTab;
@property (nonatomic, retain) NSMutableArray *_tokenKindNameTab;

- (BOOL)_popBool;
- (NSInteger)_popInteger;
- (double)_popDouble;
- (PKToken *)_popToken;
- (NSString *)_popString;

- (void)_pushBool:(BOOL)yn;
- (void)_pushInteger:(NSInteger)i;
- (void)_pushDouble:(double)d;
@end

@interface HTMLParser ()
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
        self._tokenKindTab[@"script"] = @(HTML_TOKEN_KIND_SCRIPTTAGNAME);
        self._tokenKindTab[@"style"] = @(HTML_TOKEN_KIND_STYLETAGNAME);
        self._tokenKindTab[@"<!DOCTYPE,>"] = @(HTML_TOKEN_KIND_DOCTYPE);
        self._tokenKindTab[@"<"] = @(HTML_TOKEN_KIND_LT);
        self._tokenKindTab[@"<?,?>"] = @(HTML_TOKEN_KIND_PROCINSTR);
        self._tokenKindTab[@"="] = @(HTML_TOKEN_KIND_EQ);
        self._tokenKindTab[@"/"] = @(HTML_TOKEN_KIND_FWDSLASH);
        self._tokenKindTab[@">"] = @(HTML_TOKEN_KIND_GT);

        self._tokenKindNameTab[HTML_TOKEN_KIND_SCRIPTTAGNAME] = @"script";
        self._tokenKindNameTab[HTML_TOKEN_KIND_STYLETAGNAME] = @"style";
        self._tokenKindNameTab[HTML_TOKEN_KIND_DOCTYPE] = @"<!DOCTYPE,>";
        self._tokenKindNameTab[HTML_TOKEN_KIND_LT] = @"<";
        self._tokenKindNameTab[HTML_TOKEN_KIND_PROCINSTR] = @"<?,?>";
        self._tokenKindNameTab[HTML_TOKEN_KIND_EQ] = @"=";
        self._tokenKindNameTab[HTML_TOKEN_KIND_FWDSLASH] = @"/";
        self._tokenKindNameTab[HTML_TOKEN_KIND_GT] = @">";

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

- (void)_start {
    
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
    while ([self predicts:HTML_TOKEN_KIND_DOCTYPE, HTML_TOKEN_KIND_LT, HTML_TOKEN_KIND_PROCINSTR, TOKEN_KIND_BUILTIN_ANY, TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        if ([self speculate:^{ [self anything]; }]) {
            [self anything]; 
        } else {
            break;
        }
    }
    [self matchEOF:YES]; 

}

- (void)__anything {
    
    if ([self speculate:^{ [self scriptElement]; }]) {
        [self scriptElement]; 
    } else if ([self speculate:^{ [self styleElement]; }]) {
        [self styleElement]; 
    } else if ([self speculate:^{ [self tag]; }]) {
        [self tag]; 
    } else if ([self speculate:^{ [self procInstr]; }]) {
        [self procInstr]; 
    } else if ([self speculate:^{ [self comment]; }]) {
        [self comment]; 
    } else if ([self speculate:^{ [self doctype]; }]) {
        [self doctype]; 
    } else if ([self speculate:^{ [self text]; }]) {
        [self text]; 
    } else {
        [self raise:@"No viable alternative found in rule 'anything'."];
    }

}

- (void)anything {
    [self parseRule:@selector(__anything) withMemo:_anything_memo];
}

- (void)__scriptElement {
    
    [self scriptStartTag]; 
    [self scriptElementContent]; 
    [self scriptEndTag]; 

}

- (void)scriptElement {
    [self parseRule:@selector(__scriptElement) withMemo:_scriptElement_memo];
}

- (void)__scriptStartTag {
    
    [self lt]; 
    [self scriptTagName]; 
    while ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self attr]; }]) {
            [self attr]; 
        } else {
            break;
        }
    }
    [self gt]; 

}

- (void)scriptStartTag {
    [self parseRule:@selector(__scriptStartTag) withMemo:_scriptStartTag_memo];
}

- (void)__scriptEndTag {
    
    [self lt]; 
    [self fwdSlash]; 
    [self scriptTagName]; 
    [self gt]; 

}

- (void)scriptEndTag {
    [self parseRule:@selector(__scriptEndTag) withMemo:_scriptEndTag_memo];
}

- (void)__scriptTagName {
    
    [self match:HTML_TOKEN_KIND_SCRIPTTAGNAME discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchScriptTagName:)];
}

- (void)scriptTagName {
    [self parseRule:@selector(__scriptTagName) withMemo:_scriptTagName_memo];
}

- (void)__scriptElementContent {
    
    if (![self speculate:^{ [self scriptEndTag]; }]) {
        [self match:TOKEN_KIND_BUILTIN_ANY discard:NO];
    } else {
        [self raise:@"negation test failed in scriptElementContent"];
    }

}

- (void)scriptElementContent {
    [self parseRule:@selector(__scriptElementContent) withMemo:_scriptElementContent_memo];
}

- (void)__styleElement {
    
    [self styleStartTag]; 
    [self styleElementContent]; 
    [self styleEndTag]; 

}

- (void)styleElement {
    [self parseRule:@selector(__styleElement) withMemo:_styleElement_memo];
}

- (void)__styleStartTag {
    
    [self lt]; 
    [self styleTagName]; 
    while ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self attr]; }]) {
            [self attr]; 
        } else {
            break;
        }
    }
    [self gt]; 

}

- (void)styleStartTag {
    [self parseRule:@selector(__styleStartTag) withMemo:_styleStartTag_memo];
}

- (void)__styleEndTag {
    
    [self lt]; 
    [self fwdSlash]; 
    [self styleTagName]; 
    [self gt]; 

}

- (void)styleEndTag {
    [self parseRule:@selector(__styleEndTag) withMemo:_styleEndTag_memo];
}

- (void)__styleTagName {
    
    [self match:HTML_TOKEN_KIND_STYLETAGNAME discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStyleTagName:)];
}

- (void)styleTagName {
    [self parseRule:@selector(__styleTagName) withMemo:_styleTagName_memo];
}

- (void)__styleElementContent {
    
    if (![self speculate:^{ [self styleEndTag]; }]) {
        [self match:TOKEN_KIND_BUILTIN_ANY discard:NO];
    } else {
        [self raise:@"negation test failed in styleElementContent"];
    }

}

- (void)styleElementContent {
    [self parseRule:@selector(__styleElementContent) withMemo:_styleElementContent_memo];
}

- (void)__procInstr {
    
    [self match:HTML_TOKEN_KIND_PROCINSTR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchProcInstr:)];
}

- (void)procInstr {
    [self parseRule:@selector(__procInstr) withMemo:_procInstr_memo];
}

- (void)__doctype {
    
    [self match:HTML_TOKEN_KIND_DOCTYPE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDoctype:)];
}

- (void)doctype {
    [self parseRule:@selector(__doctype) withMemo:_doctype_memo];
}

- (void)__text {
    
    [self matchAny:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchText:)];
}

- (void)text {
    [self parseRule:@selector(__text) withMemo:_text_memo];
}

- (void)__tag {
    
    if ([self speculate:^{ [self emptyTag]; }]) {
        [self emptyTag]; 
    } else if ([self speculate:^{ [self startTag]; }]) {
        [self startTag]; 
    } else if ([self speculate:^{ [self endTag]; }]) {
        [self endTag]; 
    } else {
        [self raise:@"No viable alternative found in rule 'tag'."];
    }

}

- (void)tag {
    [self parseRule:@selector(__tag) withMemo:_tag_memo];
}

- (void)__emptyTag {
    
    [self lt]; 
    [self tagName]; 
    while ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self attr]; }]) {
            [self attr]; 
        } else {
            break;
        }
    }
    [self fwdSlash]; 
    [self gt]; 

}

- (void)emptyTag {
    [self parseRule:@selector(__emptyTag) withMemo:_emptyTag_memo];
}

- (void)__startTag {
    
    [self lt]; 
    [self tagName]; 
    while ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self attr]; }]) {
            [self attr]; 
        } else {
            break;
        }
    }
    [self gt]; 

}

- (void)startTag {
    [self parseRule:@selector(__startTag) withMemo:_startTag_memo];
}

- (void)__endTag {
    
    [self lt]; 
    [self fwdSlash]; 
    [self tagName]; 
    [self gt]; 

}

- (void)endTag {
    [self parseRule:@selector(__endTag) withMemo:_endTag_memo];
}

- (void)__tagName {
    
    [self matchWord:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchTagName:)];
}

- (void)tagName {
    [self parseRule:@selector(__tagName) withMemo:_tagName_memo];
}

- (void)__attr {
    
    [self attrName]; 
    if ([self speculate:^{ [self eq]; if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {[self attrValue]; }}]) {
        [self eq]; 
        if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self attrValue]; 
        }
    }

}

- (void)attr {
    [self parseRule:@selector(__attr) withMemo:_attr_memo];
}

- (void)__attrName {
    
    [self matchWord:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchAttrName:)];
}

- (void)attrName {
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

- (void)attrValue {
    [self parseRule:@selector(__attrValue) withMemo:_attrValue_memo];
}

- (void)__eq {
    
    [self match:HTML_TOKEN_KIND_EQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)eq {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__lt {
    
    [self match:HTML_TOKEN_KIND_LT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)lt {
    [self parseRule:@selector(__lt) withMemo:_lt_memo];
}

- (void)__gt {
    
    [self match:HTML_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)gt {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__fwdSlash {
    
    [self match:HTML_TOKEN_KIND_FWDSLASH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFwdSlash:)];
}

- (void)fwdSlash {
    [self parseRule:@selector(__fwdSlash) withMemo:_fwdSlash_memo];
}

- (void)__comment {
    
    [self matchComment:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchComment:)];
}

- (void)comment {
    [self parseRule:@selector(__comment) withMemo:_comment_memo];
}

@end