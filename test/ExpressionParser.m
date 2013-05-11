#import "ExpressionParser.h"
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

@interface ExpressionParser ()
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *orExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *orTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *andExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *andTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *relExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *relOp_memo;
@property (nonatomic, retain) NSMutableDictionary *callExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *argList_memo;
@property (nonatomic, retain) NSMutableDictionary *primary_memo;
@property (nonatomic, retain) NSMutableDictionary *atom_memo;
@property (nonatomic, retain) NSMutableDictionary *obj_memo;
@property (nonatomic, retain) NSMutableDictionary *id_memo;
@property (nonatomic, retain) NSMutableDictionary *member_memo;
@property (nonatomic, retain) NSMutableDictionary *literal_memo;
@property (nonatomic, retain) NSMutableDictionary *bool_memo;
@property (nonatomic, retain) NSMutableDictionary *lt_memo;
@property (nonatomic, retain) NSMutableDictionary *gt_memo;
@property (nonatomic, retain) NSMutableDictionary *eq_memo;
@property (nonatomic, retain) NSMutableDictionary *ne_memo;
@property (nonatomic, retain) NSMutableDictionary *le_memo;
@property (nonatomic, retain) NSMutableDictionary *ge_memo;
@property (nonatomic, retain) NSMutableDictionary *openParen_memo;
@property (nonatomic, retain) NSMutableDictionary *closeParen_memo;
@property (nonatomic, retain) NSMutableDictionary *yes_memo;
@property (nonatomic, retain) NSMutableDictionary *no_memo;
@property (nonatomic, retain) NSMutableDictionary *dot_memo;
@property (nonatomic, retain) NSMutableDictionary *comma_memo;
@property (nonatomic, retain) NSMutableDictionary *or_memo;
@property (nonatomic, retain) NSMutableDictionary *and_memo;
@end

@implementation ExpressionParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@">="] = @(EXPRESSION_TOKEN_KIND_GE);
        self._tokenKindTab[@","] = @(EXPRESSION_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"or"] = @(EXPRESSION_TOKEN_KIND_OR);
        self._tokenKindTab[@"<"] = @(EXPRESSION_TOKEN_KIND_LT);
        self._tokenKindTab[@"<="] = @(EXPRESSION_TOKEN_KIND_LE);
        self._tokenKindTab[@"="] = @(EXPRESSION_TOKEN_KIND_EQ);
        self._tokenKindTab[@"."] = @(EXPRESSION_TOKEN_KIND_DOT);
        self._tokenKindTab[@">"] = @(EXPRESSION_TOKEN_KIND_GT);
        self._tokenKindTab[@"("] = @(EXPRESSION_TOKEN_KIND_OPENPAREN);
        self._tokenKindTab[@"yes"] = @(EXPRESSION_TOKEN_KIND_YES);
        self._tokenKindTab[@"no"] = @(EXPRESSION_TOKEN_KIND_NO);
        self._tokenKindTab[@")"] = @(EXPRESSION_TOKEN_KIND_CLOSEPAREN);
        self._tokenKindTab[@"!="] = @(EXPRESSION_TOKEN_KIND_NE);
        self._tokenKindTab[@"and"] = @(EXPRESSION_TOKEN_KIND_AND);

        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_GE] = @">=";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_COMMA] = @",";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_OR] = @"or";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_LT] = @"<";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_LE] = @"<=";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_EQ] = @"=";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_DOT] = @".";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_GT] = @">";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_OPENPAREN] = @"(";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_YES] = @"yes";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_NO] = @"no";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_CLOSEPAREN] = @")";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_NE] = @"!=";
        self._tokenKindNameTab[EXPRESSION_TOKEN_KIND_AND] = @"and";

        self.expr_memo = [NSMutableDictionary dictionary];
        self.orExpr_memo = [NSMutableDictionary dictionary];
        self.orTerm_memo = [NSMutableDictionary dictionary];
        self.andExpr_memo = [NSMutableDictionary dictionary];
        self.andTerm_memo = [NSMutableDictionary dictionary];
        self.relExpr_memo = [NSMutableDictionary dictionary];
        self.relOp_memo = [NSMutableDictionary dictionary];
        self.callExpr_memo = [NSMutableDictionary dictionary];
        self.argList_memo = [NSMutableDictionary dictionary];
        self.primary_memo = [NSMutableDictionary dictionary];
        self.atom_memo = [NSMutableDictionary dictionary];
        self.obj_memo = [NSMutableDictionary dictionary];
        self.id_memo = [NSMutableDictionary dictionary];
        self.member_memo = [NSMutableDictionary dictionary];
        self.literal_memo = [NSMutableDictionary dictionary];
        self.bool_memo = [NSMutableDictionary dictionary];
        self.lt_memo = [NSMutableDictionary dictionary];
        self.gt_memo = [NSMutableDictionary dictionary];
        self.eq_memo = [NSMutableDictionary dictionary];
        self.ne_memo = [NSMutableDictionary dictionary];
        self.le_memo = [NSMutableDictionary dictionary];
        self.ge_memo = [NSMutableDictionary dictionary];
        self.openParen_memo = [NSMutableDictionary dictionary];
        self.closeParen_memo = [NSMutableDictionary dictionary];
        self.yes_memo = [NSMutableDictionary dictionary];
        self.no_memo = [NSMutableDictionary dictionary];
        self.dot_memo = [NSMutableDictionary dictionary];
        self.comma_memo = [NSMutableDictionary dictionary];
        self.or_memo = [NSMutableDictionary dictionary];
        self.and_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.expr_memo = nil;
    self.orExpr_memo = nil;
    self.orTerm_memo = nil;
    self.andExpr_memo = nil;
    self.andTerm_memo = nil;
    self.relExpr_memo = nil;
    self.relOp_memo = nil;
    self.callExpr_memo = nil;
    self.argList_memo = nil;
    self.primary_memo = nil;
    self.atom_memo = nil;
    self.obj_memo = nil;
    self.id_memo = nil;
    self.member_memo = nil;
    self.literal_memo = nil;
    self.bool_memo = nil;
    self.lt_memo = nil;
    self.gt_memo = nil;
    self.eq_memo = nil;
    self.ne_memo = nil;
    self.le_memo = nil;
    self.ge_memo = nil;
    self.openParen_memo = nil;
    self.closeParen_memo = nil;
    self.yes_memo = nil;
    self.no_memo = nil;
    self.dot_memo = nil;
    self.comma_memo = nil;
    self.or_memo = nil;
    self.and_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_expr_memo removeAllObjects];
    [_orExpr_memo removeAllObjects];
    [_orTerm_memo removeAllObjects];
    [_andExpr_memo removeAllObjects];
    [_andTerm_memo removeAllObjects];
    [_relExpr_memo removeAllObjects];
    [_relOp_memo removeAllObjects];
    [_callExpr_memo removeAllObjects];
    [_argList_memo removeAllObjects];
    [_primary_memo removeAllObjects];
    [_atom_memo removeAllObjects];
    [_obj_memo removeAllObjects];
    [_id_memo removeAllObjects];
    [_member_memo removeAllObjects];
    [_literal_memo removeAllObjects];
    [_bool_memo removeAllObjects];
    [_lt_memo removeAllObjects];
    [_gt_memo removeAllObjects];
    [_eq_memo removeAllObjects];
    [_ne_memo removeAllObjects];
    [_le_memo removeAllObjects];
    [_ge_memo removeAllObjects];
    [_openParen_memo removeAllObjects];
    [_closeParen_memo removeAllObjects];
    [_yes_memo removeAllObjects];
    [_no_memo removeAllObjects];
    [_dot_memo removeAllObjects];
    [_comma_memo removeAllObjects];
    [_or_memo removeAllObjects];
    [_and_memo removeAllObjects];
}

- (void)_start {
    
    [self expr]; 
    [self matchEOF:YES]; 

}

- (void)__expr {
    
    [self orExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__orExpr {
    
    [self andExpr]; 
    while ([self predicts:EXPRESSION_TOKEN_KIND_OR, 0]) {
        if ([self speculate:^{ [self orTerm]; }]) {
            [self orTerm]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchOrExpr:)];
}

- (void)orExpr {
    [self parseRule:@selector(__orExpr) withMemo:_orExpr_memo];
}

- (void)__orTerm {
    
    [self or]; 
    [self andExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrTerm:)];
}

- (void)orTerm {
    [self parseRule:@selector(__orTerm) withMemo:_orTerm_memo];
}

- (void)__andExpr {
    
    [self relExpr]; 
    while ([self predicts:EXPRESSION_TOKEN_KIND_AND, 0]) {
        if ([self speculate:^{ [self andTerm]; }]) {
            [self andTerm]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAndExpr:)];
}

- (void)andExpr {
    [self parseRule:@selector(__andExpr) withMemo:_andExpr_memo];
}

- (void)__andTerm {
    
    [self and]; 
    [self relExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndTerm:)];
}

- (void)andTerm {
    [self parseRule:@selector(__andTerm) withMemo:_andTerm_memo];
}

- (void)__relExpr {
    
    [self callExpr]; 
    while ([self predicts:EXPRESSION_TOKEN_KIND_EQ, EXPRESSION_TOKEN_KIND_GE, EXPRESSION_TOKEN_KIND_GT, EXPRESSION_TOKEN_KIND_LE, EXPRESSION_TOKEN_KIND_LT, EXPRESSION_TOKEN_KIND_NE, 0]) {
        if ([self speculate:^{ [self relOp]; [self callExpr]; }]) {
            [self relOp]; 
            [self callExpr]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchRelExpr:)];
}

- (void)relExpr {
    [self parseRule:@selector(__relExpr) withMemo:_relExpr_memo];
}

- (void)__relOp {
    
    if ([self predicts:EXPRESSION_TOKEN_KIND_LT, 0]) {
        [self lt]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_GT, 0]) {
        [self gt]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_EQ, 0]) {
        [self eq]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_NE, 0]) {
        [self ne]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_LE, 0]) {
        [self le]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_GE, 0]) {
        [self ge]; 
    } else {
        [self raise:@"No viable alternative found in rule 'relOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchRelOp:)];
}

- (void)relOp {
    [self parseRule:@selector(__relOp) withMemo:_relOp_memo];
}

- (void)__callExpr {
    
    [self primary]; 
    if ([self speculate:^{ [self openParen]; if ([self speculate:^{ [self argList]; }]) {[self argList]; }[self closeParen]; }]) {
        [self openParen]; 
        if ([self speculate:^{ [self argList]; }]) {
            [self argList]; 
        }
        [self closeParen]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchCallExpr:)];
}

- (void)callExpr {
    [self parseRule:@selector(__callExpr) withMemo:_callExpr_memo];
}

- (void)__argList {
    
    [self atom]; 
    while ([self predicts:EXPRESSION_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self comma]; [self atom]; }]) {
            [self comma]; 
            [self atom]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArgList:)];
}

- (void)argList {
    [self parseRule:@selector(__argList) withMemo:_argList_memo];
}

- (void)__primary {
    
    if ([self predicts:EXPRESSION_TOKEN_KIND_NO, EXPRESSION_TOKEN_KIND_YES, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self atom]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_OPENPAREN, 0]) {
        [self openParen]; 
        [self expr]; 
        [self closeParen]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primary'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimary:)];
}

- (void)primary {
    [self parseRule:@selector(__primary) withMemo:_primary_memo];
}

- (void)__atom {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self obj]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_NO, EXPRESSION_TOKEN_KIND_YES, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self literal]; 
    } else {
        [self raise:@"No viable alternative found in rule 'atom'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAtom:)];
}

- (void)atom {
    [self parseRule:@selector(__atom) withMemo:_atom_memo];
}

- (void)__obj {
    
    [self id]; 
    while ([self predicts:EXPRESSION_TOKEN_KIND_DOT, 0]) {
        if ([self speculate:^{ [self member]; }]) {
            [self member]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchObj:)];
}

- (void)obj {
    [self parseRule:@selector(__obj) withMemo:_obj_memo];
}

- (void)__id {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchId:)];
}

- (void)id {
    [self parseRule:@selector(__id) withMemo:_id_memo];
}

- (void)__member {
    
    [self dot]; 
    [self id]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMember:)];
}

- (void)member {
    [self parseRule:@selector(__member) withMemo:_member_memo];
}

- (void)__literal {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self matchQuotedString:NO]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_NO, EXPRESSION_TOKEN_KIND_YES, 0]) {
        [self bool]; 
    } else {
        [self raise:@"No viable alternative found in rule 'literal'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchLiteral:)];
}

- (void)literal {
    [self parseRule:@selector(__literal) withMemo:_literal_memo];
}

- (void)__bool {
    
    if ([self predicts:EXPRESSION_TOKEN_KIND_YES, 0]) {
        [self yes]; 
    } else if ([self predicts:EXPRESSION_TOKEN_KIND_NO, 0]) {
        [self no]; 
    } else {
        [self raise:@"No viable alternative found in rule 'bool'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBool:)];
}

- (void)bool {
    [self parseRule:@selector(__bool) withMemo:_bool_memo];
}

- (void)__lt {
    
    [self match:EXPRESSION_TOKEN_KIND_LT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)lt {
    [self parseRule:@selector(__lt) withMemo:_lt_memo];
}

- (void)__gt {
    
    [self match:EXPRESSION_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)gt {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__eq {
    
    [self match:EXPRESSION_TOKEN_KIND_EQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)eq {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__ne {
    
    [self match:EXPRESSION_TOKEN_KIND_NE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNe:)];
}

- (void)ne {
    [self parseRule:@selector(__ne) withMemo:_ne_memo];
}

- (void)__le {
    
    [self match:EXPRESSION_TOKEN_KIND_LE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLe:)];
}

- (void)le {
    [self parseRule:@selector(__le) withMemo:_le_memo];
}

- (void)__ge {
    
    [self match:EXPRESSION_TOKEN_KIND_GE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGe:)];
}

- (void)ge {
    [self parseRule:@selector(__ge) withMemo:_ge_memo];
}

- (void)__openParen {
    
    [self match:EXPRESSION_TOKEN_KIND_OPENPAREN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenParen:)];
}

- (void)openParen {
    [self parseRule:@selector(__openParen) withMemo:_openParen_memo];
}

- (void)__closeParen {
    
    [self match:EXPRESSION_TOKEN_KIND_CLOSEPAREN discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseParen:)];
}

- (void)closeParen {
    [self parseRule:@selector(__closeParen) withMemo:_closeParen_memo];
}

- (void)__yes {
    
    [self match:EXPRESSION_TOKEN_KIND_YES discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchYes:)];
}

- (void)yes {
    [self parseRule:@selector(__yes) withMemo:_yes_memo];
}

- (void)__no {
    
    [self match:EXPRESSION_TOKEN_KIND_NO discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNo:)];
}

- (void)no {
    [self parseRule:@selector(__no) withMemo:_no_memo];
}

- (void)__dot {
    
    [self match:EXPRESSION_TOKEN_KIND_DOT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDot:)];
}

- (void)dot {
    [self parseRule:@selector(__dot) withMemo:_dot_memo];
}

- (void)__comma {
    
    [self match:EXPRESSION_TOKEN_KIND_COMMA discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)comma {
    [self parseRule:@selector(__comma) withMemo:_comma_memo];
}

- (void)__or {
    
    [self match:EXPRESSION_TOKEN_KIND_OR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOr:)];
}

- (void)or {
    [self parseRule:@selector(__or) withMemo:_or_memo];
}

- (void)__and {
    
    [self match:EXPRESSION_TOKEN_KIND_AND discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAnd:)];
}

- (void)and {
    [self parseRule:@selector(__and) withMemo:_and_memo];
}

@end