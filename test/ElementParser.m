#import "ElementParser.h"
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

@interface ElementParser ()
@property (nonatomic, retain) NSMutableDictionary *list_memo;
@property (nonatomic, retain) NSMutableDictionary *elements_memo;
@property (nonatomic, retain) NSMutableDictionary *element_memo;
@property (nonatomic, retain) NSMutableDictionary *lbracket_memo;
@property (nonatomic, retain) NSMutableDictionary *rbracket_memo;
@property (nonatomic, retain) NSMutableDictionary *comma_memo;
@end

@implementation ElementParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"["] = @(ELEMENT_TOKEN_KIND_LBRACKET);
        self._tokenKindTab[@"]"] = @(ELEMENT_TOKEN_KIND_RBRACKET);
        self._tokenKindTab[@","] = @(ELEMENT_TOKEN_KIND_COMMA);

        self._tokenKindNameTab[ELEMENT_TOKEN_KIND_LBRACKET] = @"[";
        self._tokenKindNameTab[ELEMENT_TOKEN_KIND_RBRACKET] = @"]";
        self._tokenKindNameTab[ELEMENT_TOKEN_KIND_COMMA] = @",";

        self.list_memo = [NSMutableDictionary dictionary];
        self.elements_memo = [NSMutableDictionary dictionary];
        self.element_memo = [NSMutableDictionary dictionary];
        self.lbracket_memo = [NSMutableDictionary dictionary];
        self.rbracket_memo = [NSMutableDictionary dictionary];
        self.comma_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.list_memo = nil;
    self.elements_memo = nil;
    self.element_memo = nil;
    self.lbracket_memo = nil;
    self.rbracket_memo = nil;
    self.comma_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_list_memo removeAllObjects];
    [_elements_memo removeAllObjects];
    [_element_memo removeAllObjects];
    [_lbracket_memo removeAllObjects];
    [_rbracket_memo removeAllObjects];
    [_comma_memo removeAllObjects];
}

- (void)_start {
    
    [self list]; 
    [self matchEOF:YES]; 

}

- (void)__list {
    
    [self lbracket]; 
    [self elements]; 
    [self rbracket]; 

    [self fireAssemblerSelector:@selector(parser:didMatchList:)];
}

- (void)list {
    [self parseRule:@selector(__list) withMemo:_list_memo];
}

- (void)__elements {
    
    [self element]; 
    while ([self predicts:ELEMENT_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self comma]; [self element]; }]) {
            [self comma]; 
            [self element]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElements:)];
}

- (void)elements {
    [self parseRule:@selector(__elements) withMemo:_elements_memo];
}

- (void)__element {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO];
    } else if ([self predicts:ELEMENT_TOKEN_KIND_LBRACKET, 0]) {
        [self list]; 
    } else {
        [self raise:@"No viable alternative found in rule 'element'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElement:)];
}

- (void)element {
    [self parseRule:@selector(__element) withMemo:_element_memo];
}

- (void)__lbracket {
    
    [self match:ELEMENT_TOKEN_KIND_LBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLbracket:)];
}

- (void)lbracket {
    [self parseRule:@selector(__lbracket) withMemo:_lbracket_memo];
}

- (void)__rbracket {
    
    [self match:ELEMENT_TOKEN_KIND_RBRACKET discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchRbracket:)];
}

- (void)rbracket {
    [self parseRule:@selector(__rbracket) withMemo:_rbracket_memo];
}

- (void)__comma {
    
    [self match:ELEMENT_TOKEN_KIND_COMMA discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)comma {
    [self parseRule:@selector(__comma) withMemo:_comma_memo];
}

@end