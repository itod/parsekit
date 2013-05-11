#import "JSONParser.h"
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

@interface JSONParser ()
@end

@implementation JSONParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"false"] = @(JSON_TOKEN_KIND_FALSELITERAL);
        self._tokenKindTab[@"}"] = @(JSON_TOKEN_KIND_CLOSECURLY);
        self._tokenKindTab[@"["] = @(JSON_TOKEN_KIND_OPENBRACKET);
        self._tokenKindTab[@"null"] = @(JSON_TOKEN_KIND_NULLLITERAL);
        self._tokenKindTab[@","] = @(JSON_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"true"] = @(JSON_TOKEN_KIND_TRUELITERAL);
        self._tokenKindTab[@"]"] = @(JSON_TOKEN_KIND_CLOSEBRACKET);
        self._tokenKindTab[@"{"] = @(JSON_TOKEN_KIND_OPENCURLY);
        self._tokenKindTab[@":"] = @(JSON_TOKEN_KIND_COLON);

        self._tokenKindNameTab[JSON_TOKEN_KIND_FALSELITERAL] = @"false";
        self._tokenKindNameTab[JSON_TOKEN_KIND_CLOSECURLY] = @"}";
        self._tokenKindNameTab[JSON_TOKEN_KIND_OPENBRACKET] = @"[";
        self._tokenKindNameTab[JSON_TOKEN_KIND_NULLLITERAL] = @"null";
        self._tokenKindNameTab[JSON_TOKEN_KIND_COMMA] = @",";
        self._tokenKindNameTab[JSON_TOKEN_KIND_TRUELITERAL] = @"true";
        self._tokenKindNameTab[JSON_TOKEN_KIND_CLOSEBRACKET] = @"]";
        self._tokenKindNameTab[JSON_TOKEN_KIND_OPENCURLY] = @"{";
        self._tokenKindNameTab[JSON_TOKEN_KIND_COLON] = @":";

    }
    return self;
}


- (void)_start {
    
    [self execute:(id)^{
    
	PKTokenizer *t = self.tokenizer;
	
    // whitespace
    self.silentlyConsumesWhitespace = YES;
    t.whitespaceState.reportsWhitespaceTokens = YES;
    self.assembly.preservesWhitespaceTokens = YES;

    // comments
	t.commentState.reportsCommentTokens = YES;
	[t setTokenizerState:t.commentState from:'/' to:'/'];
	[t.commentState addSingleLineStartMarker:@"//"];
	[t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];

    }];
    if ([self predicts:JSON_TOKEN_KIND_OPENBRACKET, 0]) {
        [self array]; 
    } else if ([self predicts:JSON_TOKEN_KIND_OPENCURLY, 0]) {
        [self object]; 
    }
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }
    [self matchEOF:YES]; 

}

- (void)object {
    
    [self openCurly]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }
    [self objectContent]; 
    [self closeCurly]; 

}

- (void)objectContent {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self actualObject]; 
    }

}

- (void)actualObject {
    
    [self property]; 
    while ([self predicts:JSON_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaProperty]; }]) {
            [self commaProperty]; 
        } else {
            break;
        }
    }

}

- (void)property {
    
    [self propertyName]; 
    [self colon]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }
    [self value]; 

}

- (void)commaProperty {
    
    [self comma]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }
    [self property]; 

}

- (void)propertyName {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPropertyName:)];
}

- (void)array {
    
    [self openBracket]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }
    [self arrayContent]; 
    [self closeBracket]; 

}

- (void)arrayContent {
    
    if ([self predicts:JSON_TOKEN_KIND_FALSELITERAL, JSON_TOKEN_KIND_NULLLITERAL, JSON_TOKEN_KIND_OPENBRACKET, JSON_TOKEN_KIND_OPENCURLY, JSON_TOKEN_KIND_TRUELITERAL, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self actualArray]; 
    }

}

- (void)actualArray {
    
    [self value]; 
    while ([self predicts:JSON_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaValue]; }]) {
            [self commaValue]; 
        } else {
            break;
        }
    }

}

- (void)commaValue {
    
    [self comma]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }
    [self value]; 

}

- (void)value {
    
    if ([self predicts:JSON_TOKEN_KIND_NULLLITERAL, 0]) {
        [self nullLiteral]; 
    } else if ([self predicts:JSON_TOKEN_KIND_TRUELITERAL, 0]) {
        [self trueLiteral]; 
    } else if ([self predicts:JSON_TOKEN_KIND_FALSELITERAL, 0]) {
        [self falseLiteral]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self number]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self string]; 
    } else if ([self predicts:JSON_TOKEN_KIND_OPENBRACKET, 0]) {
        [self array]; 
    } else if ([self predicts:JSON_TOKEN_KIND_OPENCURLY, 0]) {
        [self object]; 
    } else {
        [self raise:@"No viable alternative found in rule 'value'."];
    }
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment]; 
    }

}

- (void)comment {
    
    [self matchComment:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComment:)];
}

- (void)string {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchString:)];
}

- (void)number {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNumber:)];
}

- (void)nullLiteral {
    
    [self match:JSON_TOKEN_KIND_NULLLITERAL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNullLiteral:)];
}

- (void)trueLiteral {
    
    [self match:JSON_TOKEN_KIND_TRUELITERAL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTrueLiteral:)];
}

- (void)falseLiteral {
    
    [self match:JSON_TOKEN_KIND_FALSELITERAL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalseLiteral:)];
}

- (void)openCurly {
    
    [self match:JSON_TOKEN_KIND_OPENCURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenCurly:)];
}

- (void)closeCurly {
    
    [self match:JSON_TOKEN_KIND_CLOSECURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseCurly:)];
}

- (void)openBracket {
    
    [self match:JSON_TOKEN_KIND_OPENBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenBracket:)];
}

- (void)closeBracket {
    
    [self match:JSON_TOKEN_KIND_CLOSEBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseBracket:)];
}

- (void)comma {
    
    [self match:JSON_TOKEN_KIND_COMMA discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)colon {
    
    [self match:JSON_TOKEN_KIND_COLON discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchColon:)];
}

@end