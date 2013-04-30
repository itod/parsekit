#import "AltParser.h"
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

@interface AltParser ()
@property (nonatomic, retain) NSMutableDictionary *s_memo;
@property (nonatomic, retain) NSMutableDictionary *a_memo;
@property (nonatomic, retain) NSMutableDictionary *b_memo;
@property (nonatomic, retain) NSMutableDictionary *foo_memo;
@property (nonatomic, retain) NSMutableDictionary *bar_memo;
@property (nonatomic, retain) NSMutableDictionary *baz_memo;
@end

@implementation AltParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"foo"] = @(ALT_TOKEN_KIND_FOO);
        self._tokenKindTab[@"bar"] = @(ALT_TOKEN_KIND_BAR);
        self._tokenKindTab[@"baz"] = @(ALT_TOKEN_KIND_BAZ);

        self.s_memo = [NSMutableDictionary dictionary];
        self.a_memo = [NSMutableDictionary dictionary];
        self.b_memo = [NSMutableDictionary dictionary];
        self.foo_memo = [NSMutableDictionary dictionary];
        self.bar_memo = [NSMutableDictionary dictionary];
        self.baz_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.s_memo = nil;
    self.a_memo = nil;
    self.b_memo = nil;
    self.foo_memo = nil;
    self.bar_memo = nil;
    self.baz_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_s_memo removeAllObjects];
    [_a_memo removeAllObjects];
    [_b_memo removeAllObjects];
    [_foo_memo removeAllObjects];
    [_bar_memo removeAllObjects];
    [_baz_memo removeAllObjects];
}

- (void)_start {
    
    [self s]; 
    [self matchEOF:YES]; 

}

- (void)__s {
    
    if ([self speculate:^{ [self a]; }]) {
        [self a]; 
    } else if ([self speculate:^{ [self b]; }]) {
        [self b]; 
    } else {
        [self raise:@"No viable alternative found in rule 's'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchS:)];
}

- (void)s {
    [self parseRule:@selector(__s) withMemo:_s_memo];
}

- (void)__a {
    
    [self foo]; 
    [self baz]; 

    [self fireAssemblerSelector:@selector(parser:didMatchA:)];
}

- (void)a {
    [self parseRule:@selector(__a) withMemo:_a_memo];
}

- (void)__b {
    
    if ([self speculate:^{ [self a]; }]) {
        [self a]; 
    } else if ([self speculate:^{ [self foo]; [self bar]; }]) {
        [self foo]; 
        [self bar]; 
    } else {
        [self raise:@"No viable alternative found in rule 'b'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchB:)];
}

- (void)b {
    [self parseRule:@selector(__b) withMemo:_b_memo];
}

- (void)__foo {
    
    [self match:ALT_TOKEN_KIND_FOO expecting:@"'foo'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFoo:)];
}

- (void)foo {
    [self parseRule:@selector(__foo) withMemo:_foo_memo];
}

- (void)__bar {
    
    [self match:ALT_TOKEN_KIND_BAR expecting:@"'bar'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBar:)];
}

- (void)bar {
    [self parseRule:@selector(__bar) withMemo:_bar_memo];
}

- (void)__baz {
    
    [self match:ALT_TOKEN_KIND_BAZ expecting:@"'baz'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBaz:)];
}

- (void)baz {
    [self parseRule:@selector(__baz) withMemo:_baz_memo];
}

@end