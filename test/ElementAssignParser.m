#import "ElementAssignParser.h"
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

@interface ElementAssignParser ()
@end

@implementation ElementAssignParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"start";
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@"]"] = @(ELEMENTASSIGN_TOKEN_KIND_RBRACKET);
        self.tokenKindTab[@"["] = @(ELEMENTASSIGN_TOKEN_KIND_LBRACKET);
        self.tokenKindTab[@","] = @(ELEMENTASSIGN_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"="] = @(ELEMENTASSIGN_TOKEN_KIND_EQ);
        self.tokenKindTab[@";"] = @(ELEMENTASSIGN_TOKEN_KIND_SEMI);
        self.tokenKindTab[@"."] = @(ELEMENTASSIGN_TOKEN_KIND_DOT);

        self.tokenKindNameTab[ELEMENTASSIGN_TOKEN_KIND_RBRACKET] = @"]";
        self.tokenKindNameTab[ELEMENTASSIGN_TOKEN_KIND_LBRACKET] = @"[";
        self.tokenKindNameTab[ELEMENTASSIGN_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[ELEMENTASSIGN_TOKEN_KIND_EQ] = @"=";
        self.tokenKindNameTab[ELEMENTASSIGN_TOKEN_KIND_SEMI] = @";";
        self.tokenKindNameTab[ELEMENTASSIGN_TOKEN_KIND_DOT] = @".";

    }
    return self;
}

- (void)start {
    [self start_];
}

- (void)start_ {
    
    [self tryAndRecover:TOKEN_KIND_BUILTIN_EOF block:^{
        do {
            [self stat_]; 
        } while ([self speculate:^{ [self stat_]; }]);
        [self matchEOF:YES]; 
    } completion:^{
        [self matchEOF:YES];
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchStart:)];
}

- (void)stat_ {
    
    if ([self speculate:^{ [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_DOT block:^{ [self assign_]; [self dot_]; } completion:^{ [self dot_]; }];}]) {
        [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_DOT block:^{ 
            [self assign_]; 
            [self dot_]; 
        } completion:^{ 
            [self dot_]; 
        }];
    } else if ([self speculate:^{ [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_SEMI block:^{ [self list_]; [self semi_]; } completion:^{ [self semi_]; }];}]) {
        [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_SEMI block:^{ 
            [self list_]; 
            [self semi_]; 
        } completion:^{ 
            [self semi_]; 
        }];
    } else {
        [self raise:@"No viable alternative found in rule 'stat'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStat:)];
}

- (void)assign_ {
    
    [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_EQ block:^{ 
        [self list_]; 
        [self eq_]; 
    } completion:^{ 
        [self eq_]; 
    }];
        [self list_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAssign:)];
}

- (void)list_ {
    
    [self lbracket_]; 
    [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_RBRACKET block:^{ 
        [self elements_]; 
        [self rbracket_]; 
    } completion:^{ 
        [self rbracket_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchList:)];
}

- (void)elements_ {
    
    [self element_]; 
    while ([self speculate:^{ [self comma_]; [self element_]; }]) {
        [self comma_]; 
        [self element_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElements:)];
}

- (void)element_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO]; 
    } else if ([self predicts:ELEMENTASSIGN_TOKEN_KIND_LBRACKET, 0]) {
        [self list_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'element'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElement:)];
}

- (void)lbracket_ {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_LBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLbracket:)];
}

- (void)rbracket_ {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_RBRACKET discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchRbracket:)];
}

- (void)comma_ {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_COMMA discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)eq_ {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_EQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)dot_ {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_DOT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDot:)];
}

- (void)semi_ {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_SEMI discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemi:)];
}

@end