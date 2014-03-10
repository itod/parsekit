#import "GreedyFailureNestedParser.h"
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

@interface GreedyFailureNestedParser ()
@end

@implementation GreedyFailureNestedParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"structs";
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@","] = @(GREEDYFAILURENESTED_TOKEN_KIND_COMMA);
        self.tokenKindTab[@":"] = @(GREEDYFAILURENESTED_TOKEN_KIND_COLON);
        self.tokenKindTab[@"}"] = @(GREEDYFAILURENESTED_TOKEN_KIND_RCURLY);
        self.tokenKindTab[@"{"] = @(GREEDYFAILURENESTED_TOKEN_KIND_LCURLY);

        self.tokenKindNameTab[GREEDYFAILURENESTED_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[GREEDYFAILURENESTED_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[GREEDYFAILURENESTED_TOKEN_KIND_RCURLY] = @"}";
        self.tokenKindNameTab[GREEDYFAILURENESTED_TOKEN_KIND_LCURLY] = @"{";

    }
    return self;
}

- (void)start {
    [self structs_];
}

- (void)structs_ {
    
    [self tryAndRecover:TOKEN_KIND_BUILTIN_EOF block:^{
        do {
            [self structure_]; 
        } while ([self speculate:^{ [self structure_]; }]);
        [self matchEOF:YES]; 
    } completion:^{
        [self matchEOF:YES];
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchStructs:)];
}

- (void)structure_ {
    
    [self lcurly_]; 
    [self tryAndRecover:GREEDYFAILURENESTED_TOKEN_KIND_RCURLY block:^{ 
        [self pair_]; 
        while ([self speculate:^{ [self comma_]; [self pair_]; }]) {
            [self comma_]; 
            [self pair_]; 
        }
        [self rcurly_]; 
    } completion:^{ 
        [self rcurly_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchStructure:)];
}

- (void)pair_ {
    
    [self tryAndRecover:GREEDYFAILURENESTED_TOKEN_KIND_COLON block:^{ 
        [self name_]; 
        [self colon_]; 
    } completion:^{ 
        [self colon_]; 
    }];
        [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPair:)];
}

- (void)name_ {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchName:)];
}

- (void)value_ {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchValue:)];
}

- (void)comma_ {
    
    [self match:GREEDYFAILURENESTED_TOKEN_KIND_COMMA discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)lcurly_ {
    
    [self match:GREEDYFAILURENESTED_TOKEN_KIND_LCURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLcurly:)];
}

- (void)rcurly_ {
    
    [self match:GREEDYFAILURENESTED_TOKEN_KIND_RCURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchRcurly:)];
}

- (void)colon_ {
    
    [self match:GREEDYFAILURENESTED_TOKEN_KIND_COLON discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchColon:)];
}

@end