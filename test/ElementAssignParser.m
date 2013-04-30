#import "ElementAssignParser.h"
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

@interface ElementAssignParser ()
@end

@implementation ElementAssignParser

- (id)init {
    self = [super init];
    if (self) {
        self.enableAutomaticErrorRecovery = YES;

        self._tokenKindTab[@"]"] = @(ELEMENTASSIGN_TOKEN_KIND_RBRACKET);
        self._tokenKindTab[@"["] = @(ELEMENTASSIGN_TOKEN_KIND_LBRACKET);
        self._tokenKindTab[@","] = @(ELEMENTASSIGN_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"="] = @(ELEMENTASSIGN_TOKEN_KIND_EQ);
        self._tokenKindTab[@";"] = @(ELEMENTASSIGN_TOKEN_KIND_SEMI);
        self._tokenKindTab[@"."] = @(ELEMENTASSIGN_TOKEN_KIND_DOT);

    }
    return self;
}


- (void)_start {
    
    [self tryAndRecover:TOKEN_KIND_BUILTIN_EOF block:^{
        do {
            [self stat]; 
        } while ([self speculate:^{ [self stat]; }]);
        [self matchEOF:YES]; 
    } completion:^{
        [self matchEOF:YES];
    }];

}

- (void)stat {
    
    if ([self speculate:^{ [self assign]; [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_DOT block:^{ [self dot]; } completion:^{ [self dot]; }];}]) {
        [self assign]; 
        [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_DOT block:^{ 
            [self dot]; 
        } completion:^{ 
            [self dot]; 
        }];
    } else if ([self speculate:^{ [self list]; [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_SEMI block:^{ [self semi]; } completion:^{ [self semi]; }];}]) {
        [self list]; 
        [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_SEMI block:^{ 
            [self semi]; 
        } completion:^{ 
            [self semi]; 
        }];
    } else {
        [self raise:@"No viable alternative found in rule 'stat'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStat:)];
}

- (void)assign {
    
    [self list]; 
    [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_EQ block:^{ 
        [self eq]; 
    } completion:^{ 
        [self eq]; 
    }];
    [self list]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAssign:)];
}

- (void)list {
    
    [self lbracket]; 
    [self tryAndRecover:ELEMENTASSIGN_TOKEN_KIND_RBRACKET block:^{ 
        [self elements]; 
        [self rbracket]; 
    } completion:^{ 
        [self rbracket]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchList:)];
}

- (void)elements {
    
    [self element]; 
    while ([self predicts:ELEMENTASSIGN_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self comma]; [self element]; }]) {
            [self comma]; 
            [self element]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElements:)];
}

- (void)element {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self matchNumber:NO];
    } else if ([self predicts:ELEMENTASSIGN_TOKEN_KIND_LBRACKET, 0]) {
        [self list]; 
    } else {
        [self raise:@"No viable alternative found in rule 'element'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElement:)];
}

- (void)lbracket {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_LBRACKET expecting:@"'['" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLbracket:)];
}

- (void)rbracket {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_RBRACKET expecting:@"']'" discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchRbracket:)];
}

- (void)comma {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_COMMA expecting:@"','" discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)eq {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_EQ expecting:@"'='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)dot {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_DOT expecting:@"'.'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDot:)];
}

- (void)semi {
    
    [self match:ELEMENTASSIGN_TOKEN_KIND_SEMI expecting:@"';'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemi:)];
}

@end