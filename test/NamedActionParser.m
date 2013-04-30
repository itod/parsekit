#import "NamedActionParser.h"
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

@interface NamedActionParser ()
@property (nonatomic, retain) NSMutableDictionary *a_memo;
@property (nonatomic, retain) NSMutableDictionary *b_memo;
@end

@implementation NamedActionParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"a"] = @(NAMEDACTION_TOKEN_KIND_A);
        self._tokenKindTab[@"b"] = @(NAMEDACTION_TOKEN_KIND_B);

        self._tokenKindNameTab[NAMEDACTION_TOKEN_KIND_A] = @"a";
        self._tokenKindNameTab[NAMEDACTION_TOKEN_KIND_B] = @"b";

        self.a_memo = [NSMutableDictionary dictionary];
        self.b_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.a_memo = nil;
    self.b_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_a_memo removeAllObjects];
    [_b_memo removeAllObjects];
}

- (void)_start {
    
    [self a]; 
    [self b]; 
    [self matchEOF:YES]; 

}

- (void)__a {
    
    [self execute:(id)^{
    PUSH(@"foo");
    }];
    [self match:NAMEDACTION_TOKEN_KIND_A discard:NO]; 
    [self execute:(id)^{
    PUSH(@"bar");
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchA:)];
}

- (void)a {
    [self parseRule:@selector(__a) withMemo:_a_memo];
}

- (void)__b {
    
    [self match:NAMEDACTION_TOKEN_KIND_B discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchB:)];
}

- (void)b {
    [self parseRule:@selector(__b) withMemo:_b_memo];
}

@end