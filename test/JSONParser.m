#import "JSONParser.h"
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

@interface JSONParser ()
@end

@implementation JSONParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"start";
        self.tokenKindTab[@"false"] = @(JSON_TOKEN_KIND_FALSE);
        self.tokenKindTab[@"}"] = @(JSON_TOKEN_KIND_CLOSECURLY);
        self.tokenKindTab[@"["] = @(JSON_TOKEN_KIND_OPENBRACKET);
        self.tokenKindTab[@"null"] = @(JSON_TOKEN_KIND_NULLLITERAL);
        self.tokenKindTab[@","] = @(JSON_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"true"] = @(JSON_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"]"] = @(JSON_TOKEN_KIND_CLOSEBRACKET);
        self.tokenKindTab[@"{"] = @(JSON_TOKEN_KIND_OPENCURLY);
        self.tokenKindTab[@":"] = @(JSON_TOKEN_KIND_COLON);

        self.tokenKindNameTab[JSON_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[JSON_TOKEN_KIND_CLOSECURLY] = @"}";
        self.tokenKindNameTab[JSON_TOKEN_KIND_OPENBRACKET] = @"[";
        self.tokenKindNameTab[JSON_TOKEN_KIND_NULLLITERAL] = @"null";
        self.tokenKindNameTab[JSON_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[JSON_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[JSON_TOKEN_KIND_CLOSEBRACKET] = @"]";
        self.tokenKindNameTab[JSON_TOKEN_KIND_OPENCURLY] = @"{";
        self.tokenKindNameTab[JSON_TOKEN_KIND_COLON] = @":";

    }
    return self;
}

- (void)start {
    [self start_];
}

- (void)start_ {
    
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
        [self array_]; 
    } else if ([self predicts:JSON_TOKEN_KIND_OPENCURLY, 0]) {
        [self object_]; 
    }
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }
    [self matchEOF:YES]; 

}

- (void)object_ {
    
    [self openCurly_]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }
    [self objectContent_]; 
    [self closeCurly_]; 

}

- (void)objectContent_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self actualObject_]; 
    }

}

- (void)actualObject_ {
    
    [self property_]; 
    while ([self speculate:^{ [self commaProperty_]; }]) {
        [self commaProperty_]; 
    }

}

- (void)property_ {
    
    [self propertyName_]; 
    [self colon_]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }
    [self value_]; 

}

- (void)commaProperty_ {
    
    [self comma_]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }
    [self property_]; 

}

- (void)propertyName_ {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPropertyName:)];
}

- (void)array_ {
    
    [self openBracket_]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }
    [self arrayContent_]; 
    [self closeBracket_]; 

}

- (void)arrayContent_ {
    
    if ([self predicts:JSON_TOKEN_KIND_FALSE, JSON_TOKEN_KIND_NULLLITERAL, JSON_TOKEN_KIND_OPENBRACKET, JSON_TOKEN_KIND_OPENCURLY, JSON_TOKEN_KIND_TRUE, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self actualArray_]; 
    }

}

- (void)actualArray_ {
    
    [self value_]; 
    while ([self speculate:^{ [self commaValue_]; }]) {
        [self commaValue_]; 
    }

}

- (void)commaValue_ {
    
    [self comma_]; 
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }
    [self value_]; 

}

- (void)value_ {
    
    if ([self predicts:JSON_TOKEN_KIND_NULLLITERAL, 0]) {
        [self nullLiteral_]; 
    } else if ([self predicts:JSON_TOKEN_KIND_TRUE, 0]) {
        [self true_]; 
    } else if ([self predicts:JSON_TOKEN_KIND_FALSE, 0]) {
        [self false_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self number_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self string_]; 
    } else if ([self predicts:JSON_TOKEN_KIND_OPENBRACKET, 0]) {
        [self array_]; 
    } else if ([self predicts:JSON_TOKEN_KIND_OPENCURLY, 0]) {
        [self object_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'value'."];
    }
    if ([self predicts:TOKEN_KIND_BUILTIN_COMMENT, 0]) {
        [self comment_]; 
    }

}

- (void)comment_ {
    
    [self matchComment:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComment:)];
}

- (void)string_ {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchString:)];
}

- (void)number_ {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNumber:)];
}

- (void)nullLiteral_ {
    
    [self match:JSON_TOKEN_KIND_NULLLITERAL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNullLiteral:)];
}

- (void)true_ {
    
    [self match:JSON_TOKEN_KIND_TRUE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTrue:)];
}

- (void)false_ {
    
    [self match:JSON_TOKEN_KIND_FALSE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalse:)];
}

- (void)openCurly_ {
    
    [self match:JSON_TOKEN_KIND_OPENCURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenCurly:)];
}

- (void)closeCurly_ {
    
    [self match:JSON_TOKEN_KIND_CLOSECURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseCurly:)];
}

- (void)openBracket_ {
    
    [self match:JSON_TOKEN_KIND_OPENBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenBracket:)];
}

- (void)closeBracket_ {
    
    [self match:JSON_TOKEN_KIND_CLOSEBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseBracket:)];
}

- (void)comma_ {
    
    [self match:JSON_TOKEN_KIND_COMMA discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)colon_ {
    
    [self match:JSON_TOKEN_KIND_COLON discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchColon:)];
}

@end