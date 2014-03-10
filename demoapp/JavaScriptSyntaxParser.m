#import "JavaScriptSyntaxParser.h"
#import <ParseKit/ParseKit.h>

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

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PEGParser ()
@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
@property (nonatomic, retain) NSString *startRuleName;

- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;

- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName;
@end

@interface JavaScriptSyntaxParser ()
@property (nonatomic, retain) NSMutableDictionary *ifSym_memo;
@property (nonatomic, retain) NSMutableDictionary *elseSym_memo;
@property (nonatomic, retain) NSMutableDictionary *whileSym_memo;
@property (nonatomic, retain) NSMutableDictionary *forSym_memo;
@property (nonatomic, retain) NSMutableDictionary *inSym_memo;
@property (nonatomic, retain) NSMutableDictionary *breakSym_memo;
@property (nonatomic, retain) NSMutableDictionary *continueSym_memo;
@property (nonatomic, retain) NSMutableDictionary *with_memo;
@property (nonatomic, retain) NSMutableDictionary *returnSym_memo;
@property (nonatomic, retain) NSMutableDictionary *var_memo;
@property (nonatomic, retain) NSMutableDictionary *delete_memo;
@property (nonatomic, retain) NSMutableDictionary *keywordNew_memo;
@property (nonatomic, retain) NSMutableDictionary *this_memo;
@property (nonatomic, retain) NSMutableDictionary *false_memo;
@property (nonatomic, retain) NSMutableDictionary *true_memo;
@property (nonatomic, retain) NSMutableDictionary *null_memo;
@property (nonatomic, retain) NSMutableDictionary *undefined_memo;
@property (nonatomic, retain) NSMutableDictionary *void_memo;
@property (nonatomic, retain) NSMutableDictionary *typeof_memo;
@property (nonatomic, retain) NSMutableDictionary *instanceof_memo;
@property (nonatomic, retain) NSMutableDictionary *function_memo;
@property (nonatomic, retain) NSMutableDictionary *openCurly_memo;
@property (nonatomic, retain) NSMutableDictionary *closeCurly_memo;
@property (nonatomic, retain) NSMutableDictionary *openParen_memo;
@property (nonatomic, retain) NSMutableDictionary *closeParen_memo;
@property (nonatomic, retain) NSMutableDictionary *openBracket_memo;
@property (nonatomic, retain) NSMutableDictionary *closeBracket_memo;
@property (nonatomic, retain) NSMutableDictionary *comma_memo;
@property (nonatomic, retain) NSMutableDictionary *dot_memo;
@property (nonatomic, retain) NSMutableDictionary *semi_memo;
@property (nonatomic, retain) NSMutableDictionary *colon_memo;
@property (nonatomic, retain) NSMutableDictionary *equals_memo;
@property (nonatomic, retain) NSMutableDictionary *not_memo;
@property (nonatomic, retain) NSMutableDictionary *lt_memo;
@property (nonatomic, retain) NSMutableDictionary *gt_memo;
@property (nonatomic, retain) NSMutableDictionary *amp_memo;
@property (nonatomic, retain) NSMutableDictionary *pipe_memo;
@property (nonatomic, retain) NSMutableDictionary *caret_memo;
@property (nonatomic, retain) NSMutableDictionary *tilde_memo;
@property (nonatomic, retain) NSMutableDictionary *question_memo;
@property (nonatomic, retain) NSMutableDictionary *plus_memo;
@property (nonatomic, retain) NSMutableDictionary *minus_memo;
@property (nonatomic, retain) NSMutableDictionary *times_memo;
@property (nonatomic, retain) NSMutableDictionary *div_memo;
@property (nonatomic, retain) NSMutableDictionary *mod_memo;
@property (nonatomic, retain) NSMutableDictionary *or_memo;
@property (nonatomic, retain) NSMutableDictionary *and_memo;
@property (nonatomic, retain) NSMutableDictionary *ne_memo;
@property (nonatomic, retain) NSMutableDictionary *isnot_memo;
@property (nonatomic, retain) NSMutableDictionary *eq_memo;
@property (nonatomic, retain) NSMutableDictionary *is_memo;
@property (nonatomic, retain) NSMutableDictionary *le_memo;
@property (nonatomic, retain) NSMutableDictionary *ge_memo;
@property (nonatomic, retain) NSMutableDictionary *plusPlus_memo;
@property (nonatomic, retain) NSMutableDictionary *minusMinus_memo;
@property (nonatomic, retain) NSMutableDictionary *plusEq_memo;
@property (nonatomic, retain) NSMutableDictionary *minusEq_memo;
@property (nonatomic, retain) NSMutableDictionary *timesEq_memo;
@property (nonatomic, retain) NSMutableDictionary *divEq_memo;
@property (nonatomic, retain) NSMutableDictionary *modEq_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftLeft_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftRight_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftRightExt_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftLeftEq_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftRightEq_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftRightExtEq_memo;
@property (nonatomic, retain) NSMutableDictionary *andEq_memo;
@property (nonatomic, retain) NSMutableDictionary *xorEq_memo;
@property (nonatomic, retain) NSMutableDictionary *orEq_memo;
@property (nonatomic, retain) NSMutableDictionary *assignmentOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *relationalOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *equalityOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *incrementOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *multiplicativeOperator_memo;
@property (nonatomic, retain) NSMutableDictionary *program_memo;
@property (nonatomic, retain) NSMutableDictionary *element_memo;
@property (nonatomic, retain) NSMutableDictionary *func_memo;
@property (nonatomic, retain) NSMutableDictionary *paramListOpt_memo;
@property (nonatomic, retain) NSMutableDictionary *paramList_memo;
@property (nonatomic, retain) NSMutableDictionary *commaIdentifier_memo;
@property (nonatomic, retain) NSMutableDictionary *compoundStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *stmts_memo;
@property (nonatomic, retain) NSMutableDictionary *stmt_memo;
@property (nonatomic, retain) NSMutableDictionary *ifStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *ifElseStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *whileStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *forParenStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *forBeginStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *forInStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *breakStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *continueStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *withStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *returnStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *variablesOrExprStmt_memo;
@property (nonatomic, retain) NSMutableDictionary *condition_memo;
@property (nonatomic, retain) NSMutableDictionary *forParen_memo;
@property (nonatomic, retain) NSMutableDictionary *forBegin_memo;
@property (nonatomic, retain) NSMutableDictionary *variablesOrExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *varVariables_memo;
@property (nonatomic, retain) NSMutableDictionary *variables_memo;
@property (nonatomic, retain) NSMutableDictionary *commaVariable_memo;
@property (nonatomic, retain) NSMutableDictionary *variable_memo;
@property (nonatomic, retain) NSMutableDictionary *assignment_memo;
@property (nonatomic, retain) NSMutableDictionary *exprOpt_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *commaExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *assignmentExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *extraAssignment_memo;
@property (nonatomic, retain) NSMutableDictionary *conditionalExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *ternaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *orExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *orAndExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *andExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *andAndExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *bitwiseOrExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *pipeBitwiseOrExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *bitwiseXorExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *caretBitwiseXorExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *bitwiseAndExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *ampBitwiseAndExpression_memo;
@property (nonatomic, retain) NSMutableDictionary *equalityExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *equalityOpEqualityExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *relationalExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *shiftOpShiftExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *additiveExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *plusOrMinusExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *plusExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *minusExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *multiplicativeExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryExpr1_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryExpr2_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryExpr3_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryExpr4_memo;
@property (nonatomic, retain) NSMutableDictionary *callNewExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *unaryExpr6_memo;
@property (nonatomic, retain) NSMutableDictionary *constructor_memo;
@property (nonatomic, retain) NSMutableDictionary *constructorCall_memo;
@property (nonatomic, retain) NSMutableDictionary *parenArgListParen_memo;
@property (nonatomic, retain) NSMutableDictionary *memberExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *dotBracketOrParenExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *dotMemberExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *bracketMemberExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *parenMemberExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *argListOpt_memo;
@property (nonatomic, retain) NSMutableDictionary *argList_memo;
@property (nonatomic, retain) NSMutableDictionary *commaAssignmentExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *primaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *parenExprParen_memo;
@property (nonatomic, retain) NSMutableDictionary *identifier_memo;
@property (nonatomic, retain) NSMutableDictionary *numLiteral_memo;
@property (nonatomic, retain) NSMutableDictionary *stringLiteral_memo;
@end

@implementation JavaScriptSyntaxParser

- (id)init {
    self = [super init];
    if (self) {
        self.tokenKindTab[@"|"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PIPE);
        self.tokenKindTab[@"!="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NE);
        self.tokenKindTab[@"("] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN);
        self.tokenKindTab[@"}"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSECURLY);
        self.tokenKindTab[@"return"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_RETURNSYM);
        self.tokenKindTab[@"~"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE);
        self.tokenKindTab[@")"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSEPAREN);
        self.tokenKindTab[@"*"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMES);
        self.tokenKindTab[@"delete"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE);
        self.tokenKindTab[@"!=="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ISNOT);
        self.tokenKindTab[@"+"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUS);
        self.tokenKindTab[@"*="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMESEQ);
        self.tokenKindTab[@"instanceof"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSTANCEOF);
        self.tokenKindTab[@","] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"<<="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFTEQ);
        self.tokenKindTab[@"if"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IFSYM);
        self.tokenKindTab[@"-"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS);
        self.tokenKindTab[@"null"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL);
        self.tokenKindTab[@"false"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE);
        self.tokenKindTab[@"."] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@"<<"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFT);
        self.tokenKindTab[@"/"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIV);
        self.tokenKindTab[@"+="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSEQ);
        self.tokenKindTab[@"<="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LE);
        self.tokenKindTab[@"^="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_XOREQ);
        self.tokenKindTab[@"["] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENBRACKET);
        self.tokenKindTab[@"undefined"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED);
        self.tokenKindTab[@"typeof"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF);
        self.tokenKindTab[@"||"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OR);
        self.tokenKindTab[@"function"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FUNCTION);
        self.tokenKindTab[@"]"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSEBRACKET);
        self.tokenKindTab[@"^"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CARET);
        self.tokenKindTab[@"=="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQ);
        self.tokenKindTab[@"continue"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CONTINUESYM);
        self.tokenKindTab[@"break"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_BREAKSYM);
        self.tokenKindTab[@"-="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSEQ);
        self.tokenKindTab[@">="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GE);
        self.tokenKindTab[@":"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COLON);
        self.tokenKindTab[@"in"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSYM);
        self.tokenKindTab[@";"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SEMI);
        self.tokenKindTab[@"for"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FORSYM);
        self.tokenKindTab[@"++"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS);
        self.tokenKindTab[@"<"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LT);
        self.tokenKindTab[@"%="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MODEQ);
        self.tokenKindTab[@">>"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHT);
        self.tokenKindTab[@"="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@">"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GT);
        self.tokenKindTab[@"void"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID);
        self.tokenKindTab[@"?"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_QUESTION);
        self.tokenKindTab[@"while"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WHILESYM);
        self.tokenKindTab[@"&="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ANDEQ);
        self.tokenKindTab[@">>>="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXTEQ);
        self.tokenKindTab[@"else"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ELSESYM);
        self.tokenKindTab[@"/="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIVEQ);
        self.tokenKindTab[@"&&"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_AND);
        self.tokenKindTab[@"var"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VAR);
        self.tokenKindTab[@"|="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OREQ);
        self.tokenKindTab[@">>="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEQ);
        self.tokenKindTab[@"--"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS);
        self.tokenKindTab[@"new"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW);
        self.tokenKindTab[@"!"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NOT);
        self.tokenKindTab[@">>>"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXT);
        self.tokenKindTab[@"true"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"this"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS);
        self.tokenKindTab[@"with"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WITH);
        self.tokenKindTab[@"==="] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IS);
        self.tokenKindTab[@"%"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MOD);
        self.tokenKindTab[@"&"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_AMP);
        self.tokenKindTab[@"{"] = @(JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENCURLY);

        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PIPE] = @"|";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN] = @"(";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSECURLY] = @"}";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_RETURNSYM] = @"return";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE] = @"~";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSEPAREN] = @")";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMES] = @"*";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE] = @"delete";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ISNOT] = @"!==";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUS] = @"+";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMESEQ] = @"*=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSTANCEOF] = @"instanceof";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFTEQ] = @"<<=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IFSYM] = @"if";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS] = @"-";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL] = @"null";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFT] = @"<<";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIV] = @"/";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSEQ] = @"+=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_XOREQ] = @"^=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENBRACKET] = @"[";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED] = @"undefined";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF] = @"typeof";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OR] = @"||";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FUNCTION] = @"function";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSEBRACKET] = @"]";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CARET] = @"^";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQ] = @"==";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CONTINUESYM] = @"continue";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_BREAKSYM] = @"break";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSEQ] = @"-=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSYM] = @"in";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SEMI] = @";";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FORSYM] = @"for";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS] = @"++";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LT] = @"<";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MODEQ] = @"%=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHT] = @">>";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GT] = @">";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID] = @"void";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_QUESTION] = @"?";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WHILESYM] = @"while";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ANDEQ] = @"&=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXTEQ] = @">>>=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ELSESYM] = @"else";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIVEQ] = @"/=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_AND] = @"&&";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VAR] = @"var";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OREQ] = @"|=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEQ] = @">>=";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS] = @"--";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW] = @"new";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NOT] = @"!";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXT] = @">>>";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS] = @"this";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WITH] = @"with";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IS] = @"===";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MOD] = @"%";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_AMP] = @"&";
        self.tokenKindNameTab[JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENCURLY] = @"{";

        self.ifSym_memo = [NSMutableDictionary dictionary];
        self.elseSym_memo = [NSMutableDictionary dictionary];
        self.whileSym_memo = [NSMutableDictionary dictionary];
        self.forSym_memo = [NSMutableDictionary dictionary];
        self.inSym_memo = [NSMutableDictionary dictionary];
        self.breakSym_memo = [NSMutableDictionary dictionary];
        self.continueSym_memo = [NSMutableDictionary dictionary];
        self.with_memo = [NSMutableDictionary dictionary];
        self.returnSym_memo = [NSMutableDictionary dictionary];
        self.var_memo = [NSMutableDictionary dictionary];
        self.delete_memo = [NSMutableDictionary dictionary];
        self.keywordNew_memo = [NSMutableDictionary dictionary];
        self.this_memo = [NSMutableDictionary dictionary];
        self.false_memo = [NSMutableDictionary dictionary];
        self.true_memo = [NSMutableDictionary dictionary];
        self.null_memo = [NSMutableDictionary dictionary];
        self.undefined_memo = [NSMutableDictionary dictionary];
        self.void_memo = [NSMutableDictionary dictionary];
        self.typeof_memo = [NSMutableDictionary dictionary];
        self.instanceof_memo = [NSMutableDictionary dictionary];
        self.function_memo = [NSMutableDictionary dictionary];
        self.openCurly_memo = [NSMutableDictionary dictionary];
        self.closeCurly_memo = [NSMutableDictionary dictionary];
        self.openParen_memo = [NSMutableDictionary dictionary];
        self.closeParen_memo = [NSMutableDictionary dictionary];
        self.openBracket_memo = [NSMutableDictionary dictionary];
        self.closeBracket_memo = [NSMutableDictionary dictionary];
        self.comma_memo = [NSMutableDictionary dictionary];
        self.dot_memo = [NSMutableDictionary dictionary];
        self.semi_memo = [NSMutableDictionary dictionary];
        self.colon_memo = [NSMutableDictionary dictionary];
        self.equals_memo = [NSMutableDictionary dictionary];
        self.not_memo = [NSMutableDictionary dictionary];
        self.lt_memo = [NSMutableDictionary dictionary];
        self.gt_memo = [NSMutableDictionary dictionary];
        self.amp_memo = [NSMutableDictionary dictionary];
        self.pipe_memo = [NSMutableDictionary dictionary];
        self.caret_memo = [NSMutableDictionary dictionary];
        self.tilde_memo = [NSMutableDictionary dictionary];
        self.question_memo = [NSMutableDictionary dictionary];
        self.plus_memo = [NSMutableDictionary dictionary];
        self.minus_memo = [NSMutableDictionary dictionary];
        self.times_memo = [NSMutableDictionary dictionary];
        self.div_memo = [NSMutableDictionary dictionary];
        self.mod_memo = [NSMutableDictionary dictionary];
        self.or_memo = [NSMutableDictionary dictionary];
        self.and_memo = [NSMutableDictionary dictionary];
        self.ne_memo = [NSMutableDictionary dictionary];
        self.isnot_memo = [NSMutableDictionary dictionary];
        self.eq_memo = [NSMutableDictionary dictionary];
        self.is_memo = [NSMutableDictionary dictionary];
        self.le_memo = [NSMutableDictionary dictionary];
        self.ge_memo = [NSMutableDictionary dictionary];
        self.plusPlus_memo = [NSMutableDictionary dictionary];
        self.minusMinus_memo = [NSMutableDictionary dictionary];
        self.plusEq_memo = [NSMutableDictionary dictionary];
        self.minusEq_memo = [NSMutableDictionary dictionary];
        self.timesEq_memo = [NSMutableDictionary dictionary];
        self.divEq_memo = [NSMutableDictionary dictionary];
        self.modEq_memo = [NSMutableDictionary dictionary];
        self.shiftLeft_memo = [NSMutableDictionary dictionary];
        self.shiftRight_memo = [NSMutableDictionary dictionary];
        self.shiftRightExt_memo = [NSMutableDictionary dictionary];
        self.shiftLeftEq_memo = [NSMutableDictionary dictionary];
        self.shiftRightEq_memo = [NSMutableDictionary dictionary];
        self.shiftRightExtEq_memo = [NSMutableDictionary dictionary];
        self.andEq_memo = [NSMutableDictionary dictionary];
        self.xorEq_memo = [NSMutableDictionary dictionary];
        self.orEq_memo = [NSMutableDictionary dictionary];
        self.assignmentOperator_memo = [NSMutableDictionary dictionary];
        self.relationalOperator_memo = [NSMutableDictionary dictionary];
        self.equalityOperator_memo = [NSMutableDictionary dictionary];
        self.shiftOperator_memo = [NSMutableDictionary dictionary];
        self.incrementOperator_memo = [NSMutableDictionary dictionary];
        self.unaryOperator_memo = [NSMutableDictionary dictionary];
        self.multiplicativeOperator_memo = [NSMutableDictionary dictionary];
        self.program_memo = [NSMutableDictionary dictionary];
        self.element_memo = [NSMutableDictionary dictionary];
        self.func_memo = [NSMutableDictionary dictionary];
        self.paramListOpt_memo = [NSMutableDictionary dictionary];
        self.paramList_memo = [NSMutableDictionary dictionary];
        self.commaIdentifier_memo = [NSMutableDictionary dictionary];
        self.compoundStmt_memo = [NSMutableDictionary dictionary];
        self.stmts_memo = [NSMutableDictionary dictionary];
        self.stmt_memo = [NSMutableDictionary dictionary];
        self.ifStmt_memo = [NSMutableDictionary dictionary];
        self.ifElseStmt_memo = [NSMutableDictionary dictionary];
        self.whileStmt_memo = [NSMutableDictionary dictionary];
        self.forParenStmt_memo = [NSMutableDictionary dictionary];
        self.forBeginStmt_memo = [NSMutableDictionary dictionary];
        self.forInStmt_memo = [NSMutableDictionary dictionary];
        self.breakStmt_memo = [NSMutableDictionary dictionary];
        self.continueStmt_memo = [NSMutableDictionary dictionary];
        self.withStmt_memo = [NSMutableDictionary dictionary];
        self.returnStmt_memo = [NSMutableDictionary dictionary];
        self.variablesOrExprStmt_memo = [NSMutableDictionary dictionary];
        self.condition_memo = [NSMutableDictionary dictionary];
        self.forParen_memo = [NSMutableDictionary dictionary];
        self.forBegin_memo = [NSMutableDictionary dictionary];
        self.variablesOrExpr_memo = [NSMutableDictionary dictionary];
        self.varVariables_memo = [NSMutableDictionary dictionary];
        self.variables_memo = [NSMutableDictionary dictionary];
        self.commaVariable_memo = [NSMutableDictionary dictionary];
        self.variable_memo = [NSMutableDictionary dictionary];
        self.assignment_memo = [NSMutableDictionary dictionary];
        self.exprOpt_memo = [NSMutableDictionary dictionary];
        self.expr_memo = [NSMutableDictionary dictionary];
        self.commaExpr_memo = [NSMutableDictionary dictionary];
        self.assignmentExpr_memo = [NSMutableDictionary dictionary];
        self.extraAssignment_memo = [NSMutableDictionary dictionary];
        self.conditionalExpr_memo = [NSMutableDictionary dictionary];
        self.ternaryExpr_memo = [NSMutableDictionary dictionary];
        self.orExpr_memo = [NSMutableDictionary dictionary];
        self.orAndExpr_memo = [NSMutableDictionary dictionary];
        self.andExpr_memo = [NSMutableDictionary dictionary];
        self.andAndExpr_memo = [NSMutableDictionary dictionary];
        self.bitwiseOrExpr_memo = [NSMutableDictionary dictionary];
        self.pipeBitwiseOrExpr_memo = [NSMutableDictionary dictionary];
        self.bitwiseXorExpr_memo = [NSMutableDictionary dictionary];
        self.caretBitwiseXorExpr_memo = [NSMutableDictionary dictionary];
        self.bitwiseAndExpr_memo = [NSMutableDictionary dictionary];
        self.ampBitwiseAndExpression_memo = [NSMutableDictionary dictionary];
        self.equalityExpr_memo = [NSMutableDictionary dictionary];
        self.equalityOpEqualityExpr_memo = [NSMutableDictionary dictionary];
        self.relationalExpr_memo = [NSMutableDictionary dictionary];
        self.shiftExpr_memo = [NSMutableDictionary dictionary];
        self.shiftOpShiftExpr_memo = [NSMutableDictionary dictionary];
        self.additiveExpr_memo = [NSMutableDictionary dictionary];
        self.plusOrMinusExpr_memo = [NSMutableDictionary dictionary];
        self.plusExpr_memo = [NSMutableDictionary dictionary];
        self.minusExpr_memo = [NSMutableDictionary dictionary];
        self.multiplicativeExpr_memo = [NSMutableDictionary dictionary];
        self.unaryExpr_memo = [NSMutableDictionary dictionary];
        self.unaryExpr1_memo = [NSMutableDictionary dictionary];
        self.unaryExpr2_memo = [NSMutableDictionary dictionary];
        self.unaryExpr3_memo = [NSMutableDictionary dictionary];
        self.unaryExpr4_memo = [NSMutableDictionary dictionary];
        self.callNewExpr_memo = [NSMutableDictionary dictionary];
        self.unaryExpr6_memo = [NSMutableDictionary dictionary];
        self.constructor_memo = [NSMutableDictionary dictionary];
        self.constructorCall_memo = [NSMutableDictionary dictionary];
        self.parenArgListParen_memo = [NSMutableDictionary dictionary];
        self.memberExpr_memo = [NSMutableDictionary dictionary];
        self.dotBracketOrParenExpr_memo = [NSMutableDictionary dictionary];
        self.dotMemberExpr_memo = [NSMutableDictionary dictionary];
        self.bracketMemberExpr_memo = [NSMutableDictionary dictionary];
        self.parenMemberExpr_memo = [NSMutableDictionary dictionary];
        self.argListOpt_memo = [NSMutableDictionary dictionary];
        self.argList_memo = [NSMutableDictionary dictionary];
        self.commaAssignmentExpr_memo = [NSMutableDictionary dictionary];
        self.primaryExpr_memo = [NSMutableDictionary dictionary];
        self.parenExprParen_memo = [NSMutableDictionary dictionary];
        self.identifier_memo = [NSMutableDictionary dictionary];
        self.numLiteral_memo = [NSMutableDictionary dictionary];
        self.stringLiteral_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)_clearMemo {
    [_ifSym_memo removeAllObjects];
    [_elseSym_memo removeAllObjects];
    [_whileSym_memo removeAllObjects];
    [_forSym_memo removeAllObjects];
    [_inSym_memo removeAllObjects];
    [_breakSym_memo removeAllObjects];
    [_continueSym_memo removeAllObjects];
    [_with_memo removeAllObjects];
    [_returnSym_memo removeAllObjects];
    [_var_memo removeAllObjects];
    [_delete_memo removeAllObjects];
    [_keywordNew_memo removeAllObjects];
    [_this_memo removeAllObjects];
    [_false_memo removeAllObjects];
    [_true_memo removeAllObjects];
    [_null_memo removeAllObjects];
    [_undefined_memo removeAllObjects];
    [_void_memo removeAllObjects];
    [_typeof_memo removeAllObjects];
    [_instanceof_memo removeAllObjects];
    [_function_memo removeAllObjects];
    [_openCurly_memo removeAllObjects];
    [_closeCurly_memo removeAllObjects];
    [_openParen_memo removeAllObjects];
    [_closeParen_memo removeAllObjects];
    [_openBracket_memo removeAllObjects];
    [_closeBracket_memo removeAllObjects];
    [_comma_memo removeAllObjects];
    [_dot_memo removeAllObjects];
    [_semi_memo removeAllObjects];
    [_colon_memo removeAllObjects];
    [_equals_memo removeAllObjects];
    [_not_memo removeAllObjects];
    [_lt_memo removeAllObjects];
    [_gt_memo removeAllObjects];
    [_amp_memo removeAllObjects];
    [_pipe_memo removeAllObjects];
    [_caret_memo removeAllObjects];
    [_tilde_memo removeAllObjects];
    [_question_memo removeAllObjects];
    [_plus_memo removeAllObjects];
    [_minus_memo removeAllObjects];
    [_times_memo removeAllObjects];
    [_div_memo removeAllObjects];
    [_mod_memo removeAllObjects];
    [_or_memo removeAllObjects];
    [_and_memo removeAllObjects];
    [_ne_memo removeAllObjects];
    [_isnot_memo removeAllObjects];
    [_eq_memo removeAllObjects];
    [_is_memo removeAllObjects];
    [_le_memo removeAllObjects];
    [_ge_memo removeAllObjects];
    [_plusPlus_memo removeAllObjects];
    [_minusMinus_memo removeAllObjects];
    [_plusEq_memo removeAllObjects];
    [_minusEq_memo removeAllObjects];
    [_timesEq_memo removeAllObjects];
    [_divEq_memo removeAllObjects];
    [_modEq_memo removeAllObjects];
    [_shiftLeft_memo removeAllObjects];
    [_shiftRight_memo removeAllObjects];
    [_shiftRightExt_memo removeAllObjects];
    [_shiftLeftEq_memo removeAllObjects];
    [_shiftRightEq_memo removeAllObjects];
    [_shiftRightExtEq_memo removeAllObjects];
    [_andEq_memo removeAllObjects];
    [_xorEq_memo removeAllObjects];
    [_orEq_memo removeAllObjects];
    [_assignmentOperator_memo removeAllObjects];
    [_relationalOperator_memo removeAllObjects];
    [_equalityOperator_memo removeAllObjects];
    [_shiftOperator_memo removeAllObjects];
    [_incrementOperator_memo removeAllObjects];
    [_unaryOperator_memo removeAllObjects];
    [_multiplicativeOperator_memo removeAllObjects];
    [_program_memo removeAllObjects];
    [_element_memo removeAllObjects];
    [_func_memo removeAllObjects];
    [_paramListOpt_memo removeAllObjects];
    [_paramList_memo removeAllObjects];
    [_commaIdentifier_memo removeAllObjects];
    [_compoundStmt_memo removeAllObjects];
    [_stmts_memo removeAllObjects];
    [_stmt_memo removeAllObjects];
    [_ifStmt_memo removeAllObjects];
    [_ifElseStmt_memo removeAllObjects];
    [_whileStmt_memo removeAllObjects];
    [_forParenStmt_memo removeAllObjects];
    [_forBeginStmt_memo removeAllObjects];
    [_forInStmt_memo removeAllObjects];
    [_breakStmt_memo removeAllObjects];
    [_continueStmt_memo removeAllObjects];
    [_withStmt_memo removeAllObjects];
    [_returnStmt_memo removeAllObjects];
    [_variablesOrExprStmt_memo removeAllObjects];
    [_condition_memo removeAllObjects];
    [_forParen_memo removeAllObjects];
    [_forBegin_memo removeAllObjects];
    [_variablesOrExpr_memo removeAllObjects];
    [_varVariables_memo removeAllObjects];
    [_variables_memo removeAllObjects];
    [_commaVariable_memo removeAllObjects];
    [_variable_memo removeAllObjects];
    [_assignment_memo removeAllObjects];
    [_exprOpt_memo removeAllObjects];
    [_expr_memo removeAllObjects];
    [_commaExpr_memo removeAllObjects];
    [_assignmentExpr_memo removeAllObjects];
    [_extraAssignment_memo removeAllObjects];
    [_conditionalExpr_memo removeAllObjects];
    [_ternaryExpr_memo removeAllObjects];
    [_orExpr_memo removeAllObjects];
    [_orAndExpr_memo removeAllObjects];
    [_andExpr_memo removeAllObjects];
    [_andAndExpr_memo removeAllObjects];
    [_bitwiseOrExpr_memo removeAllObjects];
    [_pipeBitwiseOrExpr_memo removeAllObjects];
    [_bitwiseXorExpr_memo removeAllObjects];
    [_caretBitwiseXorExpr_memo removeAllObjects];
    [_bitwiseAndExpr_memo removeAllObjects];
    [_ampBitwiseAndExpression_memo removeAllObjects];
    [_equalityExpr_memo removeAllObjects];
    [_equalityOpEqualityExpr_memo removeAllObjects];
    [_relationalExpr_memo removeAllObjects];
    [_shiftExpr_memo removeAllObjects];
    [_shiftOpShiftExpr_memo removeAllObjects];
    [_additiveExpr_memo removeAllObjects];
    [_plusOrMinusExpr_memo removeAllObjects];
    [_plusExpr_memo removeAllObjects];
    [_minusExpr_memo removeAllObjects];
    [_multiplicativeExpr_memo removeAllObjects];
    [_unaryExpr_memo removeAllObjects];
    [_unaryExpr1_memo removeAllObjects];
    [_unaryExpr2_memo removeAllObjects];
    [_unaryExpr3_memo removeAllObjects];
    [_unaryExpr4_memo removeAllObjects];
    [_callNewExpr_memo removeAllObjects];
    [_unaryExpr6_memo removeAllObjects];
    [_constructor_memo removeAllObjects];
    [_constructorCall_memo removeAllObjects];
    [_parenArgListParen_memo removeAllObjects];
    [_memberExpr_memo removeAllObjects];
    [_dotBracketOrParenExpr_memo removeAllObjects];
    [_dotMemberExpr_memo removeAllObjects];
    [_bracketMemberExpr_memo removeAllObjects];
    [_parenMemberExpr_memo removeAllObjects];
    [_argListOpt_memo removeAllObjects];
    [_argList_memo removeAllObjects];
    [_commaAssignmentExpr_memo removeAllObjects];
    [_primaryExpr_memo removeAllObjects];
    [_parenExprParen_memo removeAllObjects];
    [_identifier_memo removeAllObjects];
    [_numLiteral_memo removeAllObjects];
    [_stringLiteral_memo removeAllObjects];
}

- (void)start {
    
    [self execute:(id)^{
    
        PKTokenizer *t = self.tokenizer;
        
        // whitespace
    //    self.silentlyConsumesWhitespace = YES;
    //    t.whitespaceState.reportsWhitespaceTokens = YES;
    //    self.assembly.preservesWhitespaceTokens = YES;

        [t.symbolState add:@"||"];
        [t.symbolState add:@"&&"];
        [t.symbolState add:@"!="];
        [t.symbolState add:@"!=="];
        [t.symbolState add:@"=="];
        [t.symbolState add:@"==="];
        [t.symbolState add:@"<="];
        [t.symbolState add:@">="];
        [t.symbolState add:@"++"];
        [t.symbolState add:@"--"];
        [t.symbolState add:@"+="];
        [t.symbolState add:@"-="];
        [t.symbolState add:@"*="];
        [t.symbolState add:@"/="];
        [t.symbolState add:@"%="];
        [t.symbolState add:@"<<"];
        [t.symbolState add:@">>"];
        [t.symbolState add:@">>>"];
        [t.symbolState add:@"<<="];
        [t.symbolState add:@">>="];
        [t.symbolState add:@">>>="];
        [t.symbolState add:@"&="];
        [t.symbolState add:@"^="];
        [t.symbolState add:@"|="];

        t.commentState.reportsCommentTokens = YES;
        
        [t setTokenizerState:t.commentState from:'/' to:'/'];
        [t.commentState addSingleLineStartMarker:@"//"];
        [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];

    }];
    [self program]; 
    [self matchEOF:YES]; 

}

- (void)__if {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"if"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"if"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IFSYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"if"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"if"];
}

- (void)if {
    [self parseRule:@selector(__if) withMemo:_ifSym_memo];
}

- (void)__else {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"else"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"else"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ELSESYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"else"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"else"];
}

- (void)else {
    [self parseRule:@selector(__else) withMemo:_elseSym_memo];
}

- (void)__while {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"while"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"while"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WHILESYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"while"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"while"];
}

- (void)while {
    [self parseRule:@selector(__while) withMemo:_whileSym_memo];
}

- (void)__for {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"for"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"for"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FORSYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"for"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"for"];
}

- (void)for {
    [self parseRule:@selector(__for) withMemo:_forSym_memo];
}

- (void)__in {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"in"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"in"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"in"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"in"];
}

- (void)in {
    [self parseRule:@selector(__in) withMemo:_inSym_memo];
}

- (void)__break {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"break"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"break"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_BREAKSYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"break"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"break"];
}

- (void)break {
    [self parseRule:@selector(__break) withMemo:_breakSym_memo];
}

- (void)__continue {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"continue"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"continue"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CONTINUESYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"continue"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"continue"];
}

- (void)continue {
    [self parseRule:@selector(__continue) withMemo:_continueSym_memo];
}

- (void)__with {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"with"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"with"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WITH discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"with"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"with"];
}

- (void)with {
    [self parseRule:@selector(__with) withMemo:_with_memo];
}

- (void)__return {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"return"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"return"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_RETURNSYM discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"return"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"return"];
}

- (void)return {
    [self parseRule:@selector(__return) withMemo:_returnSym_memo];
}

- (void)__var {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"var"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"var"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VAR discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"var"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"var"];
}

- (void)var {
    [self parseRule:@selector(__var) withMemo:_var_memo];
}

- (void)__delete {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"delete"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"delete"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"delete"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"delete"];
}

- (void)delete {
    [self parseRule:@selector(__delete) withMemo:_delete_memo];
}

- (void)__keywordNew {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"keywordNew"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"keywordNew"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"keywordNew"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"keywordNew"];
}

- (void)keywordNew {
    [self parseRule:@selector(__keywordNew) withMemo:_keywordNew_memo];
}

- (void)__this {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"this"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"this"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"this"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"this"];
}

- (void)this {
    [self parseRule:@selector(__this) withMemo:_this_memo];
}

- (void)__false {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"false"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"false"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"false"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"false"];
}

- (void)false {
    [self parseRule:@selector(__false) withMemo:_false_memo];
}

- (void)__true {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"true"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"true"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"true"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"true"];
}

- (void)true {
    [self parseRule:@selector(__true) withMemo:_true_memo];
}

- (void)__null {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"null"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"null"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"null"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"null"];
}

- (void)null {
    [self parseRule:@selector(__null) withMemo:_null_memo];
}

- (void)__undefined {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"undefined"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"undefined"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"undefined"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"undefined"];
}

- (void)undefined {
    [self parseRule:@selector(__undefined) withMemo:_undefined_memo];
}

- (void)__void {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"void"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"void"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"void"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"void"];
}

- (void)void {
    [self parseRule:@selector(__void) withMemo:_void_memo];
}

- (void)__typeof {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"typeof"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"typeof"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"typeof"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"typeof"];
}

- (void)typeof {
    [self parseRule:@selector(__typeof) withMemo:_typeof_memo];
}

- (void)__instanceof {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"instanceof"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"instanceof"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSTANCEOF discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"instanceof"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"instanceof"];
}

- (void)instanceof {
    [self parseRule:@selector(__instanceof) withMemo:_instanceof_memo];
}

- (void)__function {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"function"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"function"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FUNCTION discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"function"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"function"];
}

- (void)function {
    [self parseRule:@selector(__function) withMemo:_function_memo];
}

- (void)__openCurly {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"openCurly"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"openCurly"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENCURLY discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"openCurly"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"openCurly"];
}

- (void)openCurly {
    [self parseRule:@selector(__openCurly) withMemo:_openCurly_memo];
}

- (void)__closeCurly {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"closeCurly"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"closeCurly"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSECURLY discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"closeCurly"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"closeCurly"];
}

- (void)closeCurly {
    [self parseRule:@selector(__closeCurly) withMemo:_closeCurly_memo];
}

- (void)__openParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"openParen"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"openParen"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"openParen"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"openParen"];
}

- (void)openParen {
    [self parseRule:@selector(__openParen) withMemo:_openParen_memo];
}

- (void)__closeParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"closeParen"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"closeParen"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSEPAREN discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"closeParen"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"closeParen"];
}

- (void)closeParen {
    [self parseRule:@selector(__closeParen) withMemo:_closeParen_memo];
}

- (void)__openBracket {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"openBracket"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"openBracket"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENBRACKET discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"openBracket"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"openBracket"];
}

- (void)openBracket {
    [self parseRule:@selector(__openBracket) withMemo:_openBracket_memo];
}

- (void)__closeBracket {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"closeBracket"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"closeBracket"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CLOSEBRACKET discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"closeBracket"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"closeBracket"];
}

- (void)closeBracket {
    [self parseRule:@selector(__closeBracket) withMemo:_closeBracket_memo];
}

- (void)__comma {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"comma"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"comma"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COMMA discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"comma"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"comma"];
}

- (void)comma {
    [self parseRule:@selector(__comma) withMemo:_comma_memo];
}

- (void)__dot {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"dot"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"dot"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DOT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"dot"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"dot"];
}

- (void)dot {
    [self parseRule:@selector(__dot) withMemo:_dot_memo];
}

- (void)__semi {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"semi"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"semi"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SEMI discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"semi"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"semi"];
}

- (void)semi {
    [self parseRule:@selector(__semi) withMemo:_semi_memo];
}

- (void)__colon {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"colon"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"colon"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COLON discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"colon"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"colon"];
}

- (void)colon {
    [self parseRule:@selector(__colon) withMemo:_colon_memo];
}

- (void)__equals {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"equals"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"equals"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQUALS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"equals"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"equals"];
}

- (void)equals {
    [self parseRule:@selector(__equals) withMemo:_equals_memo];
}

- (void)__not {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"not"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"not"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NOT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"not"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"not"];
}

- (void)not {
    [self parseRule:@selector(__not) withMemo:_not_memo];
}

- (void)__lt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"lt"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"lt"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"lt"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"lt"];
}

- (void)lt {
    [self parseRule:@selector(__lt) withMemo:_lt_memo];
}

- (void)__gt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"gt"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"gt"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"gt"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"gt"];
}

- (void)gt {
    [self parseRule:@selector(__gt) withMemo:_gt_memo];
}

- (void)__amp {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"amp"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"amp"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_AMP discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"amp"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"amp"];
}

- (void)amp {
    [self parseRule:@selector(__amp) withMemo:_amp_memo];
}

- (void)__pipe {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"pipe"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"pipe"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PIPE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"pipe"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"pipe"];
}

- (void)pipe {
    [self parseRule:@selector(__pipe) withMemo:_pipe_memo];
}

- (void)__caret {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"caret"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"caret"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CARET discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"caret"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"caret"];
}

- (void)caret {
    [self parseRule:@selector(__caret) withMemo:_caret_memo];
}

- (void)__tilde {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"tilde"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"tilde"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"tilde"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"tilde"];
}

- (void)tilde {
    [self parseRule:@selector(__tilde) withMemo:_tilde_memo];
}

- (void)__question {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"question"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"question"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_QUESTION discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"question"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"question"];
}

- (void)question {
    [self parseRule:@selector(__question) withMemo:_question_memo];
}

- (void)__plus {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"plus"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"plus"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"plus"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"plus"];
}

- (void)plus {
    [self parseRule:@selector(__plus) withMemo:_plus_memo];
}

- (void)__minus {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"minus"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"minus"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"minus"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"minus"];
}

- (void)minus {
    [self parseRule:@selector(__minus) withMemo:_minus_memo];
}

- (void)__times {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"times"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"times"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMES discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"times"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"times"];
}

- (void)times {
    [self parseRule:@selector(__times) withMemo:_times_memo];
}

- (void)__div {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"div"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"div"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIV discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"div"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"div"];
}

- (void)div {
    [self parseRule:@selector(__div) withMemo:_div_memo];
}

- (void)__mod {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"mod"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"mod"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MOD discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"mod"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"mod"];
}

- (void)mod {
    [self parseRule:@selector(__mod) withMemo:_mod_memo];
}

- (void)__or {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"or"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"or"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OR discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"or"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"or"];
}

- (void)or {
    [self parseRule:@selector(__or) withMemo:_or_memo];
}

- (void)__and {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"and"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"and"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_AND discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"and"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"and"];
}

- (void)and {
    [self parseRule:@selector(__and) withMemo:_and_memo];
}

- (void)__ne {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ne"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"ne"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"ne"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ne"];
}

- (void)ne {
    [self parseRule:@selector(__ne) withMemo:_ne_memo];
}

- (void)__isnot {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"isnot"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"isnot"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ISNOT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"isnot"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"isnot"];
}

- (void)isnot {
    [self parseRule:@selector(__isnot) withMemo:_isnot_memo];
}

- (void)__eq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"eq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"eq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"eq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"eq"];
}

- (void)eq {
    [self parseRule:@selector(__eq) withMemo:_eq_memo];
}

- (void)__is {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"is"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"is"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"is"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"is"];
}

- (void)is {
    [self parseRule:@selector(__is) withMemo:_is_memo];
}

- (void)__le {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"le"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"le"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"le"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"le"];
}

- (void)le {
    [self parseRule:@selector(__le) withMemo:_le_memo];
}

- (void)__ge {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ge"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"ge"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GE discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"ge"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ge"];
}

- (void)ge {
    [self parseRule:@selector(__ge) withMemo:_ge_memo];
}

- (void)__plusPlus {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"plusPlus"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"plusPlus"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"plusPlus"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"plusPlus"];
}

- (void)plusPlus {
    [self parseRule:@selector(__plusPlus) withMemo:_plusPlus_memo];
}

- (void)__minusMinus {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"minusMinus"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"minusMinus"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"minusMinus"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"minusMinus"];
}

- (void)minusMinus {
    [self parseRule:@selector(__minusMinus) withMemo:_minusMinus_memo];
}

- (void)__plusEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"plusEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"plusEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"plusEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"plusEq"];
}

- (void)plusEq {
    [self parseRule:@selector(__plusEq) withMemo:_plusEq_memo];
}

- (void)__minusEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"minusEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"minusEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"minusEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"minusEq"];
}

- (void)minusEq {
    [self parseRule:@selector(__minusEq) withMemo:_minusEq_memo];
}

- (void)__timesEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"timesEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"timesEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMESEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"timesEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"timesEq"];
}

- (void)timesEq {
    [self parseRule:@selector(__timesEq) withMemo:_timesEq_memo];
}

- (void)__divEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"divEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"divEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIVEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"divEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"divEq"];
}

- (void)divEq {
    [self parseRule:@selector(__divEq) withMemo:_divEq_memo];
}

- (void)__modEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"modEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"modEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MODEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"modEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"modEq"];
}

- (void)modEq {
    [self parseRule:@selector(__modEq) withMemo:_modEq_memo];
}

- (void)__shiftLeft {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftLeft"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"shiftLeft"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"shiftLeft"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftLeft"];
}

- (void)shiftLeft {
    [self parseRule:@selector(__shiftLeft) withMemo:_shiftLeft_memo];
}

- (void)__shiftRight {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftRight"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"shiftRight"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"shiftRight"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftRight"];
}

- (void)shiftRight {
    [self parseRule:@selector(__shiftRight) withMemo:_shiftRight_memo];
}

- (void)__shiftRightExt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftRightExt"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"shiftRightExt"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXT discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"shiftRightExt"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftRightExt"];
}

- (void)shiftRightExt {
    [self parseRule:@selector(__shiftRightExt) withMemo:_shiftRightExt_memo];
}

- (void)__shiftLeftEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftLeftEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"shiftLeftEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFTEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"shiftLeftEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftLeftEq"];
}

- (void)shiftLeftEq {
    [self parseRule:@selector(__shiftLeftEq) withMemo:_shiftLeftEq_memo];
}

- (void)__shiftRightEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftRightEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"shiftRightEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"shiftRightEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftRightEq"];
}

- (void)shiftRightEq {
    [self parseRule:@selector(__shiftRightEq) withMemo:_shiftRightEq_memo];
}

- (void)__shiftRightExtEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftRightExtEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"shiftRightExtEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXTEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"shiftRightExtEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftRightExtEq"];
}

- (void)shiftRightExtEq {
    [self parseRule:@selector(__shiftRightExtEq) withMemo:_shiftRightExtEq_memo];
}

- (void)__andEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"andEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"andEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ANDEQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"andEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"andEq"];
}

- (void)andEq {
    [self parseRule:@selector(__andEq) withMemo:_andEq_memo];
}

- (void)__xorEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"xorEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"xorEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_XOREQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"xorEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"xorEq"];
}

- (void)xorEq {
    [self parseRule:@selector(__xorEq) withMemo:_xorEq_memo];
}

- (void)__orEq {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"orEq"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"orEq"];

    [self match:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OREQ discard:NO]; 

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"orEq"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"orEq"];
}

- (void)orEq {
    [self parseRule:@selector(__orEq) withMemo:_orEq_memo];
}

- (void)__assignmentOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"assignmentOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQUALS, 0]) {
        [self equals]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSEQ, 0]) {
        [self plusEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSEQ, 0]) {
        [self minusEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMESEQ, 0]) {
        [self timesEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIVEQ, 0]) {
        [self divEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MODEQ, 0]) {
        [self modEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFTEQ, 0]) {
        [self shiftLeftEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEQ, 0]) {
        [self shiftRightEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXTEQ, 0]) {
        [self shiftRightExtEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ANDEQ, 0]) {
        [self andEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_XOREQ, 0]) {
        [self xorEq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OREQ, 0]) {
        [self orEq]; 
    } else {
        [self raise:@"No viable alternative found in rule 'assignmentOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"assignmentOperator"];
}

- (void)assignmentOperator {
    [self parseRule:@selector(__assignmentOperator) withMemo:_assignmentOperator_memo];
}

- (void)__relationalOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"relationalOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LT, 0]) {
        [self lt]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GT, 0]) {
        [self gt]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GE, 0]) {
        [self ge]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LE, 0]) {
        [self le]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSTANCEOF, 0]) {
        [self instanceof]; 
    } else {
        [self raise:@"No viable alternative found in rule 'relationalOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"relationalOperator"];
}

- (void)relationalOperator {
    [self parseRule:@selector(__relationalOperator) withMemo:_relationalOperator_memo];
}

- (void)__equalityOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"equalityOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_EQ, 0]) {
        [self eq]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NE, 0]) {
        [self ne]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IS, 0]) {
        [self is]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_ISNOT, 0]) {
        [self isnot]; 
    } else {
        [self raise:@"No viable alternative found in rule 'equalityOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"equalityOperator"];
}

- (void)equalityOperator {
    [self parseRule:@selector(__equalityOperator) withMemo:_equalityOperator_memo];
}

- (void)__shiftOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTLEFT, 0]) {
        [self shiftLeft]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHT, 0]) {
        [self shiftRight]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SHIFTRIGHTEXT, 0]) {
        [self shiftRightExt]; 
    } else {
        [self raise:@"No viable alternative found in rule 'shiftOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftOperator"];
}

- (void)shiftOperator {
    [self parseRule:@selector(__shiftOperator) withMemo:_shiftOperator_memo];
}

- (void)__incrementOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"incrementOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS, 0]) {
        [self plusPlus]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS, 0]) {
        [self minusMinus]; 
    } else {
        [self raise:@"No viable alternative found in rule 'incrementOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"incrementOperator"];
}

- (void)incrementOperator {
    [self parseRule:@selector(__incrementOperator) withMemo:_incrementOperator_memo];
}

- (void)__unaryOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE, 0]) {
        [self tilde]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE, 0]) {
        [self delete]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF, 0]) {
        [self typeof]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID, 0]) {
        [self void]; 
    } else {
        [self raise:@"No viable alternative found in rule 'unaryOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryOperator"];
}

- (void)unaryOperator {
    [self parseRule:@selector(__unaryOperator) withMemo:_unaryOperator_memo];
}

- (void)__multiplicativeOperator {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"multiplicativeOperator"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TIMES, 0]) {
        [self times]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DIV, 0]) {
        [self div]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MOD, 0]) {
        [self mod]; 
    } else {
        [self raise:@"No viable alternative found in rule 'multiplicativeOperator'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"multiplicativeOperator"];
}

- (void)multiplicativeOperator {
    [self parseRule:@selector(__multiplicativeOperator) withMemo:_multiplicativeOperator_memo];
}

- (void)__program {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"program"];

    do {
        [self element]; 
    } while ([self speculate:^{ [self element]; }]);

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"program"];
}

- (void)program {
    [self parseRule:@selector(__program) withMemo:_program_memo];
}

- (void)__element {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"element"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FUNCTION, 0]) {
        [self func]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_BREAKSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CONTINUESYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FORSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IFSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENCURLY, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_RETURNSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SEMI, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VAR, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WHILESYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WITH, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self stmt]; 
    } else {
        [self raise:@"No viable alternative found in rule 'element'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"element"];
}

- (void)element {
    [self parseRule:@selector(__element) withMemo:_element_memo];
}

- (void)__func {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"func"];

    [self function]; 
    [self identifier]; 
    [self openParen]; 
    [self paramListOpt]; 
    [self closeParen]; 
    [self compoundStmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"func"];
}

- (void)func {
    [self parseRule:@selector(__func) withMemo:_func_memo];
}

- (void)__paramListOpt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"paramListOpt"];

    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self paramList]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"paramListOpt"];
}

- (void)paramListOpt {
    [self parseRule:@selector(__paramListOpt) withMemo:_paramListOpt_memo];
}

- (void)__paramList {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"paramList"];

    [self identifier]; 
    while ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaIdentifier]; }]) {
            [self commaIdentifier]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"paramList"];
}

- (void)paramList {
    [self parseRule:@selector(__paramList) withMemo:_paramList_memo];
}

- (void)__commaIdentifier {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"commaIdentifier"];

    [self comma]; 
    [self identifier]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"commaIdentifier"];
}

- (void)commaIdentifier {
    [self parseRule:@selector(__commaIdentifier) withMemo:_commaIdentifier_memo];
}

- (void)__compoundStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"compoundStmt"];

    [self openCurly]; 
    [self stmts]; 
    [self closeCurly]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"compoundStmt"];
}

- (void)compoundStmt {
    [self parseRule:@selector(__compoundStmt) withMemo:_compoundStmt_memo];
}

- (void)__stmts {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"stmts"];

    while ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_BREAKSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_CONTINUESYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FORSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_IFSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENCURLY, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_RETURNSYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_SEMI, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VAR, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WHILESYM, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_WITH, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self stmt]; }]) {
            [self stmt]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"stmts"];
}

- (void)stmts {
    [self parseRule:@selector(__stmts) withMemo:_stmts_memo];
}

- (void)__stmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"stmt"];

    if ([self speculate:^{ [self semi]; }]) {
        [self semi]; 
    } else if ([self speculate:^{ [self ifStmt]; }]) {
        [self ifStmt]; 
    } else if ([self speculate:^{ [self ifElseStmt]; }]) {
        [self ifElseStmt]; 
    } else if ([self speculate:^{ [self whileStmt]; }]) {
        [self whileStmt]; 
    } else if ([self speculate:^{ [self forParenStmt]; }]) {
        [self forParenStmt]; 
    } else if ([self speculate:^{ [self forBeginStmt]; }]) {
        [self forBeginStmt]; 
    } else if ([self speculate:^{ [self forInStmt]; }]) {
        [self forInStmt]; 
    } else if ([self speculate:^{ [self breakStmt]; }]) {
        [self breakStmt]; 
    } else if ([self speculate:^{ [self continueStmt]; }]) {
        [self continueStmt]; 
    } else if ([self speculate:^{ [self withStmt]; }]) {
        [self withStmt]; 
    } else if ([self speculate:^{ [self returnStmt]; }]) {
        [self returnStmt]; 
    } else if ([self speculate:^{ [self compoundStmt]; }]) {
        [self compoundStmt]; 
    } else if ([self speculate:^{ [self variablesOrExprStmt]; }]) {
        [self variablesOrExprStmt]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stmt'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"stmt"];
}

- (void)stmt {
    [self parseRule:@selector(__stmt) withMemo:_stmt_memo];
}

- (void)__ifStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ifStmt"];

    [self if]; 
    [self condition]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ifStmt"];
}

- (void)ifStmt {
    [self parseRule:@selector(__ifStmt) withMemo:_ifStmt_memo];
}

- (void)__ifElseStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ifElseStmt"];

    [self if]; 
    [self condition]; 
    [self stmt]; 
    [self else]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ifElseStmt"];
}

- (void)ifElseStmt {
    [self parseRule:@selector(__ifElseStmt) withMemo:_ifElseStmt_memo];
}

- (void)__whileStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"whileStmt"];

    [self while]; 
    [self condition]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"whileStmt"];
}

- (void)whileStmt {
    [self parseRule:@selector(__whileStmt) withMemo:_whileStmt_memo];
}

- (void)__forParenStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"forParenStmt"];

    [self forParen]; 
    [self semi]; 
    [self exprOpt]; 
    [self semi]; 
    [self exprOpt]; 
    [self closeParen]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"forParenStmt"];
}

- (void)forParenStmt {
    [self parseRule:@selector(__forParenStmt) withMemo:_forParenStmt_memo];
}

- (void)__forBeginStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"forBeginStmt"];

    [self forBegin]; 
    [self semi]; 
    [self exprOpt]; 
    [self semi]; 
    [self exprOpt]; 
    [self closeParen]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"forBeginStmt"];
}

- (void)forBeginStmt {
    [self parseRule:@selector(__forBeginStmt) withMemo:_forBeginStmt_memo];
}

- (void)__forInStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"forInStmt"];

    [self forBegin]; 
    [self in]; 
    [self expr]; 
    [self closeParen]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"forInStmt"];
}

- (void)forInStmt {
    [self parseRule:@selector(__forInStmt) withMemo:_forInStmt_memo];
}

- (void)__breakStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"breakStmt"];

    [self break]; 
    [self semi]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"breakStmt"];
}

- (void)breakStmt {
    [self parseRule:@selector(__breakStmt) withMemo:_breakStmt_memo];
}

- (void)__continueStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"continueStmt"];

    [self continue]; 
    [self semi]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"continueStmt"];
}

- (void)continueStmt {
    [self parseRule:@selector(__continueStmt) withMemo:_continueStmt_memo];
}

- (void)__withStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"withStmt"];

    [self with]; 
    [self openParen]; 
    [self expr]; 
    [self closeParen]; 
    [self stmt]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"withStmt"];
}

- (void)withStmt {
    [self parseRule:@selector(__withStmt) withMemo:_withStmt_memo];
}

- (void)__returnStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"returnStmt"];

    [self return]; 
    [self exprOpt]; 
    [self semi]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"returnStmt"];
}

- (void)returnStmt {
    [self parseRule:@selector(__returnStmt) withMemo:_returnStmt_memo];
}

- (void)__variablesOrExprStmt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"variablesOrExprStmt"];

    [self variablesOrExpr]; 
    [self semi]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"variablesOrExprStmt"];
}

- (void)variablesOrExprStmt {
    [self parseRule:@selector(__variablesOrExprStmt) withMemo:_variablesOrExprStmt_memo];
}

- (void)__condition {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"condition"];

    [self openParen]; 
    [self expr]; 
    [self closeParen]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"condition"];
}

- (void)condition {
    [self parseRule:@selector(__condition) withMemo:_condition_memo];
}

- (void)__forParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"forParen"];

    [self for]; 
    [self openParen]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"forParen"];
}

- (void)forParen {
    [self parseRule:@selector(__forParen) withMemo:_forParen_memo];
}

- (void)__forBegin {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"forBegin"];

    [self forParen]; 
    [self variablesOrExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"forBegin"];
}

- (void)forBegin {
    [self parseRule:@selector(__forBegin) withMemo:_forBegin_memo];
}

- (void)__variablesOrExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"variablesOrExpr"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VAR, 0]) {
        [self varVariables]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self expr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'variablesOrExpr'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"variablesOrExpr"];
}

- (void)variablesOrExpr {
    [self parseRule:@selector(__variablesOrExpr) withMemo:_variablesOrExpr_memo];
}

- (void)__varVariables {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"varVariables"];

    [self var]; 
    [self variables]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"varVariables"];
}

- (void)varVariables {
    [self parseRule:@selector(__varVariables) withMemo:_varVariables_memo];
}

- (void)__variables {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"variables"];

    [self variable]; 
    while ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaVariable]; }]) {
            [self commaVariable]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"variables"];
}

- (void)variables {
    [self parseRule:@selector(__variables) withMemo:_variables_memo];
}

- (void)__commaVariable {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"commaVariable"];

    [self comma]; 
    [self variable]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"commaVariable"];
}

- (void)commaVariable {
    [self parseRule:@selector(__commaVariable) withMemo:_commaVariable_memo];
}

- (void)__variable {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"variable"];

    [self identifier]; 
    if ([self speculate:^{ [self assignment]; }]) {
        [self assignment]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"variable"];
}

- (void)variable {
    [self parseRule:@selector(__variable) withMemo:_variable_memo];
}

- (void)__assignment {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"assignment"];

    [self equals]; 
    [self assignmentExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"assignment"];
}

- (void)assignment {
    [self parseRule:@selector(__assignment) withMemo:_assignment_memo];
}

- (void)__exprOpt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"exprOpt"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DELETE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUSMINUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUSPLUS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TILDE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TYPEOF, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_VOID, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self expr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"exprOpt"];
}

- (void)exprOpt {
    [self parseRule:@selector(__exprOpt) withMemo:_exprOpt_memo];
}

- (void)__expr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"expr"];

    [self assignmentExpr]; 
    if ([self speculate:^{ [self commaExpr]; }]) {
        [self commaExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"expr"];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__commaExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"commaExpr"];

    [self comma]; 
    [self expr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"commaExpr"];
}

- (void)commaExpr {
    [self parseRule:@selector(__commaExpr) withMemo:_commaExpr_memo];
}

- (void)__assignmentExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"assignmentExpr"];

    [self conditionalExpr]; 
    if ([self speculate:^{ [self extraAssignment]; }]) {
        [self extraAssignment]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"assignmentExpr"];
}

- (void)assignmentExpr {
    [self parseRule:@selector(__assignmentExpr) withMemo:_assignmentExpr_memo];
}

- (void)__extraAssignment {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"extraAssignment"];

    [self assignmentOperator]; 
    [self assignmentExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"extraAssignment"];
}

- (void)extraAssignment {
    [self parseRule:@selector(__extraAssignment) withMemo:_extraAssignment_memo];
}

- (void)__conditionalExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"conditionalExpr"];

    [self orExpr]; 
    if ([self speculate:^{ [self ternaryExpr]; }]) {
        [self ternaryExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"conditionalExpr"];
}

- (void)conditionalExpr {
    [self parseRule:@selector(__conditionalExpr) withMemo:_conditionalExpr_memo];
}

- (void)__ternaryExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ternaryExpr"];

    [self question]; 
    [self assignmentExpr]; 
    [self colon]; 
    [self assignmentExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ternaryExpr"];
}

- (void)ternaryExpr {
    [self parseRule:@selector(__ternaryExpr) withMemo:_ternaryExpr_memo];
}

- (void)__orExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"orExpr"];

    [self andExpr]; 
    while ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OR, 0]) {
        if ([self speculate:^{ [self orAndExpr]; }]) {
            [self orAndExpr]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"orExpr"];
}

- (void)orExpr {
    [self parseRule:@selector(__orExpr) withMemo:_orExpr_memo];
}

- (void)__orAndExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"orAndExpr"];

    [self or]; 
    [self andExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"orAndExpr"];
}

- (void)orAndExpr {
    [self parseRule:@selector(__orAndExpr) withMemo:_orAndExpr_memo];
}

- (void)__andExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"andExpr"];

    [self bitwiseOrExpr]; 
    if ([self speculate:^{ [self andAndExpr]; }]) {
        [self andAndExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"andExpr"];
}

- (void)andExpr {
    [self parseRule:@selector(__andExpr) withMemo:_andExpr_memo];
}

- (void)__andAndExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"andAndExpr"];

    [self and]; 
    [self andExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"andAndExpr"];
}

- (void)andAndExpr {
    [self parseRule:@selector(__andAndExpr) withMemo:_andAndExpr_memo];
}

- (void)__bitwiseOrExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"bitwiseOrExpr"];

    [self bitwiseXorExpr]; 
    if ([self speculate:^{ [self pipeBitwiseOrExpr]; }]) {
        [self pipeBitwiseOrExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"bitwiseOrExpr"];
}

- (void)bitwiseOrExpr {
    [self parseRule:@selector(__bitwiseOrExpr) withMemo:_bitwiseOrExpr_memo];
}

- (void)__pipeBitwiseOrExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"pipeBitwiseOrExpr"];

    [self pipe]; 
    [self bitwiseOrExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"pipeBitwiseOrExpr"];
}

- (void)pipeBitwiseOrExpr {
    [self parseRule:@selector(__pipeBitwiseOrExpr) withMemo:_pipeBitwiseOrExpr_memo];
}

- (void)__bitwiseXorExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"bitwiseXorExpr"];

    [self bitwiseAndExpr]; 
    if ([self speculate:^{ [self caretBitwiseXorExpr]; }]) {
        [self caretBitwiseXorExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"bitwiseXorExpr"];
}

- (void)bitwiseXorExpr {
    [self parseRule:@selector(__bitwiseXorExpr) withMemo:_bitwiseXorExpr_memo];
}

- (void)__caretBitwiseXorExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"caretBitwiseXorExpr"];

    [self caret]; 
    [self bitwiseXorExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"caretBitwiseXorExpr"];
}

- (void)caretBitwiseXorExpr {
    [self parseRule:@selector(__caretBitwiseXorExpr) withMemo:_caretBitwiseXorExpr_memo];
}

- (void)__bitwiseAndExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"bitwiseAndExpr"];

    [self equalityExpr]; 
    if ([self speculate:^{ [self ampBitwiseAndExpression]; }]) {
        [self ampBitwiseAndExpression]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"bitwiseAndExpr"];
}

- (void)bitwiseAndExpr {
    [self parseRule:@selector(__bitwiseAndExpr) withMemo:_bitwiseAndExpr_memo];
}

- (void)__ampBitwiseAndExpression {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"ampBitwiseAndExpression"];

    [self amp]; 
    [self bitwiseAndExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"ampBitwiseAndExpression"];
}

- (void)ampBitwiseAndExpression {
    [self parseRule:@selector(__ampBitwiseAndExpression) withMemo:_ampBitwiseAndExpression_memo];
}

- (void)__equalityExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"equalityExpr"];

    [self relationalExpr]; 
    if ([self speculate:^{ [self equalityOpEqualityExpr]; }]) {
        [self equalityOpEqualityExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"equalityExpr"];
}

- (void)equalityExpr {
    [self parseRule:@selector(__equalityExpr) withMemo:_equalityExpr_memo];
}

- (void)__equalityOpEqualityExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"equalityOpEqualityExpr"];

    [self equalityOperator]; 
    [self equalityExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"equalityOpEqualityExpr"];
}

- (void)equalityOpEqualityExpr {
    [self parseRule:@selector(__equalityOpEqualityExpr) withMemo:_equalityOpEqualityExpr_memo];
}

- (void)__relationalExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"relationalExpr"];

    [self shiftExpr]; 
    while ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_GT, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_INSTANCEOF, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LE, JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_LT, 0]) {
        if ([self speculate:^{ [self relationalOperator]; [self shiftExpr]; }]) {
            [self relationalOperator]; 
            [self shiftExpr]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"relationalExpr"];
}

- (void)relationalExpr {
    [self parseRule:@selector(__relationalExpr) withMemo:_relationalExpr_memo];
}

- (void)__shiftExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftExpr"];

    [self additiveExpr]; 
    if ([self speculate:^{ [self shiftOpShiftExpr]; }]) {
        [self shiftOpShiftExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftExpr"];
}

- (void)shiftExpr {
    [self parseRule:@selector(__shiftExpr) withMemo:_shiftExpr_memo];
}

- (void)__shiftOpShiftExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"shiftOpShiftExpr"];

    [self shiftOperator]; 
    [self shiftExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"shiftOpShiftExpr"];
}

- (void)shiftOpShiftExpr {
    [self parseRule:@selector(__shiftOpShiftExpr) withMemo:_shiftOpShiftExpr_memo];
}

- (void)__additiveExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"additiveExpr"];

    [self multiplicativeExpr]; 
    if ([self speculate:^{ [self plusOrMinusExpr]; }]) {
        [self plusOrMinusExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"additiveExpr"];
}

- (void)additiveExpr {
    [self parseRule:@selector(__additiveExpr) withMemo:_additiveExpr_memo];
}

- (void)__plusOrMinusExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"plusOrMinusExpr"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_PLUS, 0]) {
        [self plusExpr]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_MINUS, 0]) {
        [self minusExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'plusOrMinusExpr'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"plusOrMinusExpr"];
}

- (void)plusOrMinusExpr {
    [self parseRule:@selector(__plusOrMinusExpr) withMemo:_plusOrMinusExpr_memo];
}

- (void)__plusExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"plusExpr"];

    [self plus]; 
    [self additiveExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"plusExpr"];
}

- (void)plusExpr {
    [self parseRule:@selector(__plusExpr) withMemo:_plusExpr_memo];
}

- (void)__minusExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"minusExpr"];

    [self minus]; 
    [self additiveExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"minusExpr"];
}

- (void)minusExpr {
    [self parseRule:@selector(__minusExpr) withMemo:_minusExpr_memo];
}

- (void)__multiplicativeExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"multiplicativeExpr"];

    [self unaryExpr]; 
    if ([self speculate:^{ [self multiplicativeOperator]; [self multiplicativeExpr]; }]) {
        [self multiplicativeOperator]; 
        [self multiplicativeExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"multiplicativeExpr"];
}

- (void)multiplicativeExpr {
    [self parseRule:@selector(__multiplicativeExpr) withMemo:_multiplicativeExpr_memo];
}

- (void)__unaryExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryExpr"];

    if ([self speculate:^{ [self memberExpr]; }]) {
        [self memberExpr]; 
    } else if ([self speculate:^{ [self unaryExpr1]; }]) {
        [self unaryExpr1]; 
    } else if ([self speculate:^{ [self unaryExpr2]; }]) {
        [self unaryExpr2]; 
    } else if ([self speculate:^{ [self unaryExpr3]; }]) {
        [self unaryExpr3]; 
    } else if ([self speculate:^{ [self unaryExpr4]; }]) {
        [self unaryExpr4]; 
    } else if ([self speculate:^{ [self unaryExpr6]; }]) {
        [self unaryExpr6]; 
    } else {
        [self raise:@"No viable alternative found in rule 'unaryExpr'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryExpr"];
}

- (void)unaryExpr {
    [self parseRule:@selector(__unaryExpr) withMemo:_unaryExpr_memo];
}

- (void)__unaryExpr1 {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryExpr1"];

    [self unaryOperator]; 
    [self unaryExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryExpr1"];
}

- (void)unaryExpr1 {
    [self parseRule:@selector(__unaryExpr1) withMemo:_unaryExpr1_memo];
}

- (void)__unaryExpr2 {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryExpr2"];

    [self minus]; 
    [self unaryExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryExpr2"];
}

- (void)unaryExpr2 {
    [self parseRule:@selector(__unaryExpr2) withMemo:_unaryExpr2_memo];
}

- (void)__unaryExpr3 {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryExpr3"];

    [self incrementOperator]; 
    [self memberExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryExpr3"];
}

- (void)unaryExpr3 {
    [self parseRule:@selector(__unaryExpr3) withMemo:_unaryExpr3_memo];
}

- (void)__unaryExpr4 {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryExpr4"];

    [self memberExpr]; 
    [self incrementOperator]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryExpr4"];
}

- (void)unaryExpr4 {
    [self parseRule:@selector(__unaryExpr4) withMemo:_unaryExpr4_memo];
}

- (void)__callNewExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"callNewExpr"];

    [self keywordNew]; 
    [self constructor]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"callNewExpr"];
}

- (void)callNewExpr {
    [self parseRule:@selector(__callNewExpr) withMemo:_callNewExpr_memo];
}

- (void)__unaryExpr6 {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"unaryExpr6"];

    [self delete]; 
    [self memberExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"unaryExpr6"];
}

- (void)unaryExpr6 {
    [self parseRule:@selector(__unaryExpr6) withMemo:_unaryExpr6_memo];
}

- (void)__constructor {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"constructor"];

    if ([self speculate:^{ [self this]; [self dot]; }]) {
        [self this]; 
        [self dot]; 
    }
    [self constructorCall]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"constructor"];
}

- (void)constructor {
    [self parseRule:@selector(__constructor) withMemo:_constructor_memo];
}

- (void)__constructorCall {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"constructorCall"];

    [self identifier]; 
    if ([self speculate:^{ if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, 0]) {[self parenArgListParen]; } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DOT, 0]) {[self dot]; [self constructorCall]; } else {[self raise:@"No viable alternative found in rule 'constructorCall'."];}}]) {
        if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, 0]) {
            [self parenArgListParen]; 
        } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DOT, 0]) {
            [self dot]; 
            [self constructorCall]; 
        } else {
            [self raise:@"No viable alternative found in rule 'constructorCall'."];
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"constructorCall"];
}

- (void)constructorCall {
    [self parseRule:@selector(__constructorCall) withMemo:_constructorCall_memo];
}

- (void)__parenArgListParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"parenArgListParen"];

    [self openParen]; 
    [self argListOpt]; 
    [self closeParen]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"parenArgListParen"];
}

- (void)parenArgListParen {
    [self parseRule:@selector(__parenArgListParen) withMemo:_parenArgListParen_memo];
}

- (void)__memberExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"memberExpr"];

    [self primaryExpr]; 
    if ([self speculate:^{ [self dotBracketOrParenExpr]; }]) {
        [self dotBracketOrParenExpr]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"memberExpr"];
}

- (void)memberExpr {
    [self parseRule:@selector(__memberExpr) withMemo:_memberExpr_memo];
}

- (void)__dotBracketOrParenExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"dotBracketOrParenExpr"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_DOT, 0]) {
        [self dotMemberExpr]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENBRACKET, 0]) {
        [self bracketMemberExpr]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, 0]) {
        [self parenMemberExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'dotBracketOrParenExpr'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"dotBracketOrParenExpr"];
}

- (void)dotBracketOrParenExpr {
    [self parseRule:@selector(__dotBracketOrParenExpr) withMemo:_dotBracketOrParenExpr_memo];
}

- (void)__dotMemberExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"dotMemberExpr"];

    [self dot]; 
    [self memberExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"dotMemberExpr"];
}

- (void)dotMemberExpr {
    [self parseRule:@selector(__dotMemberExpr) withMemo:_dotMemberExpr_memo];
}

- (void)__bracketMemberExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"bracketMemberExpr"];

    [self openBracket]; 
    [self expr]; 
    [self closeBracket]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"bracketMemberExpr"];
}

- (void)bracketMemberExpr {
    [self parseRule:@selector(__bracketMemberExpr) withMemo:_bracketMemberExpr_memo];
}

- (void)__parenMemberExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"parenMemberExpr"];

    [self openParen]; 
    [self argListOpt]; 
    [self closeParen]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"parenMemberExpr"];
}

- (void)parenMemberExpr {
    [self parseRule:@selector(__parenMemberExpr) withMemo:_parenMemberExpr_memo];
}

- (void)__argListOpt {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"argListOpt"];

    if ([self speculate:^{ [self argList]; }]) {
        [self argList]; 
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"argListOpt"];
}

- (void)argListOpt {
    [self parseRule:@selector(__argListOpt) withMemo:_argListOpt_memo];
}

- (void)__argList {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"argList"];

    [self assignmentExpr]; 
    while ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaAssignmentExpr]; }]) {
            [self commaAssignmentExpr]; 
        } else {
            break;
        }
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"argList"];
}

- (void)argList {
    [self parseRule:@selector(__argList) withMemo:_argList_memo];
}

- (void)__commaAssignmentExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"commaAssignmentExpr"];

    [self comma]; 
    [self assignmentExpr]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"commaAssignmentExpr"];
}

- (void)commaAssignmentExpr {
    [self parseRule:@selector(__commaAssignmentExpr) withMemo:_commaAssignmentExpr_memo];
}

- (void)__primaryExpr {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"primaryExpr"];

    if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_KEYWORDNEW, 0]) {
        [self callNewExpr]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_OPENPAREN, 0]) {
        [self parenExprParen]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self identifier]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self numLiteral]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self stringLiteral]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_FALSE, 0]) {
        [self false]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_TRUE, 0]) {
        [self true]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_NULL, 0]) {
        [self null]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_UNDEFINED, 0]) {
        [self undefined]; 
    } else if ([self predicts:JAVASCRIPTSYNTAXPARSER_TOKEN_KIND_THIS, 0]) {
        [self this]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"primaryExpr"];
}

- (void)primaryExpr {
    [self parseRule:@selector(__primaryExpr) withMemo:_primaryExpr_memo];
}

- (void)__parenExprParen {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"parenExprParen"];

    [self openParen]; 
    [self expr]; 
    [self closeParen]; 

    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"parenExprParen"];
}

- (void)parenExprParen {
    [self parseRule:@selector(__parenExprParen) withMemo:_parenExprParen_memo];
}

- (void)__identifier {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"identifier"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"identifier"];

    [self matchWord:NO];

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"identifier"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"identifier"];
}

- (void)identifier {
    [self parseRule:@selector(__identifier) withMemo:_identifier_memo];
}

- (void)__numLiteral {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"numLiteral"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"numLiteral"];

    [self matchNumber:NO];

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"numLiteral"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"numLiteral"];
}

- (void)numLiteral {
    [self parseRule:@selector(__numLiteral) withMemo:_numLiteral_memo];
}

- (void)__stringLiteral {
    
    [self fireSyntaxSelector:@selector(parser:willMatchInterior:) withRuleName:@"stringLiteral"];
    [self fireSyntaxSelector:@selector(parser:willMatchLeaf:) withRuleName:@"stringLiteral"];

    [self matchQuotedString:NO];

    [self fireSyntaxSelector:@selector(parser:didMatchLeaf:) withRuleName:@"stringLiteral"];
    [self fireSyntaxSelector:@selector(parser:didMatchInterior:) withRuleName:@"stringLiteral"];
}

- (void)stringLiteral {
    [self parseRule:@selector(__stringLiteral) withMemo:_stringLiteral_memo];
}

@end