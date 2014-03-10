#import "CSSParser.h"
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

@interface CSSParser ()
@property (nonatomic, retain) NSMutableDictionary *stylesheet_memo;
@property (nonatomic, retain) NSMutableDictionary *ruleset_memo;
@property (nonatomic, retain) NSMutableDictionary *selectors_memo;
@property (nonatomic, retain) NSMutableDictionary *selector_memo;
@property (nonatomic, retain) NSMutableDictionary *selectorWord_memo;
@property (nonatomic, retain) NSMutableDictionary *selectorQuotedString_memo;
@property (nonatomic, retain) NSMutableDictionary *commaSelector_memo;
@property (nonatomic, retain) NSMutableDictionary *decls_memo;
@property (nonatomic, retain) NSMutableDictionary *actualDecls_memo;
@property (nonatomic, retain) NSMutableDictionary *decl_memo;
@property (nonatomic, retain) NSMutableDictionary *property_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *url_memo;
@property (nonatomic, retain) NSMutableDictionary *urlLower_memo;
@property (nonatomic, retain) NSMutableDictionary *urlUpper_memo;
@property (nonatomic, retain) NSMutableDictionary *nonTerminatingSymbol_memo;
@property (nonatomic, retain) NSMutableDictionary *important_memo;
@property (nonatomic, retain) NSMutableDictionary *string_memo;
@property (nonatomic, retain) NSMutableDictionary *constant_memo;
@property (nonatomic, retain) NSMutableDictionary *openCurly_memo;
@property (nonatomic, retain) NSMutableDictionary *closeCurly_memo;
@property (nonatomic, retain) NSMutableDictionary *openBracket_memo;
@property (nonatomic, retain) NSMutableDictionary *closeBracket_memo;
@property (nonatomic, retain) NSMutableDictionary *eq_memo;
@property (nonatomic, retain) NSMutableDictionary *comma_memo;
@property (nonatomic, retain) NSMutableDictionary *colon_memo;
@property (nonatomic, retain) NSMutableDictionary *semi_memo;
@property (nonatomic, retain) NSMutableDictionary *openParen_memo;
@property (nonatomic, retain) NSMutableDictionary *closeParen_memo;
@property (nonatomic, retain) NSMutableDictionary *gt_memo;
@property (nonatomic, retain) NSMutableDictionary *tilde_memo;
@property (nonatomic, retain) NSMutableDictionary *pipe_memo;
@property (nonatomic, retain) NSMutableDictionary *fwdSlash_memo;
@property (nonatomic, retain) NSMutableDictionary *hash_memo;
@property (nonatomic, retain) NSMutableDictionary *dot_memo;
@property (nonatomic, retain) NSMutableDictionary *at_memo;
@property (nonatomic, retain) NSMutableDictionary *bang_memo;
@property (nonatomic, retain) NSMutableDictionary *num_memo;
@end

@implementation CSSParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"stylesheet";
        self.tokenKindTab[@","] = @(CSS_TOKEN_KIND_COMMA);
        self.tokenKindTab[@":"] = @(CSS_TOKEN_KIND_COLON);
        self.tokenKindTab[@"~"] = @(CSS_TOKEN_KIND_TILDE);
        self.tokenKindTab[@";"] = @(CSS_TOKEN_KIND_SEMI);
        self.tokenKindTab[@"."] = @(CSS_TOKEN_KIND_DOT);
        self.tokenKindTab[@"!"] = @(CSS_TOKEN_KIND_BANG);
        self.tokenKindTab[@"/"] = @(CSS_TOKEN_KIND_FWDSLASH);
        self.tokenKindTab[@"="] = @(CSS_TOKEN_KIND_EQ);
        self.tokenKindTab[@">"] = @(CSS_TOKEN_KIND_GT);
        self.tokenKindTab[@"#"] = @(CSS_TOKEN_KIND_HASH);
        self.tokenKindTab[@"["] = @(CSS_TOKEN_KIND_OPENBRACKET);
        self.tokenKindTab[@"@"] = @(CSS_TOKEN_KIND_AT);
        self.tokenKindTab[@"]"] = @(CSS_TOKEN_KIND_CLOSEBRACKET);
        self.tokenKindTab[@"("] = @(CSS_TOKEN_KIND_OPENPAREN);
        self.tokenKindTab[@"{"] = @(CSS_TOKEN_KIND_OPENCURLY);
        self.tokenKindTab[@"URL(,)"] = @(CSS_TOKEN_KIND_URLUPPER);
        self.tokenKindTab[@"url(,)"] = @(CSS_TOKEN_KIND_URLLOWER);
        self.tokenKindTab[@"|"] = @(CSS_TOKEN_KIND_PIPE);
        self.tokenKindTab[@")"] = @(CSS_TOKEN_KIND_CLOSEPAREN);
        self.tokenKindTab[@"}"] = @(CSS_TOKEN_KIND_CLOSECURLY);

        self.tokenKindNameTab[CSS_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[CSS_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[CSS_TOKEN_KIND_TILDE] = @"~";
        self.tokenKindNameTab[CSS_TOKEN_KIND_SEMI] = @";";
        self.tokenKindNameTab[CSS_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[CSS_TOKEN_KIND_BANG] = @"!";
        self.tokenKindNameTab[CSS_TOKEN_KIND_FWDSLASH] = @"/";
        self.tokenKindNameTab[CSS_TOKEN_KIND_EQ] = @"=";
        self.tokenKindNameTab[CSS_TOKEN_KIND_GT] = @">";
        self.tokenKindNameTab[CSS_TOKEN_KIND_HASH] = @"#";
        self.tokenKindNameTab[CSS_TOKEN_KIND_OPENBRACKET] = @"[";
        self.tokenKindNameTab[CSS_TOKEN_KIND_AT] = @"@";
        self.tokenKindNameTab[CSS_TOKEN_KIND_CLOSEBRACKET] = @"]";
        self.tokenKindNameTab[CSS_TOKEN_KIND_OPENPAREN] = @"(";
        self.tokenKindNameTab[CSS_TOKEN_KIND_OPENCURLY] = @"{";
        self.tokenKindNameTab[CSS_TOKEN_KIND_URLUPPER] = @"URL(,)";
        self.tokenKindNameTab[CSS_TOKEN_KIND_URLLOWER] = @"url(,)";
        self.tokenKindNameTab[CSS_TOKEN_KIND_PIPE] = @"|";
        self.tokenKindNameTab[CSS_TOKEN_KIND_CLOSEPAREN] = @")";
        self.tokenKindNameTab[CSS_TOKEN_KIND_CLOSECURLY] = @"}";

        self.stylesheet_memo = [NSMutableDictionary dictionary];
        self.ruleset_memo = [NSMutableDictionary dictionary];
        self.selectors_memo = [NSMutableDictionary dictionary];
        self.selector_memo = [NSMutableDictionary dictionary];
        self.selectorWord_memo = [NSMutableDictionary dictionary];
        self.selectorQuotedString_memo = [NSMutableDictionary dictionary];
        self.commaSelector_memo = [NSMutableDictionary dictionary];
        self.decls_memo = [NSMutableDictionary dictionary];
        self.actualDecls_memo = [NSMutableDictionary dictionary];
        self.decl_memo = [NSMutableDictionary dictionary];
        self.property_memo = [NSMutableDictionary dictionary];
        self.expr_memo = [NSMutableDictionary dictionary];
        self.url_memo = [NSMutableDictionary dictionary];
        self.urlLower_memo = [NSMutableDictionary dictionary];
        self.urlUpper_memo = [NSMutableDictionary dictionary];
        self.nonTerminatingSymbol_memo = [NSMutableDictionary dictionary];
        self.important_memo = [NSMutableDictionary dictionary];
        self.string_memo = [NSMutableDictionary dictionary];
        self.constant_memo = [NSMutableDictionary dictionary];
        self.openCurly_memo = [NSMutableDictionary dictionary];
        self.closeCurly_memo = [NSMutableDictionary dictionary];
        self.openBracket_memo = [NSMutableDictionary dictionary];
        self.closeBracket_memo = [NSMutableDictionary dictionary];
        self.eq_memo = [NSMutableDictionary dictionary];
        self.comma_memo = [NSMutableDictionary dictionary];
        self.colon_memo = [NSMutableDictionary dictionary];
        self.semi_memo = [NSMutableDictionary dictionary];
        self.openParen_memo = [NSMutableDictionary dictionary];
        self.closeParen_memo = [NSMutableDictionary dictionary];
        self.gt_memo = [NSMutableDictionary dictionary];
        self.tilde_memo = [NSMutableDictionary dictionary];
        self.pipe_memo = [NSMutableDictionary dictionary];
        self.fwdSlash_memo = [NSMutableDictionary dictionary];
        self.hash_memo = [NSMutableDictionary dictionary];
        self.dot_memo = [NSMutableDictionary dictionary];
        self.at_memo = [NSMutableDictionary dictionary];
        self.bang_memo = [NSMutableDictionary dictionary];
        self.num_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.stylesheet_memo = nil;
    self.ruleset_memo = nil;
    self.selectors_memo = nil;
    self.selector_memo = nil;
    self.selectorWord_memo = nil;
    self.selectorQuotedString_memo = nil;
    self.commaSelector_memo = nil;
    self.decls_memo = nil;
    self.actualDecls_memo = nil;
    self.decl_memo = nil;
    self.property_memo = nil;
    self.expr_memo = nil;
    self.url_memo = nil;
    self.urlLower_memo = nil;
    self.urlUpper_memo = nil;
    self.nonTerminatingSymbol_memo = nil;
    self.important_memo = nil;
    self.string_memo = nil;
    self.constant_memo = nil;
    self.openCurly_memo = nil;
    self.closeCurly_memo = nil;
    self.openBracket_memo = nil;
    self.closeBracket_memo = nil;
    self.eq_memo = nil;
    self.comma_memo = nil;
    self.colon_memo = nil;
    self.semi_memo = nil;
    self.openParen_memo = nil;
    self.closeParen_memo = nil;
    self.gt_memo = nil;
    self.tilde_memo = nil;
    self.pipe_memo = nil;
    self.fwdSlash_memo = nil;
    self.hash_memo = nil;
    self.dot_memo = nil;
    self.at_memo = nil;
    self.bang_memo = nil;
    self.num_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_stylesheet_memo removeAllObjects];
    [_ruleset_memo removeAllObjects];
    [_selectors_memo removeAllObjects];
    [_selector_memo removeAllObjects];
    [_selectorWord_memo removeAllObjects];
    [_selectorQuotedString_memo removeAllObjects];
    [_commaSelector_memo removeAllObjects];
    [_decls_memo removeAllObjects];
    [_actualDecls_memo removeAllObjects];
    [_decl_memo removeAllObjects];
    [_property_memo removeAllObjects];
    [_expr_memo removeAllObjects];
    [_url_memo removeAllObjects];
    [_urlLower_memo removeAllObjects];
    [_urlUpper_memo removeAllObjects];
    [_nonTerminatingSymbol_memo removeAllObjects];
    [_important_memo removeAllObjects];
    [_string_memo removeAllObjects];
    [_constant_memo removeAllObjects];
    [_openCurly_memo removeAllObjects];
    [_closeCurly_memo removeAllObjects];
    [_openBracket_memo removeAllObjects];
    [_closeBracket_memo removeAllObjects];
    [_eq_memo removeAllObjects];
    [_comma_memo removeAllObjects];
    [_colon_memo removeAllObjects];
    [_semi_memo removeAllObjects];
    [_openParen_memo removeAllObjects];
    [_closeParen_memo removeAllObjects];
    [_gt_memo removeAllObjects];
    [_tilde_memo removeAllObjects];
    [_pipe_memo removeAllObjects];
    [_fwdSlash_memo removeAllObjects];
    [_hash_memo removeAllObjects];
    [_dot_memo removeAllObjects];
    [_at_memo removeAllObjects];
    [_bang_memo removeAllObjects];
    [_num_memo removeAllObjects];
}

- (void)start {
    [self stylesheet_];
}

- (void)__stylesheet {
    
    [self execute:(id)^{
    
    PKTokenizer *t = self.tokenizer;

    // whitespace
//    self.silentlyConsumesWhitespace = YES;
//    t.whitespaceState.reportsWhitespaceTokens = YES;
//    self.assembly.preservesWhitespaceTokens = YES;

    // symbols
    [t.symbolState add:@"/*"];
    [t.symbolState add:@"*/"];
    [t.symbolState add:@"//"];
    [t.symbolState add:@"url("];
    [t.symbolState add:@"URL("];

    // word chars -moz, -webkit, @media, #id, .class, :hover
    [t setTokenizerState:t.wordState from:'-' to:'-'];
    [t setTokenizerState:t.wordState from:'@' to:'@'];
    [t setTokenizerState:t.wordState from:'.' to:'.'];
    [t setTokenizerState:t.wordState from:'#' to:'#'];
    [t.wordState setWordChars:YES from:'-' to:'-'];
    [t.wordState setWordChars:YES from:'@' to:'@'];
    [t.wordState setWordChars:YES from:'.' to:'.'];
    [t.wordState setWordChars:YES from:'#' to:'#'];
/*    [t.wordState setFallbackState:t.symbolState from:'-' to:'-'];
    [t.wordState setFallbackState:t.symbolState from:'@' to:'@'];
    [t.wordState setFallbackState:t.symbolState from:'.' to:'.'];
    [t.wordState setFallbackState:t.symbolState from:'#' to:'#'];
*/
    // comments
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    [t.commentState setFallbackState:t.symbolState from:'/' to:'/'];
    [t.commentState addSingleLineStartMarker:@"//"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    t.commentState.reportsCommentTokens = YES;

	// urls
    [t setTokenizerState:t.delimitState from:'u' to:'u'];
    [t setTokenizerState:t.delimitState from:'U' to:'U'];
	[t.delimitState addStartMarker:@"url(" endMarker:@")" allowedCharacterSet:nil];
	[t.delimitState addStartMarker:@"URL(" endMarker:@")" allowedCharacterSet:nil];

    }];
    while ([self speculate:^{ [self ruleset_]; }]) {
        [self ruleset_]; 
    }
    [self matchEOF:YES]; 

}

- (void)stylesheet_ {
    [self parseRule:@selector(__stylesheet) withMemo:_stylesheet_memo];
}

- (void)__ruleset {
    
    [self selectors_]; 
    [self openCurly_]; 
    [self decls_]; 
    [self closeCurly_]; 

}

- (void)ruleset_ {
    [self parseRule:@selector(__ruleset) withMemo:_ruleset_memo];
}

- (void)__selectors {
    
    [self selector_]; 
    while ([self speculate:^{ [self commaSelector_]; }]) {
        [self commaSelector_]; 
    }

}

- (void)selectors_ {
    [self parseRule:@selector(__selectors) withMemo:_selectors_memo];
}

- (void)__selector {
    
    do {
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self selectorWord_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_HASH, 0]) {
            [self hash_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_DOT, 0]) {
            [self dot_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_COLON, 0]) {
            [self colon_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_GT, 0]) {
            [self gt_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_OPENBRACKET, 0]) {
            [self openBracket_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_CLOSEBRACKET, 0]) {
            [self closeBracket_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_EQ, 0]) {
            [self eq_]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
            [self selectorQuotedString_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_TILDE, 0]) {
            [self tilde_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_PIPE, 0]) {
            [self pipe_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'selector'."];
        }
    } while ([self predicts:CSS_TOKEN_KIND_CLOSEBRACKET, CSS_TOKEN_KIND_COLON, CSS_TOKEN_KIND_DOT, CSS_TOKEN_KIND_EQ, CSS_TOKEN_KIND_GT, CSS_TOKEN_KIND_HASH, CSS_TOKEN_KIND_OPENBRACKET, CSS_TOKEN_KIND_PIPE, CSS_TOKEN_KIND_TILDE, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]);

}

- (void)selector_ {
    [self parseRule:@selector(__selector) withMemo:_selector_memo];
}

- (void)__selectorWord {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSelectorWord:)];
}

- (void)selectorWord_ {
    [self parseRule:@selector(__selectorWord) withMemo:_selectorWord_memo];
}

- (void)__selectorQuotedString {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSelectorQuotedString:)];
}

- (void)selectorQuotedString_ {
    [self parseRule:@selector(__selectorQuotedString) withMemo:_selectorQuotedString_memo];
}

- (void)__commaSelector {
    
    [self comma_]; 
    [self selector_]; 

}

- (void)commaSelector_ {
    [self parseRule:@selector(__commaSelector) withMemo:_commaSelector_memo];
}

- (void)__decls {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self actualDecls_]; 
    }

}

- (void)decls_ {
    [self parseRule:@selector(__decls) withMemo:_decls_memo];
}

- (void)__actualDecls {
    
    [self decl_]; 
    while ([self speculate:^{ [self decl_]; }]) {
        [self decl_]; 
    }

}

- (void)actualDecls_ {
    [self parseRule:@selector(__actualDecls) withMemo:_actualDecls_memo];
}

- (void)__decl {
    
    [self property_]; 
    [self colon_]; 
    [self expr_]; 
    if ([self speculate:^{ [self important_]; }]) {
        [self important_]; 
    }
    [self semi_]; 

}

- (void)decl_ {
    [self parseRule:@selector(__decl) withMemo:_decl_memo];
}

- (void)__property {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchProperty:)];
}

- (void)property_ {
    [self parseRule:@selector(__property) withMemo:_property_memo];
}

- (void)__expr {
    
    do {
        if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
            [self string_]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self constant_]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
            [self num_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_URLLOWER, CSS_TOKEN_KIND_URLUPPER, 0]) {
            [self url_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_OPENPAREN, 0]) {
            [self openParen_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_CLOSEPAREN, 0]) {
            [self closeParen_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_COMMA, 0]) {
            [self comma_]; 
        } else if ([self predicts:CSS_TOKEN_KIND_FWDSLASH, TOKEN_KIND_BUILTIN_SYMBOL, 0]) {
            [self nonTerminatingSymbol_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'expr'."];
        }
    } while ([self predicts:CSS_TOKEN_KIND_CLOSEPAREN, CSS_TOKEN_KIND_COMMA, CSS_TOKEN_KIND_FWDSLASH, CSS_TOKEN_KIND_OPENPAREN, CSS_TOKEN_KIND_URLLOWER, CSS_TOKEN_KIND_URLUPPER, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_SYMBOL, TOKEN_KIND_BUILTIN_WORD, 0]);

}

- (void)expr_ {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__url {
    
    if ([self predicts:CSS_TOKEN_KIND_URLLOWER, 0]) {
        [self urlLower_]; 
    } else if ([self predicts:CSS_TOKEN_KIND_URLUPPER, 0]) {
        [self urlUpper_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'url'."];
    }

}

- (void)url_ {
    [self parseRule:@selector(__url) withMemo:_url_memo];
}

- (void)__urlLower {
    
    [self match:CSS_TOKEN_KIND_URLLOWER discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUrlLower:)];
}

- (void)urlLower_ {
    [self parseRule:@selector(__urlLower) withMemo:_urlLower_memo];
}

- (void)__urlUpper {
    
    [self match:CSS_TOKEN_KIND_URLUPPER discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUrlUpper:)];
}

- (void)urlUpper_ {
    [self parseRule:@selector(__urlUpper) withMemo:_urlUpper_memo];
}

- (void)__nonTerminatingSymbol {
    
    if ([self predicts:CSS_TOKEN_KIND_FWDSLASH, 0]) {
        [self testAndThrow:(id)^{ return NE(LS(1), @";") && NE(LS(1), @"!"); }]; 
        [self fwdSlash_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_SYMBOL, 0]) {
        [self matchSymbol:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'nonTerminatingSymbol'."];
    }

}

- (void)nonTerminatingSymbol_ {
    [self parseRule:@selector(__nonTerminatingSymbol) withMemo:_nonTerminatingSymbol_memo];
}

- (void)__important {
    
    [self bang_]; 
    [self matchWord:NO]; 

}

- (void)important_ {
    [self parseRule:@selector(__important) withMemo:_important_memo];
}

- (void)__string {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchString:)];
}

- (void)string_ {
    [self parseRule:@selector(__string) withMemo:_string_memo];
}

- (void)__constant {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchConstant:)];
}

- (void)constant_ {
    [self parseRule:@selector(__constant) withMemo:_constant_memo];
}

- (void)__openCurly {
    
    [self match:CSS_TOKEN_KIND_OPENCURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenCurly:)];
}

- (void)openCurly_ {
    [self parseRule:@selector(__openCurly) withMemo:_openCurly_memo];
}

- (void)__closeCurly {
    
    [self match:CSS_TOKEN_KIND_CLOSECURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseCurly:)];
}

- (void)closeCurly_ {
    [self parseRule:@selector(__closeCurly) withMemo:_closeCurly_memo];
}

- (void)__openBracket {
    
    [self match:CSS_TOKEN_KIND_OPENBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenBracket:)];
}

- (void)openBracket_ {
    [self parseRule:@selector(__openBracket) withMemo:_openBracket_memo];
}

- (void)__closeBracket {
    
    [self match:CSS_TOKEN_KIND_CLOSEBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseBracket:)];
}

- (void)closeBracket_ {
    [self parseRule:@selector(__closeBracket) withMemo:_closeBracket_memo];
}

- (void)__eq {
    
    [self match:CSS_TOKEN_KIND_EQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)eq_ {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__comma {
    
    [self match:CSS_TOKEN_KIND_COMMA discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)comma_ {
    [self parseRule:@selector(__comma) withMemo:_comma_memo];
}

- (void)__colon {
    
    [self match:CSS_TOKEN_KIND_COLON discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchColon:)];
}

- (void)colon_ {
    [self parseRule:@selector(__colon) withMemo:_colon_memo];
}

- (void)__semi {
    
    [self match:CSS_TOKEN_KIND_SEMI discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemi:)];
}

- (void)semi_ {
    [self parseRule:@selector(__semi) withMemo:_semi_memo];
}

- (void)__openParen {
    
    [self match:CSS_TOKEN_KIND_OPENPAREN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenParen:)];
}

- (void)openParen_ {
    [self parseRule:@selector(__openParen) withMemo:_openParen_memo];
}

- (void)__closeParen {
    
    [self match:CSS_TOKEN_KIND_CLOSEPAREN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseParen:)];
}

- (void)closeParen_ {
    [self parseRule:@selector(__closeParen) withMemo:_closeParen_memo];
}

- (void)__gt {
    
    [self match:CSS_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)gt_ {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__tilde {
    
    [self match:CSS_TOKEN_KIND_TILDE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTilde:)];
}

- (void)tilde_ {
    [self parseRule:@selector(__tilde) withMemo:_tilde_memo];
}

- (void)__pipe {
    
    [self match:CSS_TOKEN_KIND_PIPE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPipe:)];
}

- (void)pipe_ {
    [self parseRule:@selector(__pipe) withMemo:_pipe_memo];
}

- (void)__fwdSlash {
    
    [self match:CSS_TOKEN_KIND_FWDSLASH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFwdSlash:)];
}

- (void)fwdSlash_ {
    [self parseRule:@selector(__fwdSlash) withMemo:_fwdSlash_memo];
}

- (void)__hash {
    
    [self match:CSS_TOKEN_KIND_HASH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchHash:)];
}

- (void)hash_ {
    [self parseRule:@selector(__hash) withMemo:_hash_memo];
}

- (void)__dot {
    
    [self match:CSS_TOKEN_KIND_DOT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDot:)];
}

- (void)dot_ {
    [self parseRule:@selector(__dot) withMemo:_dot_memo];
}

- (void)__at {
    
    [self match:CSS_TOKEN_KIND_AT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAt:)];
}

- (void)at_ {
    [self parseRule:@selector(__at) withMemo:_at_memo];
}

- (void)__bang {
    
    [self match:CSS_TOKEN_KIND_BANG discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBang:)];
}

- (void)bang_ {
    [self parseRule:@selector(__bang) withMemo:_bang_memo];
}

- (void)__num {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNum:)];
}

- (void)num_ {
    [self parseRule:@selector(__num) withMemo:_num_memo];
}

@end