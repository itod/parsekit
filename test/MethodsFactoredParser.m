#import "MethodsFactoredParser.h"
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

@interface MethodsFactoredParser ()
@property (nonatomic, retain) NSMutableDictionary *start_memo;
@property (nonatomic, retain) NSMutableDictionary *method_memo;
@property (nonatomic, retain) NSMutableDictionary *type_memo;
@property (nonatomic, retain) NSMutableDictionary *args_memo;
@property (nonatomic, retain) NSMutableDictionary *arg_memo;
@end

@implementation MethodsFactoredParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"start";
        self.tokenKindTab[@"int"] = @(METHODSFACTORED_TOKEN_KIND_INT);
        self.tokenKindTab[@"}"] = @(METHODSFACTORED_TOKEN_KIND_CLOSE_CURLY);
        self.tokenKindTab[@","] = @(METHODSFACTORED_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"void"] = @(METHODSFACTORED_TOKEN_KIND_VOID);
        self.tokenKindTab[@"("] = @(METHODSFACTORED_TOKEN_KIND_OPEN_PAREN);
        self.tokenKindTab[@"{"] = @(METHODSFACTORED_TOKEN_KIND_OPEN_CURLY);
        self.tokenKindTab[@")"] = @(METHODSFACTORED_TOKEN_KIND_CLOSE_PAREN);
        self.tokenKindTab[@";"] = @(METHODSFACTORED_TOKEN_KIND_SEMI_COLON);

        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_INT] = @"int";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_VOID] = @"void";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_OPEN_PAREN] = @"(";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_OPEN_CURLY] = @"{";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_CLOSE_PAREN] = @")";
        self.tokenKindNameTab[METHODSFACTORED_TOKEN_KIND_SEMI_COLON] = @";";

        self.start_memo = [NSMutableDictionary dictionary];
        self.method_memo = [NSMutableDictionary dictionary];
        self.type_memo = [NSMutableDictionary dictionary];
        self.args_memo = [NSMutableDictionary dictionary];
        self.arg_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.start_memo = nil;
    self.method_memo = nil;
    self.type_memo = nil;
    self.args_memo = nil;
    self.arg_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_start_memo removeAllObjects];
    [_method_memo removeAllObjects];
    [_type_memo removeAllObjects];
    [_args_memo removeAllObjects];
    [_arg_memo removeAllObjects];
}

- (void)start {
    [self start_];
}

- (void)__start {
    
    do {
        [self method_]; 
    } while ([self speculate:^{ [self method_]; }]);
    [self matchEOF:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStart:)];
}

- (void)start_ {
    [self parseRule:@selector(__start) withMemo:_start_memo];
}

- (void)__method {
    
    [self type_]; 
    [self matchWord:NO]; 
    [self match:METHODSFACTORED_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    [self args_]; 
    [self match:METHODSFACTORED_TOKEN_KIND_CLOSE_PAREN discard:NO]; 
    if ([self predicts:METHODSFACTORED_TOKEN_KIND_SEMI_COLON, 0]) {
        [self match:METHODSFACTORED_TOKEN_KIND_SEMI_COLON discard:NO]; 
    } else if ([self predicts:METHODSFACTORED_TOKEN_KIND_OPEN_CURLY, 0]) {
        [self match:METHODSFACTORED_TOKEN_KIND_OPEN_CURLY discard:NO]; 
        [self match:METHODSFACTORED_TOKEN_KIND_CLOSE_CURLY discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'method'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMethod:)];
}

- (void)method_ {
    [self parseRule:@selector(__method) withMemo:_method_memo];
}

- (void)__type {
    
    if ([self predicts:METHODSFACTORED_TOKEN_KIND_VOID, 0]) {
        [self match:METHODSFACTORED_TOKEN_KIND_VOID discard:NO]; 
    } else if ([self predicts:METHODSFACTORED_TOKEN_KIND_INT, 0]) {
        [self match:METHODSFACTORED_TOKEN_KIND_INT discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'type'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchType:)];
}

- (void)type_ {
    [self parseRule:@selector(__type) withMemo:_type_memo];
}

- (void)__args {
    
    if ([self predicts:METHODSFACTORED_TOKEN_KIND_INT, 0]) {
        [self arg_]; 
        while ([self speculate:^{ [self match:METHODSFACTORED_TOKEN_KIND_COMMA discard:NO]; [self arg_]; }]) {
            [self match:METHODSFACTORED_TOKEN_KIND_COMMA discard:NO]; 
            [self arg_]; 
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArgs:)];
}

- (void)args_ {
    [self parseRule:@selector(__args) withMemo:_args_memo];
}

- (void)__arg {
    
    [self match:METHODSFACTORED_TOKEN_KIND_INT discard:NO]; 
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchArg:)];
}

- (void)arg_ {
    [self parseRule:@selector(__arg) withMemo:_arg_memo];
}

@end