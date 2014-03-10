#import "LabelEBNFParser.h"
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

@interface LabelEBNFParser ()
@property (nonatomic, retain) NSMutableDictionary *s_memo;
@property (nonatomic, retain) NSMutableDictionary *label_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@end

@implementation LabelEBNFParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"s";
        self.tokenKindTab[@"="] = @(LABELEBNF_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"return"] = @(LABELEBNF_TOKEN_KIND_RETURN);
        self.tokenKindTab[@":"] = @(LABELEBNF_TOKEN_KIND_COLON);

        self.tokenKindNameTab[LABELEBNF_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[LABELEBNF_TOKEN_KIND_RETURN] = @"return";
        self.tokenKindNameTab[LABELEBNF_TOKEN_KIND_COLON] = @":";

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

- (void)start {
    [self s_];
}

- (void)__s {
    
    if ([self speculate:^{ [self label_]; [self matchWord:NO]; [self match:LABELEBNF_TOKEN_KIND_EQUALS discard:NO]; [self expr_]; }]) {
        [self label_]; 
        [self matchWord:NO]; 
        [self match:LABELEBNF_TOKEN_KIND_EQUALS discard:NO]; 
        [self expr_]; 
    } else if ([self speculate:^{ [self label_]; [self match:LABELEBNF_TOKEN_KIND_RETURN discard:NO]; [self expr_]; }]) {
        [self label_]; 
        [self match:LABELEBNF_TOKEN_KIND_RETURN discard:NO]; 
        [self expr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 's'."];
    }
    [self matchEOF:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchS:)];
}

- (void)s_ {
    [self parseRule:@selector(__s) withMemo:_s_memo];
}

- (void)__label {
    
    while ([self speculate:^{ [self matchWord:NO]; [self match:LABELEBNF_TOKEN_KIND_COLON discard:NO]; }]) {
        [self matchWord:NO]; 
        [self match:LABELEBNF_TOKEN_KIND_COLON discard:NO]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchLabel:)];
}

- (void)label_ {
    [self parseRule:@selector(__label) withMemo:_label_memo];
}

- (void)__expr {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr_ {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

@end