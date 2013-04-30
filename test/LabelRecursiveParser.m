#import "LabelRecursiveParser.h"
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

- (BOOL)_popBool;
- (NSInteger)_popInteger;
- (double)_popDouble;
- (PKToken *)_popToken;
- (NSString *)_popString;

- (void)_pushBool:(BOOL)yn;
- (void)_pushInteger:(NSInteger)i;
- (void)_pushDouble:(double)d;
@end

@interface LabelRecursiveParser ()
@property (nonatomic, retain) NSMutableDictionary *s_memo;
@property (nonatomic, retain) NSMutableDictionary *label_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@end

@implementation LabelRecursiveParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"="] = @(LABELRECURSIVE_TOKEN_KIND_EQUALS);
        self._tokenKindTab[@"return"] = @(LABELRECURSIVE_TOKEN_KIND_RETURN);
        self._tokenKindTab[@":"] = @(LABELRECURSIVE_TOKEN_KIND_COLON);

        self.s_memo = [NSMutableDictionary dictionary];
        self.label_memo = [NSMutableDictionary dictionary];
        self.expr_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.s_memo = nil;
    self.label_memo = nil;
    self.expr_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_s_memo removeAllObjects];
    [_label_memo removeAllObjects];
    [_expr_memo removeAllObjects];
}

- (void)_start {
    
    [self s]; 
    [self matchEOF:YES]; 

}

- (void)__s {
    
    if ([self speculate:^{ [self label]; [self matchWord:NO];[self match:LABELRECURSIVE_TOKEN_KIND_EQUALS expecting:@"'='" discard:NO]; [self expr]; }]) {
        [self label]; 
        [self matchWord:NO];
        [self match:LABELRECURSIVE_TOKEN_KIND_EQUALS expecting:@"'='" discard:NO]; 
        [self expr]; 
    } else if ([self speculate:^{ [self label]; [self match:LABELRECURSIVE_TOKEN_KIND_RETURN expecting:@"'return'" discard:NO]; [self expr]; }]) {
        [self label]; 
        [self match:LABELRECURSIVE_TOKEN_KIND_RETURN expecting:@"'return'" discard:NO]; 
        [self expr]; 
    } else {
        [self raise:@"No viable alternative found in rule 's'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchS:)];
}

- (void)s {
    [self parseRule:@selector(__s) withMemo:_s_memo];
}

- (void)__label {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self matchWord:NO];
        [self match:LABELRECURSIVE_TOKEN_KIND_COLON expecting:@"':'" discard:NO]; 
        [self label]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchLabel:)];
}

- (void)label {
    [self parseRule:@selector(__label) withMemo:_label_memo];
}

- (void)__expr {
    
    [self matchNumber:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

@end