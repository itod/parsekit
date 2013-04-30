#import "JavaScriptParser.h"
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

@interface JavaScriptParser ()
@end

@implementation JavaScriptParser

- (id)init {
    self = [super init];
    if (self) {
        self.enableAutomaticErrorRecovery = YES;

        self._tokenKindTab[@"|"] = @(JAVASCRIPT_TOKEN_KIND_PIPE);
        self._tokenKindTab[@"!="] = @(JAVASCRIPT_TOKEN_KIND_NE);
        self._tokenKindTab[@"("] = @(JAVASCRIPT_TOKEN_KIND_OPENPAREN);
        self._tokenKindTab[@"}"] = @(JAVASCRIPT_TOKEN_KIND_CLOSECURLY);
        self._tokenKindTab[@"return"] = @(JAVASCRIPT_TOKEN_KIND_RETURNSYM);
        self._tokenKindTab[@"~"] = @(JAVASCRIPT_TOKEN_KIND_TILDE);
        self._tokenKindTab[@")"] = @(JAVASCRIPT_TOKEN_KIND_CLOSEPAREN);
        self._tokenKindTab[@"*"] = @(JAVASCRIPT_TOKEN_KIND_TIMES);
        self._tokenKindTab[@"delete"] = @(JAVASCRIPT_TOKEN_KIND_DELETE);
        self._tokenKindTab[@"!=="] = @(JAVASCRIPT_TOKEN_KIND_ISNOT);
        self._tokenKindTab[@"+"] = @(JAVASCRIPT_TOKEN_KIND_PLUS);
        self._tokenKindTab[@"*="] = @(JAVASCRIPT_TOKEN_KIND_TIMESEQ);
        self._tokenKindTab[@"instanceof"] = @(JAVASCRIPT_TOKEN_KIND_INSTANCEOF);
        self._tokenKindTab[@","] = @(JAVASCRIPT_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"<<="] = @(JAVASCRIPT_TOKEN_KIND_SHIFTLEFTEQ);
        self._tokenKindTab[@"if"] = @(JAVASCRIPT_TOKEN_KIND_IFSYM);
        self._tokenKindTab[@"-"] = @(JAVASCRIPT_TOKEN_KIND_MINUS);
        self._tokenKindTab[@"null"] = @(JAVASCRIPT_TOKEN_KIND_NULL);
        self._tokenKindTab[@"false"] = @(JAVASCRIPT_TOKEN_KIND_FALSELITERAL);
        self._tokenKindTab[@"."] = @(JAVASCRIPT_TOKEN_KIND_DOT);
        self._tokenKindTab[@"<<"] = @(JAVASCRIPT_TOKEN_KIND_SHIFTLEFT);
        self._tokenKindTab[@"/"] = @(JAVASCRIPT_TOKEN_KIND_DIV);
        self._tokenKindTab[@"+="] = @(JAVASCRIPT_TOKEN_KIND_PLUSEQ);
        self._tokenKindTab[@"<="] = @(JAVASCRIPT_TOKEN_KIND_LE);
        self._tokenKindTab[@"^="] = @(JAVASCRIPT_TOKEN_KIND_XOREQ);
        self._tokenKindTab[@"["] = @(JAVASCRIPT_TOKEN_KIND_OPENBRACKET);
        self._tokenKindTab[@"undefined"] = @(JAVASCRIPT_TOKEN_KIND_UNDEFINED);
        self._tokenKindTab[@"typeof"] = @(JAVASCRIPT_TOKEN_KIND_TYPEOF);
        self._tokenKindTab[@"||"] = @(JAVASCRIPT_TOKEN_KIND_OR);
        self._tokenKindTab[@"function"] = @(JAVASCRIPT_TOKEN_KIND_FUNCTION);
        self._tokenKindTab[@"]"] = @(JAVASCRIPT_TOKEN_KIND_CLOSEBRACKET);
        self._tokenKindTab[@"^"] = @(JAVASCRIPT_TOKEN_KIND_CARET);
        self._tokenKindTab[@"=="] = @(JAVASCRIPT_TOKEN_KIND_EQ);
        self._tokenKindTab[@"continue"] = @(JAVASCRIPT_TOKEN_KIND_CONTINUESYM);
        self._tokenKindTab[@"break"] = @(JAVASCRIPT_TOKEN_KIND_BREAKSYM);
        self._tokenKindTab[@"-="] = @(JAVASCRIPT_TOKEN_KIND_MINUSEQ);
        self._tokenKindTab[@">="] = @(JAVASCRIPT_TOKEN_KIND_GE);
        self._tokenKindTab[@":"] = @(JAVASCRIPT_TOKEN_KIND_COLON);
        self._tokenKindTab[@"in"] = @(JAVASCRIPT_TOKEN_KIND_INSYM);
        self._tokenKindTab[@";"] = @(JAVASCRIPT_TOKEN_KIND_SEMI);
        self._tokenKindTab[@"for"] = @(JAVASCRIPT_TOKEN_KIND_FORSYM);
        self._tokenKindTab[@"++"] = @(JAVASCRIPT_TOKEN_KIND_PLUSPLUS);
        self._tokenKindTab[@"<"] = @(JAVASCRIPT_TOKEN_KIND_LT);
        self._tokenKindTab[@"%="] = @(JAVASCRIPT_TOKEN_KIND_MODEQ);
        self._tokenKindTab[@">>"] = @(JAVASCRIPT_TOKEN_KIND_SHIFTRIGHT);
        self._tokenKindTab[@"="] = @(JAVASCRIPT_TOKEN_KIND_EQUALS);
        self._tokenKindTab[@">"] = @(JAVASCRIPT_TOKEN_KIND_GT);
        self._tokenKindTab[@"void"] = @(JAVASCRIPT_TOKEN_KIND_VOID);
        self._tokenKindTab[@"?"] = @(JAVASCRIPT_TOKEN_KIND_QUESTION);
        self._tokenKindTab[@"while"] = @(JAVASCRIPT_TOKEN_KIND_WHILESYM);
        self._tokenKindTab[@"&="] = @(JAVASCRIPT_TOKEN_KIND_ANDEQ);
        self._tokenKindTab[@">>>="] = @(JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEXTEQ);
        self._tokenKindTab[@"else"] = @(JAVASCRIPT_TOKEN_KIND_ELSESYM);
        self._tokenKindTab[@"/="] = @(JAVASCRIPT_TOKEN_KIND_DIVEQ);
        self._tokenKindTab[@"&&"] = @(JAVASCRIPT_TOKEN_KIND_AND);
        self._tokenKindTab[@"var"] = @(JAVASCRIPT_TOKEN_KIND_VAR);
        self._tokenKindTab[@"|="] = @(JAVASCRIPT_TOKEN_KIND_OREQ);
        self._tokenKindTab[@">>="] = @(JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEQ);
        self._tokenKindTab[@"--"] = @(JAVASCRIPT_TOKEN_KIND_MINUSMINUS);
        self._tokenKindTab[@"new"] = @(JAVASCRIPT_TOKEN_KIND_KEYWORDNEW);
        self._tokenKindTab[@"!"] = @(JAVASCRIPT_TOKEN_KIND_NOT);
        self._tokenKindTab[@">>>"] = @(JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEXT);
        self._tokenKindTab[@"true"] = @(JAVASCRIPT_TOKEN_KIND_TRUELITERAL);
        self._tokenKindTab[@"this"] = @(JAVASCRIPT_TOKEN_KIND_THIS);
        self._tokenKindTab[@"with"] = @(JAVASCRIPT_TOKEN_KIND_WITH);
        self._tokenKindTab[@"==="] = @(JAVASCRIPT_TOKEN_KIND_IS);
        self._tokenKindTab[@"%"] = @(JAVASCRIPT_TOKEN_KIND_MOD);
        self._tokenKindTab[@"&"] = @(JAVASCRIPT_TOKEN_KIND_AMP);
        self._tokenKindTab[@"{"] = @(JAVASCRIPT_TOKEN_KIND_OPENCURLY);

    }
    return self;
}


- (void)_start {
    
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
    [self tryAndRecover:TOKEN_KIND_BUILTIN_EOF block:^{
        [self program]; 
        [self matchEOF:YES]; 
    } completion:^{
        [self matchEOF:YES];
    }];

}

- (void)ifSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_IFSYM expecting:@"'if'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIfSym:)];
}

- (void)elseSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_ELSESYM expecting:@"'else'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchElseSym:)];
}

- (void)whileSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_WHILESYM expecting:@"'while'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWhileSym:)];
}

- (void)forSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_FORSYM expecting:@"'for'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForSym:)];
}

- (void)inSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_INSYM expecting:@"'in'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchInSym:)];
}

- (void)breakSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_BREAKSYM expecting:@"'break'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBreakSym:)];
}

- (void)continueSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_CONTINUESYM expecting:@"'continue'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchContinueSym:)];
}

- (void)with {
    
    [self match:JAVASCRIPT_TOKEN_KIND_WITH expecting:@"'with'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWith:)];
}

- (void)returnSym {
    
    [self match:JAVASCRIPT_TOKEN_KIND_RETURNSYM expecting:@"'return'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchReturnSym:)];
}

- (void)var {
    
    [self match:JAVASCRIPT_TOKEN_KIND_VAR expecting:@"'var'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVar:)];
}

- (void)delete {
    
    [self match:JAVASCRIPT_TOKEN_KIND_DELETE expecting:@"'delete'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDelete:)];
}

- (void)keywordNew {
    
    [self match:JAVASCRIPT_TOKEN_KIND_KEYWORDNEW expecting:@"'new'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchKeywordNew:)];
}

- (void)this {
    
    [self match:JAVASCRIPT_TOKEN_KIND_THIS expecting:@"'this'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchThis:)];
}

- (void)falseLiteral {
    
    [self match:JAVASCRIPT_TOKEN_KIND_FALSELITERAL expecting:@"'false'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalseLiteral:)];
}

- (void)trueLiteral {
    
    [self match:JAVASCRIPT_TOKEN_KIND_TRUELITERAL expecting:@"'true'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTrueLiteral:)];
}

- (void)null {
    
    [self match:JAVASCRIPT_TOKEN_KIND_NULL expecting:@"'null'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNull:)];
}

- (void)undefined {
    
    [self match:JAVASCRIPT_TOKEN_KIND_UNDEFINED expecting:@"'undefined'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUndefined:)];
}

- (void)void {
    
    [self match:JAVASCRIPT_TOKEN_KIND_VOID expecting:@"'void'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVoid:)];
}

- (void)typeof {
    
    [self match:JAVASCRIPT_TOKEN_KIND_TYPEOF expecting:@"'typeof'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTypeof:)];
}

- (void)instanceof {
    
    [self match:JAVASCRIPT_TOKEN_KIND_INSTANCEOF expecting:@"'instanceof'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchInstanceof:)];
}

- (void)function {
    
    [self match:JAVASCRIPT_TOKEN_KIND_FUNCTION expecting:@"'function'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFunction:)];
}

- (void)openCurly {
    
    [self match:JAVASCRIPT_TOKEN_KIND_OPENCURLY expecting:@"'{'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenCurly:)];
}

- (void)closeCurly {
    
    [self match:JAVASCRIPT_TOKEN_KIND_CLOSECURLY expecting:@"'}'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseCurly:)];
}

- (void)openParen {
    
    [self match:JAVASCRIPT_TOKEN_KIND_OPENPAREN expecting:@"'('" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenParen:)];
}

- (void)closeParen {
    
    [self match:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN expecting:@"')'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseParen:)];
}

- (void)openBracket {
    
    [self match:JAVASCRIPT_TOKEN_KIND_OPENBRACKET expecting:@"'['" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenBracket:)];
}

- (void)closeBracket {
    
    [self match:JAVASCRIPT_TOKEN_KIND_CLOSEBRACKET expecting:@"']'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseBracket:)];
}

- (void)comma {
    
    [self match:JAVASCRIPT_TOKEN_KIND_COMMA expecting:@"','" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)dot {
    
    [self match:JAVASCRIPT_TOKEN_KIND_DOT expecting:@"'.'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDot:)];
}

- (void)semi {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SEMI expecting:@"';'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemi:)];
}

- (void)colon {
    
    [self match:JAVASCRIPT_TOKEN_KIND_COLON expecting:@"':'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchColon:)];
}

- (void)equals {
    
    [self match:JAVASCRIPT_TOKEN_KIND_EQUALS expecting:@"'='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEquals:)];
}

- (void)not {
    
    [self match:JAVASCRIPT_TOKEN_KIND_NOT expecting:@"'!'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNot:)];
}

- (void)lt {
    
    [self match:JAVASCRIPT_TOKEN_KIND_LT expecting:@"'<'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)gt {
    
    [self match:JAVASCRIPT_TOKEN_KIND_GT expecting:@"'>'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)amp {
    
    [self match:JAVASCRIPT_TOKEN_KIND_AMP expecting:@"'&'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAmp:)];
}

- (void)pipe {
    
    [self match:JAVASCRIPT_TOKEN_KIND_PIPE expecting:@"'|'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPipe:)];
}

- (void)caret {
    
    [self match:JAVASCRIPT_TOKEN_KIND_CARET expecting:@"'^'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCaret:)];
}

- (void)tilde {
    
    [self match:JAVASCRIPT_TOKEN_KIND_TILDE expecting:@"'~'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTilde:)];
}

- (void)question {
    
    [self match:JAVASCRIPT_TOKEN_KIND_QUESTION expecting:@"'?'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchQuestion:)];
}

- (void)plus {
    
    [self match:JAVASCRIPT_TOKEN_KIND_PLUS expecting:@"'+'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlus:)];
}

- (void)minus {
    
    [self match:JAVASCRIPT_TOKEN_KIND_MINUS expecting:@"'-'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinus:)];
}

- (void)times {
    
    [self match:JAVASCRIPT_TOKEN_KIND_TIMES expecting:@"'*'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTimes:)];
}

- (void)div {
    
    [self match:JAVASCRIPT_TOKEN_KIND_DIV expecting:@"'/'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDiv:)];
}

- (void)mod {
    
    [self match:JAVASCRIPT_TOKEN_KIND_MOD expecting:@"'%'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMod:)];
}

- (void)or {
    
    [self match:JAVASCRIPT_TOKEN_KIND_OR expecting:@"'||'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOr:)];
}

- (void)and {
    
    [self match:JAVASCRIPT_TOKEN_KIND_AND expecting:@"'&&'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAnd:)];
}

- (void)ne {
    
    [self match:JAVASCRIPT_TOKEN_KIND_NE expecting:@"'!='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNe:)];
}

- (void)isnot {
    
    [self match:JAVASCRIPT_TOKEN_KIND_ISNOT expecting:@"'!=='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIsnot:)];
}

- (void)eq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_EQ expecting:@"'=='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)is {
    
    [self match:JAVASCRIPT_TOKEN_KIND_IS expecting:@"'==='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIs:)];
}

- (void)le {
    
    [self match:JAVASCRIPT_TOKEN_KIND_LE expecting:@"'<='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLe:)];
}

- (void)ge {
    
    [self match:JAVASCRIPT_TOKEN_KIND_GE expecting:@"'>='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGe:)];
}

- (void)plusPlus {
    
    [self match:JAVASCRIPT_TOKEN_KIND_PLUSPLUS expecting:@"'++'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlusPlus:)];
}

- (void)minusMinus {
    
    [self match:JAVASCRIPT_TOKEN_KIND_MINUSMINUS expecting:@"'--'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinusMinus:)];
}

- (void)plusEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_PLUSEQ expecting:@"'+='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlusEq:)];
}

- (void)minusEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_MINUSEQ expecting:@"'-='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinusEq:)];
}

- (void)timesEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_TIMESEQ expecting:@"'*='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTimesEq:)];
}

- (void)divEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_DIVEQ expecting:@"'/='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDivEq:)];
}

- (void)modEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_MODEQ expecting:@"'%='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchModEq:)];
}

- (void)shiftLeft {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SHIFTLEFT expecting:@"'<<'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftLeft:)];
}

- (void)shiftRight {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHT expecting:@"'>>'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRight:)];
}

- (void)shiftRightExt {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEXT expecting:@"'>>>'" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRightExt:)];
}

- (void)shiftLeftEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SHIFTLEFTEQ expecting:@"'<<='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftLeftEq:)];
}

- (void)shiftRightEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEQ expecting:@"'>>='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRightEq:)];
}

- (void)shiftRightExtEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEXTEQ expecting:@"'>>>='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRightExtEq:)];
}

- (void)andEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_ANDEQ expecting:@"'&='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndEq:)];
}

- (void)xorEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_XOREQ expecting:@"'^='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchXorEq:)];
}

- (void)orEq {
    
    [self match:JAVASCRIPT_TOKEN_KIND_OREQ expecting:@"'|='" discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrEq:)];
}

- (void)assignmentOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_EQUALS, 0]) {
        [self equals]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_PLUSEQ, 0]) {
        [self plusEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_MINUSEQ, 0]) {
        [self minusEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_TIMESEQ, 0]) {
        [self timesEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_DIVEQ, 0]) {
        [self divEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_MODEQ, 0]) {
        [self modEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_SHIFTLEFTEQ, 0]) {
        [self shiftLeftEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEQ, 0]) {
        [self shiftRightEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEXTEQ, 0]) {
        [self shiftRightExtEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_ANDEQ, 0]) {
        [self andEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_XOREQ, 0]) {
        [self xorEq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_OREQ, 0]) {
        [self orEq]; 
    } else {
        [self raise:@"No viable alternative found in rule 'assignmentOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAssignmentOperator:)];
}

- (void)relationalOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_LT, 0]) {
        [self lt]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_GT, 0]) {
        [self gt]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_GE, 0]) {
        [self ge]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_LE, 0]) {
        [self le]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_INSTANCEOF, 0]) {
        [self instanceof]; 
    } else {
        [self raise:@"No viable alternative found in rule 'relationalOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchRelationalOperator:)];
}

- (void)equalityOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_EQ, 0]) {
        [self eq]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_NE, 0]) {
        [self ne]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_IS, 0]) {
        [self is]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_ISNOT, 0]) {
        [self isnot]; 
    } else {
        [self raise:@"No viable alternative found in rule 'equalityOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchEqualityOperator:)];
}

- (void)shiftOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_SHIFTLEFT, 0]) {
        [self shiftLeft]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHT, 0]) {
        [self shiftRight]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_SHIFTRIGHTEXT, 0]) {
        [self shiftRightExt]; 
    } else {
        [self raise:@"No viable alternative found in rule 'shiftOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchShiftOperator:)];
}

- (void)incrementOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_PLUSPLUS, 0]) {
        [self plusPlus]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_MINUSMINUS, 0]) {
        [self minusMinus]; 
    } else {
        [self raise:@"No viable alternative found in rule 'incrementOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchIncrementOperator:)];
}

- (void)unaryOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_TILDE, 0]) {
        [self tilde]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_DELETE, 0]) {
        [self delete]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_TYPEOF, 0]) {
        [self typeof]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_VOID, 0]) {
        [self void]; 
    } else {
        [self raise:@"No viable alternative found in rule 'unaryOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryOperator:)];
}

- (void)multiplicativeOperator {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_TIMES, 0]) {
        [self times]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_DIV, 0]) {
        [self div]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_MOD, 0]) {
        [self mod]; 
    } else {
        [self raise:@"No viable alternative found in rule 'multiplicativeOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMultiplicativeOperator:)];
}

- (void)program {
    
    do {
        [self element]; 
    } while ([self speculate:^{ [self element]; }]);

    [self fireAssemblerSelector:@selector(parser:didMatchProgram:)];
}

- (void)element {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_FUNCTION, 0]) {
        [self func]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_BREAKSYM, JAVASCRIPT_TOKEN_KIND_CONTINUESYM, JAVASCRIPT_TOKEN_KIND_DELETE, JAVASCRIPT_TOKEN_KIND_FALSELITERAL, JAVASCRIPT_TOKEN_KIND_FORSYM, JAVASCRIPT_TOKEN_KIND_IFSYM, JAVASCRIPT_TOKEN_KIND_KEYWORDNEW, JAVASCRIPT_TOKEN_KIND_MINUS, JAVASCRIPT_TOKEN_KIND_MINUSMINUS, JAVASCRIPT_TOKEN_KIND_NULL, JAVASCRIPT_TOKEN_KIND_OPENCURLY, JAVASCRIPT_TOKEN_KIND_OPENPAREN, JAVASCRIPT_TOKEN_KIND_PLUSPLUS, JAVASCRIPT_TOKEN_KIND_RETURNSYM, JAVASCRIPT_TOKEN_KIND_SEMI, JAVASCRIPT_TOKEN_KIND_THIS, JAVASCRIPT_TOKEN_KIND_TILDE, JAVASCRIPT_TOKEN_KIND_TRUELITERAL, JAVASCRIPT_TOKEN_KIND_TYPEOF, JAVASCRIPT_TOKEN_KIND_UNDEFINED, JAVASCRIPT_TOKEN_KIND_VAR, JAVASCRIPT_TOKEN_KIND_VOID, JAVASCRIPT_TOKEN_KIND_WHILESYM, JAVASCRIPT_TOKEN_KIND_WITH, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self stmt]; 
    } else {
        [self raise:@"No viable alternative found in rule 'element'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElement:)];
}

- (void)func {
    
    [self function]; 
    [self tryAndRecover:TOKEN_KIND_BUILTIN_WORD block:^{ 
        [self identifier]; 
    } completion:^{ 
        [self identifier]; 
    }];
    [self openParen]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self paramListOpt]; 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];
    [self compoundStmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFunc:)];
}

- (void)paramListOpt {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self paramList]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchParamListOpt:)];
}

- (void)paramList {
    
    [self identifier]; 
    while ([self predicts:JAVASCRIPT_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaIdentifier]; }]) {
            [self commaIdentifier]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchParamList:)];
}

- (void)commaIdentifier {
    
    [self comma]; 
    [self tryAndRecover:TOKEN_KIND_BUILTIN_WORD block:^{ 
        [self identifier]; 
    } completion:^{ 
        [self identifier]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchCommaIdentifier:)];
}

- (void)compoundStmt {
    
    [self openCurly]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSECURLY block:^{ 
        [self stmts]; 
        [self closeCurly]; 
    } completion:^{ 
        [self closeCurly]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchCompoundStmt:)];
}

- (void)stmts {
    
    while ([self predicts:JAVASCRIPT_TOKEN_KIND_BREAKSYM, JAVASCRIPT_TOKEN_KIND_CONTINUESYM, JAVASCRIPT_TOKEN_KIND_DELETE, JAVASCRIPT_TOKEN_KIND_FALSELITERAL, JAVASCRIPT_TOKEN_KIND_FORSYM, JAVASCRIPT_TOKEN_KIND_IFSYM, JAVASCRIPT_TOKEN_KIND_KEYWORDNEW, JAVASCRIPT_TOKEN_KIND_MINUS, JAVASCRIPT_TOKEN_KIND_MINUSMINUS, JAVASCRIPT_TOKEN_KIND_NULL, JAVASCRIPT_TOKEN_KIND_OPENCURLY, JAVASCRIPT_TOKEN_KIND_OPENPAREN, JAVASCRIPT_TOKEN_KIND_PLUSPLUS, JAVASCRIPT_TOKEN_KIND_RETURNSYM, JAVASCRIPT_TOKEN_KIND_SEMI, JAVASCRIPT_TOKEN_KIND_THIS, JAVASCRIPT_TOKEN_KIND_TILDE, JAVASCRIPT_TOKEN_KIND_TRUELITERAL, JAVASCRIPT_TOKEN_KIND_TYPEOF, JAVASCRIPT_TOKEN_KIND_UNDEFINED, JAVASCRIPT_TOKEN_KIND_VAR, JAVASCRIPT_TOKEN_KIND_VOID, JAVASCRIPT_TOKEN_KIND_WHILESYM, JAVASCRIPT_TOKEN_KIND_WITH, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self stmt]; }]) {
            [self stmt]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStmts:)];
}

- (void)stmt {
    
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

    [self fireAssemblerSelector:@selector(parser:didMatchStmt:)];
}

- (void)ifStmt {
    
    [self ifSym]; 
    [self condition]; 
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIfStmt:)];
}

- (void)ifElseStmt {
    
    [self ifSym]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_ELSESYM block:^{ 
        [self condition]; 
        [self stmt]; 
        [self elseSym]; 
    } completion:^{ 
        [self elseSym]; 
    }];
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIfElseStmt:)];
}

- (void)whileStmt {
    
    [self whileSym]; 
    [self condition]; 
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWhileStmt:)];
}

- (void)forParenStmt {
    
    [self forParen]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];
    [self exprOpt]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];
    [self exprOpt]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForParenStmt:)];
}

- (void)forBeginStmt {
    
    [self forBegin]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];
    [self exprOpt]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];
    [self exprOpt]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForBeginStmt:)];
}

- (void)forInStmt {
    
    [self forBegin]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_INSYM block:^{ 
        [self inSym]; 
    } completion:^{ 
        [self inSym]; 
    }];
    [self expr]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForInStmt:)];
}

- (void)breakStmt {
    
    [self breakSym]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchBreakStmt:)];
}

- (void)continueStmt {
    
    [self continueSym]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchContinueStmt:)];
}

- (void)withStmt {
    
    [self with]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_OPENPAREN block:^{ 
        [self openParen]; 
    } completion:^{ 
        [self openParen]; 
    }];
    [self expr]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];
    [self stmt]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWithStmt:)];
}

- (void)returnStmt {
    
    [self returnSym]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self exprOpt]; 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchReturnStmt:)];
}

- (void)variablesOrExprStmt {
    
    [self variablesOrExpr]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_SEMI block:^{ 
        [self semi]; 
    } completion:^{ 
        [self semi]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchVariablesOrExprStmt:)];
}

- (void)condition {
    
    [self openParen]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self expr]; 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchCondition:)];
}

- (void)forParen {
    
    [self forSym]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_OPENPAREN block:^{ 
        [self openParen]; 
    } completion:^{ 
        [self openParen]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchForParen:)];
}

- (void)forBegin {
    
    [self forParen]; 
    [self variablesOrExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForBegin:)];
}

- (void)variablesOrExpr {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_VAR, 0]) {
        [self varVariables]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_DELETE, JAVASCRIPT_TOKEN_KIND_FALSELITERAL, JAVASCRIPT_TOKEN_KIND_KEYWORDNEW, JAVASCRIPT_TOKEN_KIND_MINUS, JAVASCRIPT_TOKEN_KIND_MINUSMINUS, JAVASCRIPT_TOKEN_KIND_NULL, JAVASCRIPT_TOKEN_KIND_OPENPAREN, JAVASCRIPT_TOKEN_KIND_PLUSPLUS, JAVASCRIPT_TOKEN_KIND_THIS, JAVASCRIPT_TOKEN_KIND_TILDE, JAVASCRIPT_TOKEN_KIND_TRUELITERAL, JAVASCRIPT_TOKEN_KIND_TYPEOF, JAVASCRIPT_TOKEN_KIND_UNDEFINED, JAVASCRIPT_TOKEN_KIND_VOID, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self expr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'variablesOrExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchVariablesOrExpr:)];
}

- (void)varVariables {
    
    [self var]; 
    [self variables]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVarVariables:)];
}

- (void)variables {
    
    [self variable]; 
    while ([self predicts:JAVASCRIPT_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaVariable]; }]) {
            [self commaVariable]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchVariables:)];
}

- (void)commaVariable {
    
    [self comma]; 
    [self variable]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaVariable:)];
}

- (void)variable {
    
    [self identifier]; 
    if ([self speculate:^{ [self assignment]; }]) {
        [self assignment]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchVariable:)];
}

- (void)assignment {
    
    [self equals]; 
    [self assignmentExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAssignment:)];
}

- (void)exprOpt {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_DELETE, JAVASCRIPT_TOKEN_KIND_FALSELITERAL, JAVASCRIPT_TOKEN_KIND_KEYWORDNEW, JAVASCRIPT_TOKEN_KIND_MINUS, JAVASCRIPT_TOKEN_KIND_MINUSMINUS, JAVASCRIPT_TOKEN_KIND_NULL, JAVASCRIPT_TOKEN_KIND_OPENPAREN, JAVASCRIPT_TOKEN_KIND_PLUSPLUS, JAVASCRIPT_TOKEN_KIND_THIS, JAVASCRIPT_TOKEN_KIND_TILDE, JAVASCRIPT_TOKEN_KIND_TRUELITERAL, JAVASCRIPT_TOKEN_KIND_TYPEOF, JAVASCRIPT_TOKEN_KIND_UNDEFINED, JAVASCRIPT_TOKEN_KIND_VOID, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self expr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExprOpt:)];
}

- (void)expr {
    
    [self assignmentExpr]; 
    if ([self speculate:^{ [self commaExpr]; }]) {
        [self commaExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)commaExpr {
    
    [self comma]; 
    [self expr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaExpr:)];
}

- (void)assignmentExpr {
    
    [self conditionalExpr]; 
    if ([self speculate:^{ [self extraAssignment]; }]) {
        [self extraAssignment]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAssignmentExpr:)];
}

- (void)extraAssignment {
    
    [self assignmentOperator]; 
    [self assignmentExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchExtraAssignment:)];
}

- (void)conditionalExpr {
    
    [self orExpr]; 
    if ([self speculate:^{ [self ternaryExpr]; }]) {
        [self ternaryExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchConditionalExpr:)];
}

- (void)ternaryExpr {
    
    [self question]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_COLON block:^{ 
        [self assignmentExpr]; 
        [self colon]; 
    } completion:^{ 
        [self colon]; 
    }];
    [self assignmentExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTernaryExpr:)];
}

- (void)orExpr {
    
    [self andExpr]; 
    while ([self predicts:JAVASCRIPT_TOKEN_KIND_OR, 0]) {
        if ([self speculate:^{ [self orAndExpr]; }]) {
            [self orAndExpr]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchOrExpr:)];
}

- (void)orAndExpr {
    
    [self or]; 
    [self andExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrAndExpr:)];
}

- (void)andExpr {
    
    [self bitwiseOrExpr]; 
    if ([self speculate:^{ [self andAndExpr]; }]) {
        [self andAndExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAndExpr:)];
}

- (void)andAndExpr {
    
    [self and]; 
    [self andExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndAndExpr:)];
}

- (void)bitwiseOrExpr {
    
    [self bitwiseXorExpr]; 
    if ([self speculate:^{ [self pipeBitwiseOrExpr]; }]) {
        [self pipeBitwiseOrExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBitwiseOrExpr:)];
}

- (void)pipeBitwiseOrExpr {
    
    [self pipe]; 
    [self bitwiseOrExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPipeBitwiseOrExpr:)];
}

- (void)bitwiseXorExpr {
    
    [self bitwiseAndExpr]; 
    if ([self speculate:^{ [self caretBitwiseXorExpr]; }]) {
        [self caretBitwiseXorExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBitwiseXorExpr:)];
}

- (void)caretBitwiseXorExpr {
    
    [self caret]; 
    [self bitwiseXorExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCaretBitwiseXorExpr:)];
}

- (void)bitwiseAndExpr {
    
    [self equalityExpr]; 
    if ([self speculate:^{ [self ampBitwiseAndExpression]; }]) {
        [self ampBitwiseAndExpression]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBitwiseAndExpr:)];
}

- (void)ampBitwiseAndExpression {
    
    [self amp]; 
    [self bitwiseAndExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAmpBitwiseAndExpression:)];
}

- (void)equalityExpr {
    
    [self relationalExpr]; 
    if ([self speculate:^{ [self equalityOpEqualityExpr]; }]) {
        [self equalityOpEqualityExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchEqualityExpr:)];
}

- (void)equalityOpEqualityExpr {
    
    [self equalityOperator]; 
    [self equalityExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEqualityOpEqualityExpr:)];
}

- (void)relationalExpr {
    
    [self shiftExpr]; 
    while ([self predicts:JAVASCRIPT_TOKEN_KIND_GE, JAVASCRIPT_TOKEN_KIND_GT, JAVASCRIPT_TOKEN_KIND_INSTANCEOF, JAVASCRIPT_TOKEN_KIND_LE, JAVASCRIPT_TOKEN_KIND_LT, 0]) {
        if ([self speculate:^{ [self relationalOperator]; [self shiftExpr]; }]) {
            [self relationalOperator]; 
            [self shiftExpr]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchRelationalExpr:)];
}

- (void)shiftExpr {
    
    [self additiveExpr]; 
    if ([self speculate:^{ [self shiftOpShiftExpr]; }]) {
        [self shiftOpShiftExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchShiftExpr:)];
}

- (void)shiftOpShiftExpr {
    
    [self shiftOperator]; 
    [self shiftExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftOpShiftExpr:)];
}

- (void)additiveExpr {
    
    [self multiplicativeExpr]; 
    if ([self speculate:^{ [self plusOrMinusExpr]; }]) {
        [self plusOrMinusExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAdditiveExpr:)];
}

- (void)plusOrMinusExpr {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_PLUS, 0]) {
        [self plusExpr]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_MINUS, 0]) {
        [self minusExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'plusOrMinusExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPlusOrMinusExpr:)];
}

- (void)plusExpr {
    
    [self plus]; 
    [self additiveExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlusExpr:)];
}

- (void)minusExpr {
    
    [self minus]; 
    [self additiveExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinusExpr:)];
}

- (void)multiplicativeExpr {
    
    [self unaryExpr]; 
    if ([self speculate:^{ [self multiplicativeOperator]; [self multiplicativeExpr]; }]) {
        [self multiplicativeOperator]; 
        [self multiplicativeExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMultiplicativeExpr:)];
}

- (void)unaryExpr {
    
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

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr:)];
}

- (void)unaryExpr1 {
    
    [self unaryOperator]; 
    [self unaryExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr1:)];
}

- (void)unaryExpr2 {
    
    [self minus]; 
    [self unaryExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr2:)];
}

- (void)unaryExpr3 {
    
    [self incrementOperator]; 
    [self memberExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr3:)];
}

- (void)unaryExpr4 {
    
    [self memberExpr]; 
    [self incrementOperator]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr4:)];
}

- (void)callNewExpr {
    
    [self keywordNew]; 
    [self constructor]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCallNewExpr:)];
}

- (void)unaryExpr6 {
    
    [self delete]; 
    [self memberExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr6:)];
}

- (void)constructor {
    
    if ([self speculate:^{ [self this]; [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_DOT block:^{ [self dot]; } completion:^{ [self dot]; }];}]) {
        [self this]; 
        [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_DOT block:^{ 
            [self dot]; 
        } completion:^{ 
            [self dot]; 
        }];
    }
    [self constructorCall]; 

    [self fireAssemblerSelector:@selector(parser:didMatchConstructor:)];
}

- (void)constructorCall {
    
    [self identifier]; 
    if ([self speculate:^{ if ([self predicts:JAVASCRIPT_TOKEN_KIND_OPENPAREN, 0]) {[self parenArgListParen]; } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_DOT, 0]) {[self dot]; [self constructorCall]; } else {[self raise:@"No viable alternative found in rule 'constructorCall'."];}}]) {
        if ([self predicts:JAVASCRIPT_TOKEN_KIND_OPENPAREN, 0]) {
            [self parenArgListParen]; 
        } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_DOT, 0]) {
            [self dot]; 
            [self constructorCall]; 
        } else {
            [self raise:@"No viable alternative found in rule 'constructorCall'."];
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchConstructorCall:)];
}

- (void)parenArgListParen {
    
    [self openParen]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self argListOpt]; 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchParenArgListParen:)];
}

- (void)memberExpr {
    
    [self primaryExpr]; 
    if ([self speculate:^{ [self dotBracketOrParenExpr]; }]) {
        [self dotBracketOrParenExpr]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMemberExpr:)];
}

- (void)dotBracketOrParenExpr {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_DOT, 0]) {
        [self dotMemberExpr]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_OPENBRACKET, 0]) {
        [self bracketMemberExpr]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_OPENPAREN, 0]) {
        [self parenMemberExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'dotBracketOrParenExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchDotBracketOrParenExpr:)];
}

- (void)dotMemberExpr {
    
    [self dot]; 
    [self memberExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDotMemberExpr:)];
}

- (void)bracketMemberExpr {
    
    [self openBracket]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEBRACKET block:^{ 
        [self expr]; 
        [self closeBracket]; 
    } completion:^{ 
        [self closeBracket]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchBracketMemberExpr:)];
}

- (void)parenMemberExpr {
    
    [self openParen]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self argListOpt]; 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchParenMemberExpr:)];
}

- (void)argListOpt {
    
    if ([self speculate:^{ [self argList]; }]) {
        [self argList]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArgListOpt:)];
}

- (void)argList {
    
    [self assignmentExpr]; 
    while ([self predicts:JAVASCRIPT_TOKEN_KIND_COMMA, 0]) {
        if ([self speculate:^{ [self commaAssignmentExpr]; }]) {
            [self commaAssignmentExpr]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArgList:)];
}

- (void)commaAssignmentExpr {
    
    [self comma]; 
    [self assignmentExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaAssignmentExpr:)];
}

- (void)primaryExpr {
    
    if ([self predicts:JAVASCRIPT_TOKEN_KIND_KEYWORDNEW, 0]) {
        [self callNewExpr]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_OPENPAREN, 0]) {
        [self parenExprParen]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self identifier]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self numLiteral]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self stringLiteral]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_FALSELITERAL, 0]) {
        [self falseLiteral]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_TRUELITERAL, 0]) {
        [self trueLiteral]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_NULL, 0]) {
        [self null]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_UNDEFINED, 0]) {
        [self undefined]; 
    } else if ([self predicts:JAVASCRIPT_TOKEN_KIND_THIS, 0]) {
        [self this]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimaryExpr:)];
}

- (void)parenExprParen {
    
    [self openParen]; 
    [self tryAndRecover:JAVASCRIPT_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self expr]; 
        [self closeParen]; 
    } completion:^{ 
        [self closeParen]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchParenExprParen:)];
}

- (void)identifier {
    
    [self matchWord:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchIdentifier:)];
}

- (void)numLiteral {
    
    [self matchNumber:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchNumLiteral:)];
}

- (void)stringLiteral {
    
    [self matchQuotedString:NO];

    [self fireAssemblerSelector:@selector(parser:didMatchStringLiteral:)];
}

@end