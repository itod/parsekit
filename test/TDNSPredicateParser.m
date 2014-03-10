#import "TDNSPredicateParser.h"
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

@interface TDNSPredicateParser ()
@property (nonatomic, retain) NSMutableDictionary *start_memo;
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
@property (nonatomic, retain) NSMutableDictionary *true_memo;
@property (nonatomic, retain) NSMutableDictionary *false_memo;
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
        self.startRuleName = @"start";
        self.tokenKindTab[@"ALL"] = @(TDNSPREDICATE_TOKEN_KIND_ALL);
        self.tokenKindTab[@"FALSEPREDICATE"] = @(TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE);
        self.tokenKindTab[@"NOT"] = @(TDNSPREDICATE_TOKEN_KIND_NOT_UPPER);
        self.tokenKindTab[@"{"] = @(TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY);
        self.tokenKindTab[@"=>"] = @(TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET);
        self.tokenKindTab[@">="] = @(TDNSPREDICATE_TOKEN_KIND_GE);
        self.tokenKindTab[@"&&"] = @(TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND);
        self.tokenKindTab[@"TRUEPREDICATE"] = @(TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE);
        self.tokenKindTab[@"AND"] = @(TDNSPREDICATE_TOKEN_KIND_AND_UPPER);
        self.tokenKindTab[@"}"] = @(TDNSPREDICATE_TOKEN_KIND_CLOSE_CURLY);
        self.tokenKindTab[@"true"] = @(TDNSPREDICATE_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"!="] = @(TDNSPREDICATE_TOKEN_KIND_NE);
        self.tokenKindTab[@"OR"] = @(TDNSPREDICATE_TOKEN_KIND_OR_UPPER);
        self.tokenKindTab[@"!"] = @(TDNSPREDICATE_TOKEN_KIND_BANG);
        self.tokenKindTab[@"SOME"] = @(TDNSPREDICATE_TOKEN_KIND_SOME);
        self.tokenKindTab[@"IN"] = @(TDNSPREDICATE_TOKEN_KIND_INKEYWORD);
        self.tokenKindTab[@"BEGINSWITH"] = @(TDNSPREDICATE_TOKEN_KIND_BEGINSWITH);
        self.tokenKindTab[@"<"] = @(TDNSPREDICATE_TOKEN_KIND_LT);
        self.tokenKindTab[@"="] = @(TDNSPREDICATE_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"CONTAINS"] = @(TDNSPREDICATE_TOKEN_KIND_CONTAINS);
        self.tokenKindTab[@">"] = @(TDNSPREDICATE_TOKEN_KIND_GT);
        self.tokenKindTab[@"("] = @(TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN);
        self.tokenKindTab[@")"] = @(TDNSPREDICATE_TOKEN_KIND_CLOSE_PAREN);
        self.tokenKindTab[@"||"] = @(TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE);
        self.tokenKindTab[@"MATCHES"] = @(TDNSPREDICATE_TOKEN_KIND_MATCHES);
        self.tokenKindTab[@","] = @(TDNSPREDICATE_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"LIKE"] = @(TDNSPREDICATE_TOKEN_KIND_LIKE);
        self.tokenKindTab[@"ANY"] = @(TDNSPREDICATE_TOKEN_KIND_ANY);
        self.tokenKindTab[@"ENDSWITH"] = @(TDNSPREDICATE_TOKEN_KIND_ENDSWITH);
        self.tokenKindTab[@"false"] = @(TDNSPREDICATE_TOKEN_KIND_FALSE);
        self.tokenKindTab[@"<="] = @(TDNSPREDICATE_TOKEN_KIND_LE);
        self.tokenKindTab[@"BETWEEN"] = @(TDNSPREDICATE_TOKEN_KIND_BETWEEN);
        self.tokenKindTab[@"=<"] = @(TDNSPREDICATE_TOKEN_KIND_EL);
        self.tokenKindTab[@"<>"] = @(TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL);
        self.tokenKindTab[@"NONE"] = @(TDNSPREDICATE_TOKEN_KIND_NONE);
        self.tokenKindTab[@"=="] = @(TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS);

        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_ALL] = @"ALL";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE] = @"FALSEPREDICATE";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NOT_UPPER] = @"NOT";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY] = @"{";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET] = @"=>";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_DOUBLE_AMPERSAND] = @"&&";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE] = @"TRUEPREDICATE";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_AND_UPPER] = @"AND";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_OR_UPPER] = @"OR";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_BANG] = @"!";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_SOME] = @"SOME";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_INKEYWORD] = @"IN";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_BEGINSWITH] = @"BEGINSWITH";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_LT] = @"<";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_CONTAINS] = @"CONTAINS";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_GT] = @">";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN] = @"(";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_CLOSE_PAREN] = @")";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_DOUBLE_PIPE] = @"||";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_MATCHES] = @"MATCHES";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_LIKE] = @"LIKE";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_ANY] = @"ANY";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_ENDSWITH] = @"ENDSWITH";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_BETWEEN] = @"BETWEEN";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_EL] = @"=<";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL] = @"<>";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_NONE] = @"NONE";
        self.tokenKindNameTab[TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS] = @"==";

        self.start_memo = [NSMutableDictionary dictionary];
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
        self.true_memo = [NSMutableDictionary dictionary];
        self.false_memo = [NSMutableDictionary dictionary];
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
    self.start_memo = nil;
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
    self.true_memo = nil;
    self.false_memo = nil;
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
    [_start_memo removeAllObjects];
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
    [_true_memo removeAllObjects];
    [_false_memo removeAllObjects];
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

- (void)start {
    [self start_];
}

- (void)__start {
    
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
    do {
        [self expr_]; 
    } while ([self speculate:^{ [self expr_]; }]);
    [self matchEOF:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStart:)];
}

- (void)start_ {
    [self parseRule:@selector(__start) withMemo:_start_memo];
}

- (void)__expr {
    
    [self orTerm_]; 
    while ([self speculate:^{ [self orOrTerm_]; }]) {
        [self orOrTerm_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr_ {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__orOrTerm {
    
    [self orKeyword_]; 
    [self orTerm_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrOrTerm:)];
}

- (void)orOrTerm_ {
    [self parseRule:@selector(__orOrTerm) withMemo:_orOrTerm_memo];
}

- (void)__orTerm {
    
    [self andTerm_]; 
    while ([self speculate:^{ [self andAndTerm_]; }]) {
        [self andAndTerm_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchOrTerm:)];
}

- (void)orTerm_ {
    [self parseRule:@selector(__orTerm) withMemo:_orTerm_memo];
}

- (void)__andAndTerm {
    
    [self andKeyword_]; 
    [self andTerm_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndAndTerm:)];
}

- (void)andAndTerm_ {
    [self parseRule:@selector(__andAndTerm) withMemo:_andAndTerm_memo];
}

- (void)__andTerm {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, TDNSPREDICATE_TOKEN_KIND_ANY, TDNSPREDICATE_TOKEN_KIND_BANG, TDNSPREDICATE_TOKEN_KIND_FALSE, TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE, TDNSPREDICATE_TOKEN_KIND_NONE, TDNSPREDICATE_TOKEN_KIND_NOT_UPPER, TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, TDNSPREDICATE_TOKEN_KIND_SOME, TDNSPREDICATE_TOKEN_KIND_TRUE, TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self primaryExpr_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN, 0]) {
        [self compoundExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'andTerm'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAndTerm:)];
}

- (void)andTerm_ {
    [self parseRule:@selector(__andTerm) withMemo:_andTerm_memo];
}

- (void)__compoundExpr {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_OPEN_PAREN discard:YES]; 
    [self expr_]; 
    [self match:TDNSPREDICATE_TOKEN_KIND_CLOSE_PAREN discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCompoundExpr:)];
}

- (void)compoundExpr_ {
    [self parseRule:@selector(__compoundExpr) withMemo:_compoundExpr_memo];
}

- (void)__primaryExpr {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, TDNSPREDICATE_TOKEN_KIND_ANY, TDNSPREDICATE_TOKEN_KIND_FALSE, TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE, TDNSPREDICATE_TOKEN_KIND_NONE, TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, TDNSPREDICATE_TOKEN_KIND_SOME, TDNSPREDICATE_TOKEN_KIND_TRUE, TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self predicate_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BANG, TDNSPREDICATE_TOKEN_KIND_NOT_UPPER, 0]) {
        [self negatedPredicate_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimaryExpr:)];
}

- (void)primaryExpr_ {
    [self parseRule:@selector(__primaryExpr) withMemo:_primaryExpr_memo];
}

- (void)__negatedPredicate {
    
    [self notKeyword_]; 
    [self predicate_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNegatedPredicate:)];
}

- (void)negatedPredicate_ {
    [self parseRule:@selector(__negatedPredicate) withMemo:_negatedPredicate_memo];
}

- (void)__predicate {
    
    if ([self speculate:^{ [self collectionTestPredicate_]; }]) {
        [self collectionTestPredicate_]; 
    } else if ([self speculate:^{ [self boolPredicate_]; }]) {
        [self boolPredicate_]; 
    } else if ([self speculate:^{ [self comparisonPredicate_]; }]) {
        [self comparisonPredicate_]; 
    } else if ([self speculate:^{ [self stringTestPredicate_]; }]) {
        [self stringTestPredicate_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'predicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPredicate:)];
}

- (void)predicate_ {
    [self parseRule:@selector(__predicate) withMemo:_predicate_memo];
}

- (void)__value {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self keyPath_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self string_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self num_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSE, TDNSPREDICATE_TOKEN_KIND_TRUE, 0]) {
        [self bool_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, 0]) {
        [self array_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'value'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchValue:)];
}

- (void)value_ {
    [self parseRule:@selector(__value) withMemo:_value_memo];
}

- (void)__string {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchString:)];
}

- (void)string_ {
    [self parseRule:@selector(__string) withMemo:_string_memo];
}

- (void)__num {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNum:)];
}

- (void)num_ {
    [self parseRule:@selector(__num) withMemo:_num_memo];
}

- (void)__bool {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_TRUE, 0]) {
        [self true_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSE, 0]) {
        [self false_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'bool'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBool:)];
}

- (void)bool_ {
    [self parseRule:@selector(__bool) withMemo:_bool_memo];
}

- (void)__true {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_TRUE discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTrue:)];
}

- (void)true_ {
    [self parseRule:@selector(__true) withMemo:_true_memo];
}

- (void)__false {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_FALSE discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalse:)];
}

- (void)false_ {
    [self parseRule:@selector(__false) withMemo:_false_memo];
}

- (void)__array {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY discard:NO]; 
    [self arrayContentsOpt_]; 
    [self match:TDNSPREDICATE_TOKEN_KIND_CLOSE_CURLY discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchArray:)];
}

- (void)array_ {
    [self parseRule:@selector(__array) withMemo:_array_memo];
}

- (void)__arrayContentsOpt {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSE, TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, TDNSPREDICATE_TOKEN_KIND_TRUE, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self arrayContents_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArrayContentsOpt:)];
}

- (void)arrayContentsOpt_ {
    [self parseRule:@selector(__arrayContentsOpt) withMemo:_arrayContentsOpt_memo];
}

- (void)__arrayContents {
    
    [self value_]; 
    while ([self speculate:^{ [self commaValue_]; }]) {
        [self commaValue_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArrayContents:)];
}

- (void)arrayContents_ {
    [self parseRule:@selector(__arrayContents) withMemo:_arrayContents_memo];
}

- (void)__commaValue {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_COMMA discard:YES]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaValue:)];
}

- (void)commaValue_ {
    [self parseRule:@selector(__commaValue) withMemo:_commaValue_memo];
}

- (void)__keyPath {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchKeyPath:)];
}

- (void)keyPath_ {
    [self parseRule:@selector(__keyPath) withMemo:_keyPath_memo];
}

- (void)__comparisonPredicate {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self numComparisonPredicate_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, TDNSPREDICATE_TOKEN_KIND_ANY, TDNSPREDICATE_TOKEN_KIND_NONE, TDNSPREDICATE_TOKEN_KIND_SOME, 0]) {
        [self collectionComparisonPredicate_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'comparisonPredicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchComparisonPredicate:)];
}

- (void)comparisonPredicate_ {
    [self parseRule:@selector(__comparisonPredicate) withMemo:_comparisonPredicate_memo];
}

- (void)__numComparisonPredicate {
    
    [self numComparisonValue_]; 
    [self comparisonOp_]; 
    [self numComparisonValue_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNumComparisonPredicate:)];
}

- (void)numComparisonPredicate_ {
    [self parseRule:@selector(__numComparisonPredicate) withMemo:_numComparisonPredicate_memo];
}

- (void)__numComparisonValue {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self keyPath_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self num_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'numComparisonValue'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchNumComparisonValue:)];
}

- (void)numComparisonValue_ {
    [self parseRule:@selector(__numComparisonValue) withMemo:_numComparisonValue_memo];
}

- (void)__comparisonOp {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_DOUBLE_EQUALS, TDNSPREDICATE_TOKEN_KIND_EQUALS, 0]) {
        [self eq_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_GT, 0]) {
        [self gt_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_LT, 0]) {
        [self lt_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_GE, TDNSPREDICATE_TOKEN_KIND_HASH_ROCKET, 0]) {
        [self gtEq_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_EL, TDNSPREDICATE_TOKEN_KIND_LE, 0]) {
        [self ltEq_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NE, TDNSPREDICATE_TOKEN_KIND_NOT_EQUAL, 0]) {
        [self notEq_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BETWEEN, 0]) {
        [self between_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'comparisonOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchComparisonOp:)];
}

- (void)comparisonOp_ {
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

- (void)eq_ {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__gt {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)gt_ {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__lt {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_LT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)lt_ {
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

- (void)gtEq_ {
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

- (void)ltEq_ {
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

- (void)notEq_ {
    [self parseRule:@selector(__notEq) withMemo:_notEq_memo];
}

- (void)__between {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_BETWEEN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBetween:)];
}

- (void)between_ {
    [self parseRule:@selector(__between) withMemo:_between_memo];
}

- (void)__collectionComparisonPredicate {
    
    if ([self speculate:^{ [self collectionLtPredicate_]; }]) {
        [self collectionLtPredicate_]; 
    } else if ([self speculate:^{ [self collectionGtPredicate_]; }]) {
        [self collectionGtPredicate_]; 
    } else if ([self speculate:^{ [self collectionLtEqPredicate_]; }]) {
        [self collectionLtEqPredicate_]; 
    } else if ([self speculate:^{ [self collectionGtEqPredicate_]; }]) {
        [self collectionGtEqPredicate_]; 
    } else if ([self speculate:^{ [self collectionEqPredicate_]; }]) {
        [self collectionEqPredicate_]; 
    } else if ([self speculate:^{ [self collectionNotEqPredicate_]; }]) {
        [self collectionNotEqPredicate_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'collectionComparisonPredicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionComparisonPredicate:)];
}

- (void)collectionComparisonPredicate_ {
    [self parseRule:@selector(__collectionComparisonPredicate) withMemo:_collectionComparisonPredicate_memo];
}

- (void)__collectionLtPredicate {
    
    [self aggregateOp_]; 
    [self collection_]; 
    [self lt_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionLtPredicate:)];
}

- (void)collectionLtPredicate_ {
    [self parseRule:@selector(__collectionLtPredicate) withMemo:_collectionLtPredicate_memo];
}

- (void)__collectionGtPredicate {
    
    [self aggregateOp_]; 
    [self collection_]; 
    [self gt_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionGtPredicate:)];
}

- (void)collectionGtPredicate_ {
    [self parseRule:@selector(__collectionGtPredicate) withMemo:_collectionGtPredicate_memo];
}

- (void)__collectionLtEqPredicate {
    
    [self aggregateOp_]; 
    [self collection_]; 
    [self ltEq_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionLtEqPredicate:)];
}

- (void)collectionLtEqPredicate_ {
    [self parseRule:@selector(__collectionLtEqPredicate) withMemo:_collectionLtEqPredicate_memo];
}

- (void)__collectionGtEqPredicate {
    
    [self aggregateOp_]; 
    [self collection_]; 
    [self gtEq_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionGtEqPredicate:)];
}

- (void)collectionGtEqPredicate_ {
    [self parseRule:@selector(__collectionGtEqPredicate) withMemo:_collectionGtEqPredicate_memo];
}

- (void)__collectionEqPredicate {
    
    [self aggregateOp_]; 
    [self collection_]; 
    [self eq_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionEqPredicate:)];
}

- (void)collectionEqPredicate_ {
    [self parseRule:@selector(__collectionEqPredicate) withMemo:_collectionEqPredicate_memo];
}

- (void)__collectionNotEqPredicate {
    
    [self aggregateOp_]; 
    [self collection_]; 
    [self notEq_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionNotEqPredicate:)];
}

- (void)collectionNotEqPredicate_ {
    [self parseRule:@selector(__collectionNotEqPredicate) withMemo:_collectionNotEqPredicate_memo];
}

- (void)__boolPredicate {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE, 0]) {
        [self truePredicate_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE, 0]) {
        [self falsePredicate_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'boolPredicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBoolPredicate:)];
}

- (void)boolPredicate_ {
    [self parseRule:@selector(__boolPredicate) withMemo:_boolPredicate_memo];
}

- (void)__truePredicate {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_TRUEPREDICATE discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTruePredicate:)];
}

- (void)truePredicate_ {
    [self parseRule:@selector(__truePredicate) withMemo:_truePredicate_memo];
}

- (void)__falsePredicate {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_FALSEPREDICATE discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalsePredicate:)];
}

- (void)falsePredicate_ {
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

- (void)andKeyword_ {
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

- (void)orKeyword_ {
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

- (void)notKeyword_ {
    [self parseRule:@selector(__notKeyword) withMemo:_notKeyword_memo];
}

- (void)__stringTestPredicate {
    
    [self string_]; 
    [self stringTestOp_]; 
    [self value_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStringTestPredicate:)];
}

- (void)stringTestPredicate_ {
    [self parseRule:@selector(__stringTestPredicate) withMemo:_stringTestPredicate_memo];
}

- (void)__stringTestOp {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_BEGINSWITH, 0]) {
        [self beginswith_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_CONTAINS, 0]) {
        [self contains_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ENDSWITH, 0]) {
        [self endswith_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_LIKE, 0]) {
        [self like_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_MATCHES, 0]) {
        [self matches_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stringTestOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStringTestOp:)];
}

- (void)stringTestOp_ {
    [self parseRule:@selector(__stringTestOp) withMemo:_stringTestOp_memo];
}

- (void)__beginswith {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_BEGINSWITH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBeginswith:)];
}

- (void)beginswith_ {
    [self parseRule:@selector(__beginswith) withMemo:_beginswith_memo];
}

- (void)__contains {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_CONTAINS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchContains:)];
}

- (void)contains_ {
    [self parseRule:@selector(__contains) withMemo:_contains_memo];
}

- (void)__endswith {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_ENDSWITH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEndswith:)];
}

- (void)endswith_ {
    [self parseRule:@selector(__endswith) withMemo:_endswith_memo];
}

- (void)__like {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_LIKE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLike:)];
}

- (void)like_ {
    [self parseRule:@selector(__like) withMemo:_like_memo];
}

- (void)__matches {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_MATCHES discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMatches:)];
}

- (void)matches_ {
    [self parseRule:@selector(__matches) withMemo:_matches_memo];
}

- (void)__collectionTestPredicate {
    
    [self value_]; 
    [self inKeyword_]; 
    [self collection_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCollectionTestPredicate:)];
}

- (void)collectionTestPredicate_ {
    [self parseRule:@selector(__collectionTestPredicate) withMemo:_collectionTestPredicate_memo];
}

- (void)__collection {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self keyPath_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_OPEN_CURLY, 0]) {
        [self array_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'collection'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchCollection:)];
}

- (void)collection_ {
    [self parseRule:@selector(__collection) withMemo:_collection_memo];
}

- (void)__inKeyword {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_INKEYWORD discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchInKeyword:)];
}

- (void)inKeyword_ {
    [self parseRule:@selector(__inKeyword) withMemo:_inKeyword_memo];
}

- (void)__aggregateOp {
    
    if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ANY, 0]) {
        [self any_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_SOME, 0]) {
        [self some_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_ALL, 0]) {
        [self all_]; 
    } else if ([self predicts:TDNSPREDICATE_TOKEN_KIND_NONE, 0]) {
        [self none_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'aggregateOp'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAggregateOp:)];
}

- (void)aggregateOp_ {
    [self parseRule:@selector(__aggregateOp) withMemo:_aggregateOp_memo];
}

- (void)__any {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_ANY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAny:)];
}

- (void)any_ {
    [self parseRule:@selector(__any) withMemo:_any_memo];
}

- (void)__some {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_SOME discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSome:)];
}

- (void)some_ {
    [self parseRule:@selector(__some) withMemo:_some_memo];
}

- (void)__all {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_ALL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAll:)];
}

- (void)all_ {
    [self parseRule:@selector(__all) withMemo:_all_memo];
}

- (void)__none {
    
    [self match:TDNSPREDICATE_TOKEN_KIND_NONE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNone:)];
}

- (void)none_ {
    [self parseRule:@selector(__none) withMemo:_none_memo];
}

@end