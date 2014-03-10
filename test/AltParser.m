#import "AltParser.h"
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

@interface AltParser ()
@property (nonatomic, retain) NSMutableDictionary *start_memo;
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
        self.startRuleName = @"start";
        self.tokenKindTab[@"foo"] = @(ALT_TOKEN_KIND_FOO);
        self.tokenKindTab[@"bar"] = @(ALT_TOKEN_KIND_BAR);
        self.tokenKindTab[@"baz"] = @(ALT_TOKEN_KIND_BAZ);

        self.tokenKindNameTab[ALT_TOKEN_KIND_FOO] = @"foo";
        self.tokenKindNameTab[ALT_TOKEN_KIND_BAR] = @"bar";
        self.tokenKindNameTab[ALT_TOKEN_KIND_BAZ] = @"baz";

        self.start_memo = [NSMutableDictionary dictionary];
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
    self.start_memo = nil;
    self.s_memo = nil;
    self.a_memo = nil;
    self.b_memo = nil;
    self.foo_memo = nil;
    self.bar_memo = nil;
    self.baz_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_start_memo removeAllObjects];
    [_s_memo removeAllObjects];
    [_a_memo removeAllObjects];
    [_b_memo removeAllObjects];
    [_foo_memo removeAllObjects];
    [_bar_memo removeAllObjects];
    [_baz_memo removeAllObjects];
}

- (void)start {
    [self start_];
}

- (void)__start {
    
    [self s_]; 
    [self matchEOF:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStart:)];
}

- (void)start_ {
    [self parseRule:@selector(__start) withMemo:_start_memo];
}

- (void)__s {
    
    if ([self speculate:^{ [self a_]; }]) {
        [self a_]; 
    } else if ([self speculate:^{ [self b_]; }]) {
        [self b_]; 
    } else {
        [self raise:@"No viable alternative found in rule 's'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchS:)];
}

- (void)s_ {
    [self parseRule:@selector(__s) withMemo:_s_memo];
}

- (void)__a {
    
    [self foo_]; 
    [self baz_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchA:)];
}

- (void)a_ {
    [self parseRule:@selector(__a) withMemo:_a_memo];
}

- (void)__b {
    
    if ([self speculate:^{ [self a_]; }]) {
        [self a_]; 
    } else if ([self speculate:^{ [self foo_]; [self bar_]; }]) {
        [self foo_]; 
        [self bar_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'b'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchB:)];
}

- (void)b_ {
    [self parseRule:@selector(__b) withMemo:_b_memo];
}

- (void)__foo {
    
    [self match:ALT_TOKEN_KIND_FOO discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFoo:)];
}

- (void)foo_ {
    [self parseRule:@selector(__foo) withMemo:_foo_memo];
}

- (void)__bar {
    
    [self match:ALT_TOKEN_KIND_BAR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBar:)];
}

- (void)bar_ {
    [self parseRule:@selector(__bar) withMemo:_bar_memo];
}

- (void)__baz {
    
    [self match:ALT_TOKEN_KIND_BAZ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBaz:)];
}

- (void)baz_ {
    [self parseRule:@selector(__baz) withMemo:_baz_memo];
}

@end