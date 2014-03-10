#import "ExpressionSyntaxParser.h"
#import <ParseKit/ParseKit.h>

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

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PEGParser ()
@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
@property (nonatomic, retain) NSString *startRuleName;

- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;

- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName;
@end

@interface ExpressionSyntaxParser ()
@end

@implementation ExpressionSyntaxParser

- (id)init {
    self = [super init];
    if (self) {
        self.tokenKindTab[@">="] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GE);
        self.tokenKindTab[@","] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"or"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OR);
        self.tokenKindTab[@"<"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LT);
        self.tokenKindTab[@"<="] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LE);
        self.tokenKindTab[@"="] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_EQ);
        self.tokenKindTab[@"."] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@">"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GT);
        self.tokenKindTab[@"("] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OPENPAREN);
        self.tokenKindTab[@"yes"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES);
        self.tokenKindTab[@"no"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO);
        self.tokenKindTab[@")"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_CLOSEPAREN);
        self.tokenKindTab[@"!="] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NE);
        self.tokenKindTab[@"and"] = @(EXPRESSIONSYNTAXPARSER_TOKEN_KIND_AND);

        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OR] = @"or";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LT] = @"<";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_EQ] = @"=";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GT] = @">";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OPENPAREN] = @"(";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES] = @"yes";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO] = @"no";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_CLOSEPAREN] = @")";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[EXPRESSIONSYNTAXPARSER_TOKEN_KIND_AND] = @"and";

    }
    return self;
}


- (void)start {
    
    [self expr]; 
    [self matchEOF:YES]; 

}

- (void)expr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"expr"];

    [self orExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"expr"];
}

- (void)orExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"orExpr"];

    [self andExpr]; 
    while ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OR, 0]) {
        if ([self speculate:^{ [self orTerm]; }]) {
            [self orTerm]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"orExpr"];
}

- (void)orTerm {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"orTerm"];

    [self or]; 
    [self andExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"orTerm"];
}

- (void)andExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"andExpr"];

    [self relExpr]; 
    while ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_AND, 0]) {
        if ([self speculate:^{ [self andTerm]; }]) {
            [self andTerm]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"andExpr"];
}

- (void)andTerm {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"andTerm"];

    [self and]; 
    [self relExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"andTerm"];
}

- (void)relExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"relExpr"];

    [self callExpr]; 
    while ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_EQ, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GE, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GT, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LE, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LT, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NE, 0]) {
        if ([self speculate:^{ [self relOp]; [self callExpr]; }]) {
            [self relOp]; 
            [self callExpr]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"relExpr"];
}

- (void)relOp {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"relOp"];

    if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LT, 0]) {
        [self lt]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GT, 0]) {
        [self gt]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_EQ, 0]) {
        [self eq]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NE, 0]) {
        [self ne]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LE, 0]) {
        [self le]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GE, 0]) {
        [self ge]; 
    } else {
        [self raise:@"no viable alternative found in relOp"];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"relOp"];
}

- (void)callExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"callExpr"];

    [self primary]; 
    if ([self speculate:^{ [self openParen]; if ([self speculate:^{ [self argList]; }]) {[self argList]; }[self closeParen]; }]) {
        [self openParen]; 
        if ([self speculate:^{ [self argList]; }]) {
            [self argList]; 
        }
        [self closeParen]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"callExpr"];
}

- (void)argList {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"argList"];

    [self atom]; 
    while ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self comma]; [self atom]; }]) {
            [self comma]; 
            [self atom]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"argList"];
}

- (void)primary {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"primary"];

    if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self atom]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OPENPAREN, 0]) {
        [self openParen]; 
        [self expr]; 
        [self closeParen]; 
    } else {
        [self raise:@"no viable alternative found in primary"];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"primary"];
}

- (void)atom {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"atom"];

    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self obj]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self literal]; 
    } else {
        [self raise:@"no viable alternative found in atom"];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"atom"];
}

- (void)obj {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"obj"];

    [self id]; 
    while ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_DOT, 0]) {
        if ([self speculate:^{ [self member]; }]) {
            [self member]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"obj"];
}

- (void)id {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"id"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"id"];

    [self matchWord:NO];

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"id"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"id"];
}

- (void)member {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"member"];

    [self dot]; 
    [self id]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"member"];
}

- (void)literal {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"literal"];

    if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self matchQuotedString:NO];
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO];
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO, EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES, 0]) {
        [self bool]; 
    } else {
        [self raise:@"no viable alternative found in literal"];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"literal"];
}

- (void)bool {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"bool"];

    if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES, 0]) {
        [self yes]; 
    } else if ([self predicts:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO, 0]) {
        [self no]; 
    } else {
        [self raise:@"no viable alternative found in bool"];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"bool"];
}

- (void)lt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"lt"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"lt"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"lt"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"lt"];
}

- (void)gt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"gt"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"gt"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"gt"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"gt"];
}

- (void)eq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"eq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"eq"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_EQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"eq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"eq"];
}

- (void)ne {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ne"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"ne"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"ne"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ne"];
}

- (void)le {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"le"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"le"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_LE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"le"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"le"];
}

- (void)ge {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ge"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"ge"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_GE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"ge"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ge"];
}

- (void)openParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"openParen"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"openParen"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OPENPAREN discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"openParen"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"openParen"];
}

- (void)closeParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"closeParen"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"closeParen"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_CLOSEPAREN discard:YES]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"closeParen"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"closeParen"];
}

- (void)yes {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"yes"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"yes"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_YES discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"yes"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"yes"];
}

- (void)no {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"no"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"no"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_NO discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"no"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"no"];
}

- (void)dot {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"dot"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"dot"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_DOT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"dot"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"dot"];
}

- (void)comma {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"comma"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"comma"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_COMMA discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"comma"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"comma"];
}

- (void)or {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"or"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"or"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_OR discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"or"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"or"];
}

- (void)and {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"and"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"and"];

    [self match:EXPRESSIONSYNTAXPARSER_TOKEN_KIND_AND discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"and"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"and"];
}

@end