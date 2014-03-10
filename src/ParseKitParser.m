#import "ParseKitParser.h"
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

@interface ParseKitParser ()
@end

@implementation ParseKitParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"start";
        self.tokenKindTab[@"Symbol"] = @(PARSEKIT_TOKEN_KIND_SYMBOL_TITLE);
        self.tokenKindTab[@"{,}?"] = @(PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE);
        self.tokenKindTab[@"|"] = @(PARSEKIT_TOKEN_KIND_PIPE);
        self.tokenKindTab[@"after"] = @(PARSEKIT_TOKEN_KIND_AFTERKEY);
        self.tokenKindTab[@"}"] = @(PARSEKIT_TOKEN_KIND_CLOSE_CURLY);
        self.tokenKindTab[@"~"] = @(PARSEKIT_TOKEN_KIND_TILDE);
        self.tokenKindTab[@"Email"] = @(PARSEKIT_TOKEN_KIND_EMAIL_TITLE);
        self.tokenKindTab[@"Comment"] = @(PARSEKIT_TOKEN_KIND_COMMENT_TITLE);
        self.tokenKindTab[@"!"] = @(PARSEKIT_TOKEN_KIND_DISCARD);
        self.tokenKindTab[@"Number"] = @(PARSEKIT_TOKEN_KIND_NUMBER_TITLE);
        self.tokenKindTab[@"Any"] = @(PARSEKIT_TOKEN_KIND_ANY_TITLE);
        self.tokenKindTab[@";"] = @(PARSEKIT_TOKEN_KIND_SEMI_COLON);
        self.tokenKindTab[@"S"] = @(PARSEKIT_TOKEN_KIND_S_TITLE);
        self.tokenKindTab[@"{,}"] = @(PARSEKIT_TOKEN_KIND_ACTION);
        self.tokenKindTab[@"="] = @(PARSEKIT_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"&"] = @(PARSEKIT_TOKEN_KIND_AMPERSAND);
        self.tokenKindTab[@"/,/"] = @(PARSEKIT_TOKEN_KIND_PATTERNNOOPTS);
        self.tokenKindTab[@"?"] = @(PARSEKIT_TOKEN_KIND_PHRASEQUESTION);
        self.tokenKindTab[@"QuotedString"] = @(PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE);
        self.tokenKindTab[@"("] = @(PARSEKIT_TOKEN_KIND_OPEN_PAREN);
        self.tokenKindTab[@"@"] = @(PARSEKIT_TOKEN_KIND_AT);
        self.tokenKindTab[@"/,/i"] = @(PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE);
        self.tokenKindTab[@"before"] = @(PARSEKIT_TOKEN_KIND_BEFOREKEY);
        self.tokenKindTab[@"EOF"] = @(PARSEKIT_TOKEN_KIND_EOF_TITLE);
        self.tokenKindTab[@"URL"] = @(PARSEKIT_TOKEN_KIND_URL_TITLE);
        self.tokenKindTab[@")"] = @(PARSEKIT_TOKEN_KIND_CLOSE_PAREN);
        self.tokenKindTab[@"*"] = @(PARSEKIT_TOKEN_KIND_PHRASESTAR);
        self.tokenKindTab[@"Empty"] = @(PARSEKIT_TOKEN_KIND_EMPTY_TITLE);
        self.tokenKindTab[@"+"] = @(PARSEKIT_TOKEN_KIND_PHRASEPLUS);
        self.tokenKindTab[@"Letter"] = @(PARSEKIT_TOKEN_KIND_LETTER_TITLE);
        self.tokenKindTab[@"["] = @(PARSEKIT_TOKEN_KIND_OPEN_BRACKET);
        self.tokenKindTab[@","] = @(PARSEKIT_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"SpecificChar"] = @(PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE);
        self.tokenKindTab[@"-"] = @(PARSEKIT_TOKEN_KIND_MINUS);
        self.tokenKindTab[@"Word"] = @(PARSEKIT_TOKEN_KIND_WORD_TITLE);
        self.tokenKindTab[@"]"] = @(PARSEKIT_TOKEN_KIND_CLOSE_BRACKET);
        self.tokenKindTab[@"Char"] = @(PARSEKIT_TOKEN_KIND_CHAR_TITLE);
        self.tokenKindTab[@"Digit"] = @(PARSEKIT_TOKEN_KIND_DIGIT_TITLE);
        self.tokenKindTab[@"%{"] = @(PARSEKIT_TOKEN_KIND_DELIMOPEN);

        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_SYMBOL_TITLE] = @"Symbol";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE] = @"{,}?";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_PIPE] = @"|";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_AFTERKEY] = @"after";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_TILDE] = @"~";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_EMAIL_TITLE] = @"Email";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_COMMENT_TITLE] = @"Comment";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_DISCARD] = @"!";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_NUMBER_TITLE] = @"Number";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_ANY_TITLE] = @"Any";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_SEMI_COLON] = @";";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_S_TITLE] = @"S";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_ACTION] = @"{,}";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_AMPERSAND] = @"&";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_PATTERNNOOPTS] = @"/,/";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_PHRASEQUESTION] = @"?";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE] = @"QuotedString";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_OPEN_PAREN] = @"(";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_AT] = @"@";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE] = @"/,/i";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_BEFOREKEY] = @"before";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_EOF_TITLE] = @"EOF";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_URL_TITLE] = @"URL";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_CLOSE_PAREN] = @")";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_PHRASESTAR] = @"*";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_EMPTY_TITLE] = @"Empty";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_PHRASEPLUS] = @"+";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_LETTER_TITLE] = @"Letter";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_OPEN_BRACKET] = @"[";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE] = @"SpecificChar";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_MINUS] = @"-";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_WORD_TITLE] = @"Word";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_CHAR_TITLE] = @"Char";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_DIGIT_TITLE] = @"Digit";
        self.tokenKindNameTab[PARSEKIT_TOKEN_KIND_DELIMOPEN] = @"%{";

    }
    return self;
}

- (void)start {
    [self start_];
}

- (void)start_ {
    
    do {
        [self statement_]; 
    } while ([self speculate:^{ [self statement_]; }]);
    [self matchEOF:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStart:)];
}

- (void)statement_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self decl_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_AT, 0]) {
        [self tokenizerDirective_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'statement'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStatement:)];
}

- (void)tokenizerDirective_ {
    
    [self match:PARSEKIT_TOKEN_KIND_AT discard:YES]; 
    [self matchWord:NO]; 
    [self match:PARSEKIT_TOKEN_KIND_EQUALS discard:NO]; 
    do {
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self matchWord:NO]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
            [self matchQuotedString:NO]; 
        } else {
            [self raise:@"No viable alternative found in rule 'tokenizerDirective'."];
        }
    } while ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]);
    [self match:PARSEKIT_TOKEN_KIND_SEMI_COLON discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTokenizerDirective:)];
}

- (void)decl_ {
    
    [self production_]; 
    while ([self speculate:^{ [self namedAction_]; }]) {
        [self namedAction_]; 
    }
    [self match:PARSEKIT_TOKEN_KIND_EQUALS discard:NO]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_ACTION, 0]) {
        [self action_]; 
    }
    [self expr_]; 
    [self match:PARSEKIT_TOKEN_KIND_SEMI_COLON discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDecl:)];
}

- (void)production_ {
    
    [self varProduction_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchProduction:)];
}

- (void)namedAction_ {
    
    [self match:PARSEKIT_TOKEN_KIND_AT discard:YES]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_BEFOREKEY, 0]) {
        [self beforeKey_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_AFTERKEY, 0]) {
        [self afterKey_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'namedAction'."];
    }
    [self action_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNamedAction:)];
}

- (void)beforeKey_ {
    
    [self match:PARSEKIT_TOKEN_KIND_BEFOREKEY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBeforeKey:)];
}

- (void)afterKey_ {
    
    [self match:PARSEKIT_TOKEN_KIND_AFTERKEY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAfterKey:)];
}

- (void)varProduction_ {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVarProduction:)];
}

- (void)expr_ {
    
    [self term_]; 
    while ([self speculate:^{ [self orTerm_]; }]) {
        [self orTerm_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)term_ {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE, 0]) {
        [self semanticPredicate_]; 
    }
    [self factor_]; 
    while ([self speculate:^{ [self nextFactor_]; }]) {
        [self nextFactor_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchTerm:)];
}

- (void)orTerm_ {
    
    [self match:PARSEKIT_TOKEN_KIND_PIPE discard:NO]; 
    [self term_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrTerm:)];
}

- (void)factor_ {
    
    [self phrase_]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASEPLUS, PARSEKIT_TOKEN_KIND_PHRASEQUESTION, PARSEKIT_TOKEN_KIND_PHRASESTAR, 0]) {
        if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASESTAR, 0]) {
            [self phraseStar_]; 
        } else if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASEPLUS, 0]) {
            [self phrasePlus_]; 
        } else if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASEQUESTION, 0]) {
            [self phraseQuestion_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'factor'."];
        }
    }
    if ([self predicts:PARSEKIT_TOKEN_KIND_ACTION, 0]) {
        [self action_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchFactor:)];
}

- (void)nextFactor_ {
    
    [self factor_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNextFactor:)];
}

- (void)phrase_ {
    
    [self primaryExpr_]; 
    while ([self speculate:^{ [self predicate_]; }]) {
        [self predicate_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPhrase:)];
}

- (void)phraseStar_ {
    
    [self match:PARSEKIT_TOKEN_KIND_PHRASESTAR discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPhraseStar:)];
}

- (void)phrasePlus_ {
    
    [self match:PARSEKIT_TOKEN_KIND_PHRASEPLUS discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPhrasePlus:)];
}

- (void)phraseQuestion_ {
    
    [self match:PARSEKIT_TOKEN_KIND_PHRASEQUESTION discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPhraseQuestion:)];
}

- (void)action_ {
    
    [self match:PARSEKIT_TOKEN_KIND_ACTION discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAction:)];
}

- (void)semanticPredicate_ {
    
    [self match:PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemanticPredicate:)];
}

- (void)predicate_ {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_AMPERSAND, 0]) {
        [self intersection_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_MINUS, 0]) {
        [self difference_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'predicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPredicate:)];
}

- (void)intersection_ {
    
    [self match:PARSEKIT_TOKEN_KIND_AMPERSAND discard:YES]; 
    [self primaryExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIntersection:)];
}

- (void)difference_ {
    
    [self match:PARSEKIT_TOKEN_KIND_MINUS discard:YES]; 
    [self primaryExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDifference:)];
}

- (void)primaryExpr_ {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_TILDE, 0]) {
        [self negatedPrimaryExpr_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DELIMOPEN, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMAIL_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_OPEN_BRACKET, PARSEKIT_TOKEN_KIND_OPEN_PAREN, PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_URL_TITLE, PARSEKIT_TOKEN_KIND_WORD_TITLE, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self barePrimaryExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimaryExpr:)];
}

- (void)negatedPrimaryExpr_ {
    
    [self match:PARSEKIT_TOKEN_KIND_TILDE discard:YES]; 
    [self barePrimaryExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNegatedPrimaryExpr:)];
}

- (void)barePrimaryExpr_ {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DELIMOPEN, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMAIL_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_URL_TITLE, PARSEKIT_TOKEN_KIND_WORD_TITLE, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self atomicValue_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_OPEN_PAREN, 0]) {
        [self subSeqExpr_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self subTrackExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'barePrimaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBarePrimaryExpr:)];
}

- (void)subSeqExpr_ {
    
    [self match:PARSEKIT_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    [self expr_]; 
    [self match:PARSEKIT_TOKEN_KIND_CLOSE_PAREN discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSubSeqExpr:)];
}

- (void)subTrackExpr_ {
    
    [self match:PARSEKIT_TOKEN_KIND_OPEN_BRACKET discard:NO]; 
    [self expr_]; 
    [self match:PARSEKIT_TOKEN_KIND_CLOSE_BRACKET discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSubTrackExpr:)];
}

- (void)atomicValue_ {
    
    [self parser_]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_DISCARD, 0]) {
        [self discard_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAtomicValue:)];
}

- (void)parser_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self variable_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self literal_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, 0]) {
        [self pattern_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_DELIMOPEN, 0]) {
        [self delimitedString_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMAIL_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_URL_TITLE, PARSEKIT_TOKEN_KIND_WORD_TITLE, 0]) {
        [self constant_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'parser'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchParser:)];
}

- (void)discard_ {
    
    [self match:PARSEKIT_TOKEN_KIND_DISCARD discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDiscard:)];
}

- (void)pattern_ {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, 0]) {
        [self patternNoOpts_]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, 0]) {
        [self patternIgnoreCase_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'pattern'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPattern:)];
}

- (void)patternNoOpts_ {
    
    [self match:PARSEKIT_TOKEN_KIND_PATTERNNOOPTS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPatternNoOpts:)];
}

- (void)patternIgnoreCase_ {
    
    [self match:PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPatternIgnoreCase:)];
}

- (void)delimitedString_ {
    
    [self delimOpen_]; 
    [self matchQuotedString:NO]; 
    if ([self speculate:^{ [self match:PARSEKIT_TOKEN_KIND_COMMA discard:YES]; [self matchQuotedString:NO]; }]) {
        [self match:PARSEKIT_TOKEN_KIND_COMMA discard:YES]; 
        [self matchQuotedString:NO]; 
    }
    [self match:PARSEKIT_TOKEN_KIND_CLOSE_CURLY discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDelimitedString:)];
}

- (void)literal_ {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLiteral:)];
}

- (void)constant_ {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_EOF_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_EOF_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_WORD_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_WORD_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_NUMBER_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_NUMBER_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_SYMBOL_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_COMMENT_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_COMMENT_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_EMPTY_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_EMPTY_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_ANY_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_S_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_S_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_URL_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_URL_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_EMAIL_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_EMAIL_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_DIGIT_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_DIGIT_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_LETTER_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_LETTER_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_CHAR_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_CHAR_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'constant'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchConstant:)];
}

- (void)variable_ {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVariable:)];
}

- (void)delimOpen_ {
    
    [self match:PARSEKIT_TOKEN_KIND_DELIMOPEN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDelimOpen:)];
}

@end