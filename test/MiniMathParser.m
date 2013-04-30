#import "MiniMathParser.h"
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

@interface MiniMathParser ()
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *mult_memo;
@property (nonatomic, retain) NSMutableDictionary *pow_memo;
@property (nonatomic, retain) NSMutableDictionary *atom_memo;
@end

@implementation MiniMathParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"+"] = @(MINIMATH_TOKEN_KIND_PLUS);
        self._tokenKindTab[@"*"] = @(MINIMATH_TOKEN_KIND_STAR);
        self._tokenKindTab[@"^"] = @(MINIMATH_TOKEN_KIND_CARET);

        self._tokenKindNameTab[MINIMATH_TOKEN_KIND_PLUS] = @"+";
        self._tokenKindNameTab[MINIMATH_TOKEN_KIND_STAR] = @"*";
        self._tokenKindNameTab[MINIMATH_TOKEN_KIND_CARET] = @"^";

        self.expr_memo = [NSMutableDictionary dictionary];
        self.mult_memo = [NSMutableDictionary dictionary];
        self.pow_memo = [NSMutableDictionary dictionary];
        self.atom_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.expr_memo = nil;
    self.mult_memo = nil;
    self.pow_memo = nil;
    self.atom_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_expr_memo removeAllObjects];
    [_mult_memo removeAllObjects];
    [_pow_memo removeAllObjects];
    [_atom_memo removeAllObjects];
}

- (void)_start {
    
    [self expr]; 
    [self matchEOF:YES]; 

}

- (void)__expr {
    
    [self mult]; 
    while ([self predicts:MINIMATH_TOKEN_KIND_PLUS, 0]) {
        if ([self speculate:^{ [self match:MINIMATH_TOKEN_KIND_PLUS discard:YES]; [self mult]; [self execute:(id)^{ PUSH_FLOAT(POP_FLOAT()+POP_FLOAT()); }];}]) {
            [self match:MINIMATH_TOKEN_KIND_PLUS discard:YES]; 
            [self mult]; 
            [self execute:(id)^{
             PUSH_FLOAT(POP_FLOAT()+POP_FLOAT()); 
            }];
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__mult {
    
    [self pow]; 
    while ([self predicts:MINIMATH_TOKEN_KIND_STAR, 0]) {
        if ([self speculate:^{ [self match:MINIMATH_TOKEN_KIND_STAR discard:YES]; [self pow]; [self execute:(id)^{ PUSH_FLOAT(POP_FLOAT()*POP_FLOAT()); }];}]) {
            [self match:MINIMATH_TOKEN_KIND_STAR discard:YES]; 
            [self pow]; 
            [self execute:(id)^{
             PUSH_FLOAT(POP_FLOAT()*POP_FLOAT()); 
            }];
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMult:)];
}

- (void)mult {
    [self parseRule:@selector(__mult) withMemo:_mult_memo];
}

- (void)__pow {
    
    [self atom]; 
    if ([self speculate:^{ [self match:MINIMATH_TOKEN_KIND_CARET discard:YES]; [self pow]; [self execute:(id)^{ 		double exp = POP_FLOAT();		double base = POP_FLOAT();		double result = base;	for (NSUInteger i = 1; i < exp; i++) 			result *= base;		PUSH_FLOAT(result); 	}];}]) {
        [self match:MINIMATH_TOKEN_KIND_CARET discard:YES]; 
        [self pow]; 
        [self execute:(id)^{
         
		double exp = POP_FLOAT();
		double base = POP_FLOAT();
		double result = base;
	    for (NSUInteger i = 1; i < exp; i++) 
			result *= base;
		PUSH_FLOAT(result); 
	
        }];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPow:)];
}

- (void)pow {
    [self parseRule:@selector(__pow) withMemo:_pow_memo];
}

- (void)__atom {
    
    [self matchNumber:NO];
    [self execute:(id)^{
    PUSH_FLOAT(POP_FLOAT());
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchAtom:)];
}

- (void)atom {
    [self parseRule:@selector(__atom) withMemo:_atom_memo];
}

@end