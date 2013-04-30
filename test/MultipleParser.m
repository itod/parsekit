#import "MultipleParser.h"
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

@interface MultipleParser ()
@property (nonatomic, retain) NSMutableDictionary *s_memo;
@property (nonatomic, retain) NSMutableDictionary *ab_memo;
@property (nonatomic, retain) NSMutableDictionary *a_memo;
@property (nonatomic, retain) NSMutableDictionary *b_memo;
@end

@implementation MultipleParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"a"] = @(MULTIPLE_TOKEN_KIND_A);
        self._tokenKindTab[@"b"] = @(MULTIPLE_TOKEN_KIND_B);

        self._tokenKindNameTab[MULTIPLE_TOKEN_KIND_A] = @"a";
        self._tokenKindNameTab[MULTIPLE_TOKEN_KIND_B] = @"b";

        self.s_memo = [NSMutableDictionary dictionary];
        self.ab_memo = [NSMutableDictionary dictionary];
        self.a_memo = [NSMutableDictionary dictionary];
        self.b_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.s_memo = nil;
    self.ab_memo = nil;
    self.a_memo = nil;
    self.b_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_s_memo removeAllObjects];
    [_ab_memo removeAllObjects];
    [_a_memo removeAllObjects];
    [_b_memo removeAllObjects];
}

- (void)_start {
    
    [self s]; 
    [self matchEOF:YES]; 

}

- (void)__s {
    
    do {
        [self ab]; 
    } while ([self speculate:^{ [self ab]; }]);
    [self a]; 

    [self fireAssemblerSelector:@selector(parser:didMatchS:)];
}

- (void)s {
    [self parseRule:@selector(__s) withMemo:_s_memo];
}

- (void)__ab {
    
    [self a]; 
    [self b]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAb:)];
}

- (void)ab {
    [self parseRule:@selector(__ab) withMemo:_ab_memo];
}

- (void)__a {
    
    [self match:MULTIPLE_TOKEN_KIND_A discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchA:)];
}

- (void)a {
    [self parseRule:@selector(__a) withMemo:_a_memo];
}

- (void)__b {
    
    [self match:MULTIPLE_TOKEN_KIND_B discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchB:)];
}

- (void)b {
    [self parseRule:@selector(__b) withMemo:_b_memo];
}

@end