#import "TDNSPredicateParser.h"
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

@interface TDNSPredicateParser ()
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *orOrTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *orTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *andAndTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *andTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *compoundExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *primaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *negatedPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *predicate_memo;
@property (nonatomic, retain) NSMutableDictionary *value_memo;
@property (nonatomic, retain) NSMutableDictionary *string_memo;
@property (nonatomic, retain) NSMutableDictionary *num_memo;
@property (nonatomic, retain) NSMutableDictionary *bool_memo;
@property (nonatomic, retain) NSMutableDictionary *trueLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *falseLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *array_memo;
@property (nonatomic, retain) NSMutableDictionary *arrayContentsOpt_memo;
@property (nonatomic, retain) NSMutableDictionary *arrayContents_memo;
@property (nonatomic, retain) NSMutableDictionary *commaValue_memo;
@property (nonatomic, retain) NSMutableDictionary *keyPath_memo;
@property (nonatomic, retain) NSMutableDictionary *comparisonPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *numComparisonPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *numComparisonValue_memo;
@property (nonatomic, retain) NSMutableDictionary *comparisonOp_memo;
@property (nonatomic, retain) NSMutableDictionary *eq_memo;
@property (nonatomic, retain) NSMutableDictionary *gt_memo;
@property (nonatomic, retain) NSMutableDictionary *lt_memo;
@property (nonatomic, retain) NSMutableDictionary *gtEq_memo;
@property (nonatomic, retain) NSMutableDictionary *ltEq_memo;
@property (nonatomic, retain) NSMutableDictionary *notEq_memo;
@property (nonatomic, retain) NSMutableDictionary *between_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionComparisonPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionLtPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionGtPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionLtEqPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionGtEqPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionEqPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionNotEqPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *boolPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *truePredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *falsePredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *andKeyword_memo;
@property (nonatomic, retain) NSMutableDictionary *orKeyword_memo;
@property (nonatomic, retain) NSMutableDictionary *notKeyword_memo;
@property (nonatomic, retain) NSMutableDictionary *stringTestPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *stringTestOp_memo;
@property (nonatomic, retain) NSMutableDictionary *beginswith_memo;
@property (nonatomic, retain) NSMutableDictionary *contains_memo;
@property (nonatomic, retain) NSMutableDictionary *endswith_memo;
@property (nonatomic, retain) NSMutableDictionary *like_memo;
@property (nonatomic, retain) NSMutableDictionary *matches_memo;
@property (nonatomic, retain) NSMutableDictionary *collectionTestPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *collection_memo;
@property (nonatomic, retain) NSMutableDictionary *inKeyword_memo;
@property (nonatomic, retain) NSMutableDictionary *aggregateOp_memo;
@property (nonatomic, retain) NSMutableDictionary *any_memo;
@property (nonatomic, retain) NSMutableDictionary *some_memo;
@property (nonatomic, retain) NSMutableDictionary *all_memo;
@property (nonatomic, retain) NSMutableDictionary *none_memo;
@end

@implementation TDNSPredicateParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"ALL"] = @(TDNSPREDICATE_TOKEN_KIND_ALL);
        self._tokenKindTab[@"FALSEPREDICATE"] = @(TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE);
        self._tokenKindTab[@"NOT"] = @(TDNSPREDICATE_TOKEN_KIND_NOT_UPPER);
        self._tokenKindTab[@"{"] = @(TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY);
        self._tokenKindTab[@"=>"] = @(TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET);
        self._tokenKindTab[@">="] = @(TDNSPREDICATE_TOKEN_KIND_GE);
        self._tokenKindTab[@"&&"] = @(TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND);
        self._tokenKindTab[@"TRUEPREDICATE"] = @(TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE);
        self._tokenKindTab[@"AND"] = @(TDNSPREDICATE_TOKEN_KIND_AND_UPPER);
        self._tokenKindTab[@"}"] = @(TDNSPREDICATE_TOKEN_KIND_CLOSE_CURLY);
        self._tokenKindTab[@"true"] = @(TDNSPREDICATE_TOKEN_KIND_TRUELITERAL);
        self._tokenKindTab[@"!="] = @(TDNSPREDICATE_TOKEN_KIND_NE);
        self._tokenKindTab[@"OR"] = @(TDNSPREDICATE_TOKEN_KIND_OR_UPPER);
        self._tokenKindTab[@"!"] = @(TDNSPREDICATE_TOKEN_KIND_BANG);
        self._tokenKindTab[@"SOME"] = @(TDNSPREDICATE_TOKEN_KIND_SOME);
        self._tokenKindTab[@"IN"] = @(TDNSPREDICATE_TOKEN_KIND_INKEYWORD);
        self._tokenKindTab[@"BEGINSWITH"] = @(TDNSPREDICATE_TOKEN_KIND_BEGINSWITH);
        self._tokenKindTab[@"<"] = @(TDNSPREDICATE_TOKEN_KIND_LT);
        self._tokenKindTab[@"="] = @(TDNSPREDICATE_TOKEN_KIND_EQUALS);
        self._tokenKindTab[@"CONTAINS"] = @(TDNSPREDICATE_TOKEN_KIND_CONTAINS);
        self._tokenKindTab[@">"] = @(TDNSPREDICATE_TOKEN_KIND_GT);
        self._tokenKindTab[@"("] = @(TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN);
        self._tokenKindTab[@")"] = @(TDNSPREDICATE_TOKEN_KIND_CLOSE_PAREN);
        self._tokenKindTab[@"||"] = @(TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE);
        self._tokenKindTab[@"MATCHES"] = @(TDNSPREDICATE_TOKEN_KIND_MATCHES);
        self._tokenKindTab[@","] = @(TDNSPREDICATE_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"LIKE"] = @(TDNSPREDICATE_TOKEN_KIND_LIKE);
        self._tokenKindTab[@"ANY"] = @(TDNSPREDICATE_TOKEN_KIND_ANY);
        self._tokenKindTab[@"ENDSWITH"] = @(TDNSPREDICATE_TOKEN_KIND_ENDSWITH);
        self._tokenKindTab[@"false"] = @(TDNSPREDICATE_TOKEN_KIND_FALSELITERAL);
        self._tokenKindTab[@"<="] = @(TDNSPREDICATE_TOKEN_KIND_LE);
        self._tokenKindTab[@"BETWEEN"] = @(TDNSPREDICATE_TOKEN_KIND_BETWEEN);
        self._tokenKindTab[@"=<"] = @(TDNSPREDICATE_TOKEN_KIND_EL);
        self._tokenKindTab[@"<>"] = @(TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL);
        self._tokenKindTab[@"NONE"] = @(TDNSPREDICATE_TOKEN_KIND_NONE);
        self._tokenKindTab[@"=="] = @(TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS);

        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_ALL] = @"ALL";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE] = @"FALSEPREDICATE";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NOT_UPPER] = @"NOT";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY] = @"{";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET] = @"=>";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_GE] = @">=";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND] = @"&&";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE] = @"TRUEPREDICATE";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_AND_UPPER] = @"AND";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_TRUELITERAL] = @"true";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NE] = @"!=";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_OR_UPPER] = @"OR";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_BANG] = @"!";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_SOME] = @"SOME";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_INKEYWORD] = @"IN";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_BEGINSWITH] = @"BEGINSWITH";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_LT] = @"<";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_EQUALS] = @"=";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_CONTAINS] = @"CONTAINS";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_GT] = @">";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN] = @"(";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_CLOSE_PAREN] = @")";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE] = @"||";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_MATCHES] = @"MATCHES";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_COMMA] = @",";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_LIKE] = @"LIKE";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_ANY] = @"ANY";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_ENDSWITH] = @"ENDSWITH";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_FALSELITERAL] = @"false";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_LE] = @"<=";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_BETWEEN] = @"BETWEEN";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_EL] = @"=<";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL] = @"<>";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NONE] = @"NONE";
        self._tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS] = @"==";

        self.expr_memo = [NSMutableDictionary dictionary];
        self.orOrTerm_memo = [NSMutableDictionary dictionary];
        self.orTerm_memo = [NSMutableDictionary dictionary];
        self.andAndTerm_memo = [NSMutableDictionary dictionary];
        self.andTerm_memo = [NSMutableDictionary dictionary];
        self.compoundExpr_memo = [NSMutableDictionary dictionary];
        self.primaryExpr_memo = [NSMutableDictionary dictionary];
        self.negatedPredicate_memo = [NSMutableDictionary dictionary];
        self.predicate_memo = [NSMutableDictionary dictionary];
        self.value_memo = [NSMutableDictionary dictionary];
        self.string_memo = [NSMutableDictionary dictionary];
        self.num_memo = [NSMutableDictionary dictionary];
        self.bool_memo = [NSMutableDictionary dictionary];
        self.trueLiteral_memo = [NSMutableDictionary dictionary];
        self.falseLiteral_memo = [NSMutableDictionary dictionary];
        self.array_memo = [NSMutableDictionary dictionary];
        self.arrayContentsOpt_memo = [NSMutableDictionary dictionary];
        self.arrayContents_memo = [NSMutableDictionary dictionary];
        self.commaValue_memo = [NSMutableDictionary dictionary];
        self.keyPath_memo = [NSMutableDictionary dictionary];
        self.comparisonPredicate_memo = [NSMutableDictionary dictionary];
        self.numComparisonPredicate_memo = [NSMutableDictionary dictionary];
        self.numComparisonValue_memo = [NSMutableDictionary dictionary];
        self.comparisonOp_memo = [NSMutableDictionary dictionary];
        self.eq_memo = [NSMutableDictionary dictionary];
        self.gt_memo = [NSMutableDictionary dictionary];
        self.lt_memo = [NSMutableDictionary dictionary];
        self.gtEq_memo = [NSMutableDictionary dictionary];
        self.ltEq_memo = [NSMutableDictionary dictionary];
        self.notEq_memo = [NSMutableDictionary dictionary];
        self.between_memo = [NSMutableDictionary dictionary];
        self.collectionComparisonPredicate_memo = [NSMutableDictionary dictionary];
        self.collectionLtPredicate_memo = [NSMutableDictionary dictionary];
        self.collectionGtPredicate_memo = [NSMutableDictionary dictionary];
        self.collectionLtEqPredicate_memo = [NSMutableDictionary dictionary];
        self.collectionGtEqPredicate_memo = [NSMutableDictionary dictionary];
        self.collectionEqPredicate_memo = [NSMutableDictionary dictionary];
        self.collectionNotEqPredicate_memo = [NSMutableDictionary dictionary];
        self.boolPredicate_memo = [NSMutableDictionary dictionary];
        self.truePredicate_memo = [NSMutableDictionary dictionary];
        self.falsePredicate_memo = [NSMutableDictionary dictionary];
        self.andKeyword_memo = [NSMutableDictionary dictionary];
        self.orKeyword_memo = [NSMutableDictionary dictionary];
        self.notKeyword_memo = [NSMutableDictionary dictionary];
        self.stringTestPredicate_memo = [NSMutableDictionary dictionary];
        self.stringTestOp_memo = [NSMutableDictionary dictionary];
        self.beginswith_memo = [NSMutableDictionary dictionary];
        self.contains_memo = [NSMutableDictionary dictionary];
        self.endswith_memo = [NSMutableDictionary dictionary];
        self.like_memo = [NSMutableDictionary dictionary];
        self.matches_memo = [NSMutableDictionary dictionary];
        self.collectionTestPredicate_memo = [NSMutableDictionary dictionary];
        self.collection_memo = [NSMutableDictionary dictionary];
        self.inKeyword_memo = [NSMutableDictionary dictionary];
        self.aggregateOp_memo = [NSMutableDictionary dictionary];
        self.any_memo = [NSMutableDictionary dictionary];
        self.some_memo = [NSMutableDictionary dictionary];
        self.all_memo = [NSMutableDictionary dictionary];
        self.none_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.expr_memo = nil;
    self.orOrTerm_memo = nil;
    self.orTerm_memo = nil;
    self.andAndTerm_memo = nil;
    self.andTerm_memo = nil;
    self.compoundExpr_memo = nil;
    self.primaryExpr_memo = nil;
    self.negatedPredicate_memo = nil;
    self.predicate_memo = nil;
    self.value_memo = nil;
    self.string_memo = nil;
    self.num_memo = nil;
    self.bool_memo = nil;
    self.trueLiteral_memo = nil;
    self.falseLiteral_memo = nil;
    self.array_memo = nil;
    self.arrayContentsOpt_memo = nil;
    self.arrayContents_memo = nil;
    self.commaValue_memo = nil;
    self.keyPath_memo = nil;
    self.comparisonPredicate_memo = nil;
    self.numComparisonPredicate_memo = nil;
    self.numComparisonValue_memo = nil;
    self.comparisonOp_memo = nil;
    self.eq_memo = nil;
    self.gt_memo = nil;
    self.lt_memo = nil;
    self.gtEq_memo = nil;
    self.ltEq_memo = nil;
    self.notEq_memo = nil;
    self.between_memo = nil;
    self.collectionComparisonPredicate_memo = nil;
    self.collectionLtPredicate_memo = nil;
    self.collectionGtPredicate_memo = nil;
    self.collectionLtEqPredicate_memo = nil;
    self.collectionGtEqPredicate_memo = nil;
    self.collectionEqPredicate_memo = nil;
    self.collectionNotEqPredicate_memo = nil;
    self.boolPredicate_memo = nil;
    self.truePredicate_memo = nil;
    self.falsePredicate_memo = nil;
    self.andKeyword_memo = nil;
    self.orKeyword_memo = nil;
    self.notKeyword_memo = nil;
    self.stringTestPredicate_memo = nil;
    self.stringTestOp_memo = nil;
    self.beginswith_memo = nil;
    self.contains_memo = nil;
    self.endswith_memo = nil;
    self.like_memo = nil;
    self.matches_memo = nil;
    self.collectionTestPredicate_memo = nil;
    self.collection_memo = nil;
    self.inKeyword_memo = nil;
    self.aggregateOp_memo = nil;
    self.any_memo = nil;
    self.some_memo = nil;
    self.all_memo = nil;
    self.none_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_expr_memo removeAllObjects];
    [_orOrTerm_memo removeAllObjects];
    [_orTerm_memo removeAllObjects];
    [_andAndTerm_memo removeAllObjects];
    [_andTerm_memo removeAllObjects];
    [_compoundExpr_memo removeAllObjects];
    [_primaryExpr_memo removeAllObjects];
    [_negatedPredicate_memo removeAllObjects];
    [_predicate_memo removeAllObjects];
    [_value_memo removeAllObjects];
    [_string_memo removeAllObjects];
    [_num_memo removeAllObjects];
    [_bool_memo removeAllObjects];
    [_trueLiteral_memo removeAllObjects];
    [_falseLiteral_memo removeAllObjects];
    [_array_memo removeAllObjects];
    [_arrayContentsOpt_memo removeAllObjects];
    [_arrayContents_memo removeAllObjects];
    [_commaValue_memo removeAllObjects];
    [_keyPath_memo removeAllObjects];
    [_comparisonPredicate_memo removeAllObjects];
    [_numComparisonPredicate_memo removeAllObjects];
    [_numComparisonValue_memo removeAllObjects];
    [_comparisonOp_memo removeAllObjects];
    [_eq_memo removeAllObjects];
    [_gt_memo removeAllObjects];
    [_lt_memo removeAllObjects];
    [_gtEq_memo removeAllObjects];
    [_ltEq_memo removeAllObjects];
    [_notEq_memo removeAllObjects];
    [_between_memo removeAllObjects];
    [_collectionComparisonPredicate_memo removeAllObjects];
    [_collectionLtPredicate_memo removeAllObjects];
    [_collectionGtPredicate_memo removeAllObjects];
    [_collectionLtEqPredicate_memo removeAllObjects];
    [_collectionGtEqPredicate_memo removeAllObjects];
    [_collectionEqPredicate_memo removeAllObjects];
    [_collectionNotEqPredicate_memo removeAllObjects];
    [_boolPredicate_memo removeAllObjects];
    [_truePredicate_memo removeAllObjects];
    [_falsePredicate_memo removeAllObjects];
    [_andKeyword_memo removeAllObjects];
    [_orKeyword_memo removeAllObjects];
    [_notKeyword_memo removeAllObjects];
    [_stringTestPredicate_memo removeAllObjects];
    [_stringTestOp_memo removeAllObjects];
    [_beginswith_memo removeAllObjects];
    [_contains_memo removeAllObjects];
    [_endswith_memo removeAllObjects];
    [_like_memo removeAllObjects];
    [_matches_memo removeAllObjects];
    [_collectionTestPredicate_memo removeAllObjects];
    [_collection_memo removeAllObjects];
    [_inKeyword_memo removeAllObjects];
    [_aggregateOp_memo removeAllObjects];
    [_any_memo removeAllObjects];
    [_some_memo removeAllObjects];
    [_all_memo removeAllObjects];
    [_none_memo removeAllObjects];
}

- (void)_start {
    
    [self execute:(id)^{
    
	PKTokenizer *t = self.tokenizer;
	[t setTokenizerState:t.wordState from:'#' to:'#'];
	[t.wordState setWordChars:YES from:'.' to:'.'];
	[t.wordState setWordChars:YES from:'[' to:'['];
	[t.wordState setWordChars:YES from:']' to:']'];

	[t.symbolState add:@"=="];
	[t.symbolState add:@">="];
	[t.symbolState add:@"=>"];
	[t.symbolState add:@"<="];
	[t.symbolState add:@"=<"];
	[t.symbolState add:@"!="];
	[t.symbolState add:@"<>"];
	[t.symbolState add:@"&&"];
	[t.symbolState add:@"||"];
 
    }];
    [self expr]; 
    [self matchEOF:YES]; 

}

- (void)__expr {
    
    [self orTerm]; 
    while ([self predicts:TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE, TDNSPREDICATE_TOKEN_KIND_OR_UPPER, 0]) {
        if ([self speculate:^{ [self orOrTerm]; }]) {
            [self orOrTerm]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__orOrTerm {
    
    [self orKeyword]; 
    [self orTerm]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrOrTerm:)];
}

- (void)orOrTerm {
    [self parseRule:@selector(__orOrTerm) withMemo:_orOrTerm_memo];
}

- (void)__orTerm {
    
    [self andTerm]; 
    while ([self predicts:TDNSPREDICATE_TOKEN_KIND_AND_UPPER, TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND, 0]) {
        if ([self speculate:^{ [self andAndTerm]; }]) {
            [self andAndTerm]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchOrTerm:)];
}

- (void)orTerm {
    [self parseRule:@selector(__orTerm) withMemo:_orTerm_memo];
}

- (void)__andAndTerm {
    
    [self andKeyword]; 
    [self andTerm]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndAndTerm:)];
}

- (void)andAndTerm {
    [self parseRule:@selector(__andAndTerm) withMemo:_andAndTerm_memo];
}

- (void)__andTerm {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, TDNSPREDICATE_TOKEN_KIND_ANY, TDNSPREDICATE_TOKEN_KIND_BANG, TDNSPREDICATE_TOKEN_KIND_FALSELITERAL, TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE, TDNSPREDICATE_TOKEN_KIND_NONE, TDNSPREDICATE_TOKEN_KIND_NOT_UPPER, TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, TDNSPREDICATE_TOKEN_KIND_SOME, TDNSPREDICATE_TOKEN_KIND_TRUELITERAL, TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self primaryExpr]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN, 0]) {
        [self compoundExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'andTerm'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAndTerm:)];
}

- (void)andTerm {
    [self parseRule:@selector(__andTerm) withMemo:_andTerm_memo];
}

- (void)__compoundExpr {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN discard:YES]; 
    [self expr]; 
    [self match:TDNSPREDICATE_TOKEN_KIND_CLOSE_PAREN discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCompoundExpr:)];
}

- (void)compoundExpr {
    [self parseRule:@selector(__compoundExpr) withMemo:_compoundExpr_memo];
}

- (void)__primaryExpr {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, TDNSPREDICATE_TOKEN_KIND_ANY, TDNSPREDICATE_TOKEN_KIND_FALSELITERAL, TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE, TDNSPREDICATE_TOKEN_KIND_NONE, TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, TDNSPREDICATE_TOKEN_KIND_SOME, TDNSPREDICATE_TOKEN_KIND_TRUELITERAL, TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self predicate]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BANG, TDNSPREDICATE_TOKEN_KIND_NOT_UPPER, 0]) {
        [self negatedPredicate]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimaryExpr:)];
}

- (void)primaryExpr {
    [self parseRule:@selector(__primaryExpr) withMemo:_primaryExpr_memo];
}

- (void)__negatedPredicate {
    
    [self notKeyword]; 
    [self predicate]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNegatedPredicate:)];
}

- (void)negatedPredicate {
    [self parseRule:@selector(__negatedPredicate) withMemo:_negatedPredicate_memo];
}

- (void)__predicate {
    
    if ([self speculate:^{ [self collectionTestPredicate]; }]) {
        [self collectionTestPredicate]; 
    } else if ([self speculate:^{ [self boolPredicate]; }]) {
        [self boolPredicate]; 
    } else if ([self speculate:^{ [self comparisonPredicate]; }]) {
        [self comparisonPredicate]; 
    } else if ([self speculate:^{ [self stringTestPredicate]; }]) {
        [self stringTestPredicate]; 
    } else {
        [self raise:@"No viable alternative found in rule 'predicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPredicate:)];
}

- (void)predicate {
    [self parseRule:@selector(__predicate) withMemo:_predicate_memo];
}

- (void)__val {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self keyPath]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self string]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self num]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSELITERAL, TDNSPREDICATE_TOKEN_KIND_TRUELITERAL, 0]) {
        [self bool]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, 0]) {
        [self array]; 
    } else {
        [self raise:@"No viable alternative found in rule 'val'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchValue:)];
}

- (void)val {
    [self parseRule:@selector(__val) withMemo:_value_memo];
}

- (void)__string {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchString:)];
}

- (void)string {
    [self parseRule:@selector(__string) withMemo:_string_memo];
}

- (void)__num {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNum:)];
}

- (void)num {
    [self parseRule:@selector(__num) withMemo:_num_memo];
}

- (void)__bool {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_TRUELITERAL, 0]) {
        [self trueLiteral]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSELITERAL, 0]) {
        [self falseLiteral]; 
    } else {
        [self raise:@"No viable alternative found in rule 'bool'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBool:)];
}

- (void)bool {
    [self parseRule:@selector(__bool) withMemo:_bool_memo];
}

- (void)__trueLiteral {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_TRUELITERAL discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTrueLiteral:)];
}

- (void)trueLiteral {
    [self parseRule:@selector(__trueLiteral) withMemo:_trueLiteral_memo];
}

- (void)__falseLiteral {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_FALSELITERAL discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalseLiteral:)];
}

- (void)falseLiteral {
    [self parseRule:@selector(__falseLiteral) withMemo:_falseLiteral_memo];
}

- (void)__array {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    [self arrayContentsOpt]; 
    [self match:TDNSPREDICATE_TOKEN_KIND_CLOSE_CURLY discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchArray:)];
}

- (void)array {
    [self parseRule:@selector(__array) withMemo:_array_memo];
}

- (void)__arrayContentsOpt {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSELITERAL, TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, TDNSPREDICATE_TOKEN_KIND_TRUELITERAL, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self arrayContents]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArrayContentsOpt:)];
}

- (void)arrayContentsOpt {
    [self parseRule:@selector(__arrayContentsOpt) withMemo:_arrayContentsOpt_memo];
}

- (void)__arrayContents {
    
    [self val];
    while ([self predicts:TDNSPREDICATE_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaValue]; }]) {
            [self commaValue]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArrayContents:)];
}

- (void)arrayContents {
    [self parseRule:@selector(__arrayContents) withMemo:_arrayContents_memo];
}

- (void)__commaValue {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_COMMA discard:YES]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCommaValue:)];
}

- (void)commaValue {
    [self parseRule:@selector(__commaValue) withMemo:_commaValue_memo];
}

- (void)__keyPath {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchKeyPath:)];
}

- (void)keyPath {
    [self parseRule:@selector(__keyPath) withMemo:_keyPath_memo];
}

- (void)__comparisonPredicate {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self numComparisonPredicate]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, TDNSPREDICATE_TOKEN_KIND_ANY, TDNSPREDICATE_TOKEN_KIND_NONE, TDNSPREDICATE_TOKEN_KIND_SOME, 0]) {
        [self collectionComparisonPredicate]; 
    } else {
        [self raise:@"No viable alternative found in rule 'comparisonPredicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchComparisonPredicate:)];
}

- (void)comparisonPredicate {
    [self parseRule:@selector(__comparisonPredicate) withMemo:_comparisonPredicate_memo];
}

- (void)__numComparisonPredicate {
    
    [self numComparisonValue]; 
    [self comparisonOp]; 
    [self numComparisonValue]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNumComparisonPredicate:)];
}

- (void)numComparisonPredicate {
    [self parseRule:@selector(__numComparisonPredicate) withMemo:_numComparisonPredicate_memo];
}

- (void)__numComparisonValue {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self keyPath]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self num]; 
    } else {
        [self raise:@"No viable alternative found in rule 'numComparisonValue'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchNumComparisonValue:)];
}

- (void)numComparisonValue {
    [self parseRule:@selector(__numComparisonValue) withMemo:_numComparisonValue_memo];
}

- (void)__comparisonOp {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS, TDNSPREDICATE_TOKEN_KIND_EQUALS, 0]) {
        [self eq]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_GT, 0]) {
        [self gt]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_LT, 0]) {
        [self lt]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_GE, TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET, 0]) {
        [self gtEq]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_EL, TDNSPREDICATE_TOKEN_KIND_LE, 0]) {
        [self ltEq]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NE, TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL, 0]) {
        [self notEq]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BETWEEN, 0]) {
        [self between]; 
    } else {
        [self raise:@"No viable alternative found in rule 'comparisonOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchComparisonOp:)];
}

- (void)comparisonOp {
    [self parseRule:@selector(__comparisonOp) withMemo:_comparisonOp_memo];
}

- (void)__eq {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_EQUALS, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_EQUALS discard:NO]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'eq'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)eq {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__gt {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)gt {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__lt {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_LT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)lt {
    [self parseRule:@selector(__lt) withMemo:_lt_memo];
}

- (void)__gtEq {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_GE, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_GE discard:NO]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'gtEq'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchGtEq:)];
}

- (void)gtEq {
    [self parseRule:@selector(__gtEq) withMemo:_gtEq_memo];
}

- (void)__ltEq {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_LE, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_LE discard:NO]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_EL, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_EL discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'ltEq'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchLtEq:)];
}

- (void)ltEq {
    [self parseRule:@selector(__ltEq) withMemo:_ltEq_memo];
}

- (void)__notEq {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NE, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_NE discard:NO]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'notEq'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchNotEq:)];
}

- (void)notEq {
    [self parseRule:@selector(__notEq) withMemo:_notEq_memo];
}

- (void)__between {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_BETWEEN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBetween:)];
}

- (void)between {
    [self parseRule:@selector(__between) withMemo:_between_memo];
}

- (void)__collectionComparisonPredicate {
    
    if ([self speculate:^{ [self collectionLtPredicate]; }]) {
        [self collectionLtPredicate]; 
    } else if ([self speculate:^{ [self collectionGtPredicate]; }]) {
        [self collectionGtPredicate]; 
    } else if ([self speculate:^{ [self collectionLtEqPredicate]; }]) {
        [self collectionLtEqPredicate]; 
    } else if ([self speculate:^{ [self collectionGtEqPredicate]; }]) {
        [self collectionGtEqPredicate]; 
    } else if ([self speculate:^{ [self collectionEqPredicate]; }]) {
        [self collectionEqPredicate]; 
    } else if ([self speculate:^{ [self collectionNotEqPredicate]; }]) {
        [self collectionNotEqPredicate]; 
    } else {
        [self raise:@"No viable alternative found in rule 'collectionComparisonPredicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionComparisonPredicate:)];
}

- (void)collectionComparisonPredicate {
    [self parseRule:@selector(__collectionComparisonPredicate) withMemo:_collectionComparisonPredicate_memo];
}

- (void)__collectionLtPredicate {
    
    [self aggregateOp]; 
    [self collection]; 
    [self lt]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionLtPredicate:)];
}

- (void)collectionLtPredicate {
    [self parseRule:@selector(__collectionLtPredicate) withMemo:_collectionLtPredicate_memo];
}

- (void)__collectionGtPredicate {
    
    [self aggregateOp]; 
    [self collection]; 
    [self gt]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionGtPredicate:)];
}

- (void)collectionGtPredicate {
    [self parseRule:@selector(__collectionGtPredicate) withMemo:_collectionGtPredicate_memo];
}

- (void)__collectionLtEqPredicate {
    
    [self aggregateOp]; 
    [self collection]; 
    [self ltEq]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionLtEqPredicate:)];
}

- (void)collectionLtEqPredicate {
    [self parseRule:@selector(__collectionLtEqPredicate) withMemo:_collectionLtEqPredicate_memo];
}

- (void)__collectionGtEqPredicate {
    
    [self aggregateOp]; 
    [self collection]; 
    [self gtEq]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionGtEqPredicate:)];
}

- (void)collectionGtEqPredicate {
    [self parseRule:@selector(__collectionGtEqPredicate) withMemo:_collectionGtEqPredicate_memo];
}

- (void)__collectionEqPredicate {
    
    [self aggregateOp]; 
    [self collection]; 
    [self eq]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionEqPredicate:)];
}

- (void)collectionEqPredicate {
    [self parseRule:@selector(__collectionEqPredicate) withMemo:_collectionEqPredicate_memo];
}

- (void)__collectionNotEqPredicate {
    
    [self aggregateOp]; 
    [self collection]; 
    [self notEq]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionNotEqPredicate:)];
}

- (void)collectionNotEqPredicate {
    [self parseRule:@selector(__collectionNotEqPredicate) withMemo:_collectionNotEqPredicate_memo];
}

- (void)__boolPredicate {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE, 0]) {
        [self truePredicate]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE, 0]) {
        [self falsePredicate]; 
    } else {
        [self raise:@"No viable alternative found in rule 'boolPredicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBoolPredicate:)];
}

- (void)boolPredicate {
    [self parseRule:@selector(__boolPredicate) withMemo:_boolPredicate_memo];
}

- (void)__truePredicate {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTruePredicate:)];
}

- (void)truePredicate {
    [self parseRule:@selector(__truePredicate) withMemo:_truePredicate_memo];
}

- (void)__falsePredicate {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalsePredicate:)];
}

- (void)falsePredicate {
    [self parseRule:@selector(__falsePredicate) withMemo:_falsePredicate_memo];
}

- (void)__andKeyword {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_AND_UPPER, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_AND_UPPER discard:YES]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND discard:YES]; 
    } else {
        [self raise:@"No viable alternative found in rule 'andKeyword'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAndKeyword:)];
}

- (void)andKeyword {
    [self parseRule:@selector(__andKeyword) withMemo:_andKeyword_memo];
}

- (void)__orKeyword {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OR_UPPER, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_OR_UPPER discard:YES]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE discard:YES]; 
    } else {
        [self raise:@"No viable alternative found in rule 'orKeyword'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchOrKeyword:)];
}

- (void)orKeyword {
    [self parseRule:@selector(__orKeyword) withMemo:_orKeyword_memo];
}

- (void)__notKeyword {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NOT_UPPER, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_NOT_UPPER discard:YES]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BANG, 0]) {
        [self match:TDNSPREDICATE_TOKEN_KIND_BANG discard:YES]; 
    } else {
        [self raise:@"No viable alternative found in rule 'notKeyword'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchNotKeyword:)];
}

- (void)notKeyword {
    [self parseRule:@selector(__notKeyword) withMemo:_notKeyword_memo];
}

- (void)__stringTestPredicate {
    
    [self string]; 
    [self stringTestOp]; 
    [self val];

    [self fireAssemblerSelector:@selector(parser:didMatchStringTestPredicate:)];
}

- (void)stringTestPredicate {
    [self parseRule:@selector(__stringTestPredicate) withMemo:_stringTestPredicate_memo];
}

- (void)__stringTestOp {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BEGINSWITH, 0]) {
        [self beginswith]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_CONTAINS, 0]) {
        [self contains]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ENDSWITH, 0]) {
        [self endswith]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_LIKE, 0]) {
        [self like]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_MATCHES, 0]) {
        [self matches]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stringTestOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStringTestOp:)];
}

- (void)stringTestOp {
    [self parseRule:@selector(__stringTestOp) withMemo:_stringTestOp_memo];
}

- (void)__beginswith {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_BEGINSWITH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBeginswith:)];
}

- (void)beginswith {
    [self parseRule:@selector(__beginswith) withMemo:_beginswith_memo];
}

- (void)__contains {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_CONTAINS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchContains:)];
}

- (void)contains {
    [self parseRule:@selector(__contains) withMemo:_contains_memo];
}

- (void)__endswith {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_ENDSWITH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEndswith:)];
}

- (void)endswith {
    [self parseRule:@selector(__endswith) withMemo:_endswith_memo];
}

- (void)__like {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_LIKE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLike:)];
}

- (void)like {
    [self parseRule:@selector(__like) withMemo:_like_memo];
}

- (void)__matches {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_MATCHES discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMatches:)];
}

- (void)matches {
    [self parseRule:@selector(__matches) withMemo:_matches_memo];
}

- (void)__collectionTestPredicate {
    
    [self val];
    [self inKeyword]; 
    [self collection]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionTestPredicate:)];
}

- (void)collectionTestPredicate {
    [self parseRule:@selector(__collectionTestPredicate) withMemo:_collectionTestPredicate_memo];
}

- (void)__collection {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self keyPath]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, 0]) {
        [self array]; 
    } else {
        [self raise:@"No viable alternative found in rule 'collection'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchCollection:)];
}

- (void)collection {
    [self parseRule:@selector(__collection) withMemo:_collection_memo];
}

- (void)__inKeyword {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_INKEYWORD discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchInKeyword:)];
}

- (void)inKeyword {
    [self parseRule:@selector(__inKeyword) withMemo:_inKeyword_memo];
}

- (void)__aggregateOp {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ANY, 0]) {
        [self any]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_SOME, 0]) {
        [self some]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, 0]) {
        [self all]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NONE, 0]) {
        [self none]; 
    } else {
        [self raise:@"No viable alternative found in rule 'aggregateOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAggregateOp:)];
}

- (void)aggregateOp {
    [self parseRule:@selector(__aggregateOp) withMemo:_aggregateOp_memo];
}

- (void)__any {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_ANY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAny:)];
}

- (void)any {
    [self parseRule:@selector(__any) withMemo:_any_memo];
}

- (void)__some {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_SOME discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSome:)];
}

- (void)some {
    [self parseRule:@selector(__some) withMemo:_some_memo];
}

- (void)__all {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_ALL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAll:)];
}

- (void)all {
    [self parseRule:@selector(__all) withMemo:_all_memo];
}

- (void)__none {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_NONE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNone:)];
}

- (void)none {
    [self parseRule:@selector(__none) withMemo:_none_memo];
}

@end