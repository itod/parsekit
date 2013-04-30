#import "OptionalParser.h"
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

@interface OptionalParser ()
@property (nonatomic, retain) NSMutableDictionary *s_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *foo_memo;
@property (nonatomic, retain) NSMutableDictionary *bar_memo;
@end

@implementation OptionalParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"foo"] = @(OPTIONAL_TOKEN_KIND_FOO);
        self._tokenKindTab[@"bar"] = @(OPTIONAL_TOKEN_KIND_BAR);

        self._tokenKindNameTab[OPTIONAL_TOKEN_KIND_FOO] = @"foo";
        self._tokenKindNameTab[OPTIONAL_TOKEN_KIND_BAR] = @"bar";

        self.s_memo = [NSMutableDictionary dictionary];
        self.expr_memo = [NSMutableDictionary dictionary];
        self.foo_memo = [NSMutableDictionary dictionary];
        self.bar_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.s_memo = nil;
    self.expr_memo = nil;
    self.foo_memo = nil;
    self.bar_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_s_memo removeAllObjects];
    [_expr_memo removeAllObjects];
    [_foo_memo removeAllObjects];
    [_bar_memo removeAllObjects];
}

- (void)_start {
    
    [self s]; 
    [self matchEOF:YES]; 

}

- (void)__s {
    
    if ([self speculate:^{ [self expr]; }]) {
        [self expr]; 
    }
    [self foo]; 
    [self bar]; 

    [self fireAssemblerSelector:@selector(parser:didMatchS:)];
}

- (void)s {
    [self parseRule:@selector(__s) withMemo:_s_memo];
}

- (void)__expr {
    
    [self foo]; 
    [self bar]; 
    [self bar]; 

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__foo {
    
    [self match:OPTIONAL_TOKEN_KIND_FOO discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFoo:)];
}

- (void)foo {
    [self parseRule:@selector(__foo) withMemo:_foo_memo];
}

- (void)__bar {
    
    [self match:OPTIONAL_TOKEN_KIND_BAR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBar:)];
}

- (void)bar {
    [self parseRule:@selector(__bar) withMemo:_bar_memo];
}

@end