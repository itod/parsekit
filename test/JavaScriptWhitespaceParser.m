#import "JavaScriptWhitespaceParser.h"
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

- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;
@end

@interface JavaScriptWhitespaceParser ()
@end

@implementation JavaScriptWhitespaceParser

- (id)init {
    self = [super init];
    if (self) {
        self.startRuleName = @"program";
        self.enableAutomaticErrorRecovery = YES;

        self.tokenKindTab[@"|"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_PIPE);
        self.tokenKindTab[@"!="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_NE);
        self.tokenKindTab[@"("] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN);
        self.tokenKindTab[@"}"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSECURLY);
        self.tokenKindTab[@"return"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_RETURNSYM);
        self.tokenKindTab[@"~"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE);
        self.tokenKindTab[@")"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN);
        self.tokenKindTab[@"*"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMES);
        self.tokenKindTab[@"delete"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE);
        self.tokenKindTab[@"!=="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_ISNOT);
        self.tokenKindTab[@"+"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUS);
        self.tokenKindTab[@"*="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMESEQ);
        self.tokenKindTab[@"instanceof"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_INSTANCEOF);
        self.tokenKindTab[@","] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"<<="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFTEQ);
        self.tokenKindTab[@"if"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_IFSYM);
        self.tokenKindTab[@"-"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS);
        self.tokenKindTab[@"null"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL);
        self.tokenKindTab[@"false"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE);
        self.tokenKindTab[@"."] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT);
        self.tokenKindTab[@"<<"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFT);
        self.tokenKindTab[@"/"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_DIV);
        self.tokenKindTab[@"+="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSEQ);
        self.tokenKindTab[@"<="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_LE);
        self.tokenKindTab[@"^="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_XOREQ);
        self.tokenKindTab[@"["] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENBRACKET);
        self.tokenKindTab[@"undefined"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED);
        self.tokenKindTab[@"typeof"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF);
        self.tokenKindTab[@"||"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_OR);
        self.tokenKindTab[@"function"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_FUNCTION);
        self.tokenKindTab[@"]"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEBRACKET);
        self.tokenKindTab[@"^"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_CARET);
        self.tokenKindTab[@"=="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_EQ);
        self.tokenKindTab[@"continue"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_CONTINUESYM);
        self.tokenKindTab[@"break"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_BREAKSYM);
        self.tokenKindTab[@"-="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSEQ);
        self.tokenKindTab[@">="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_GE);
        self.tokenKindTab[@":"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_COLON);
        self.tokenKindTab[@"in"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_INSYM);
        self.tokenKindTab[@";"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI);
        self.tokenKindTab[@"for"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_FORSYM);
        self.tokenKindTab[@"++"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS);
        self.tokenKindTab[@"<"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_LT);
        self.tokenKindTab[@"%="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_MODEQ);
        self.tokenKindTab[@">>"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHT);
        self.tokenKindTab[@"="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@">"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_GT);
        self.tokenKindTab[@"void"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID);
        self.tokenKindTab[@"?"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_QUESTION);
        self.tokenKindTab[@"while"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_WHILESYM);
        self.tokenKindTab[@"&="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_ANDEQ);
        self.tokenKindTab[@">>>="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXTEQ);
        self.tokenKindTab[@"else"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_ELSESYM);
        self.tokenKindTab[@"/="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_DIVEQ);
        self.tokenKindTab[@"&&"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_AND);
        self.tokenKindTab[@"var"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_VAR);
        self.tokenKindTab[@"|="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_OREQ);
        self.tokenKindTab[@">>="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEQ);
        self.tokenKindTab[@"--"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS);
        self.tokenKindTab[@"new"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW);
        self.tokenKindTab[@"!"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_NOT);
        self.tokenKindTab[@">>>"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXT);
        self.tokenKindTab[@"true"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"this"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS);
        self.tokenKindTab[@"with"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_WITH);
        self.tokenKindTab[@"==="] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_IS);
        self.tokenKindTab[@"%"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_MOD);
        self.tokenKindTab[@"&"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_AMP);
        self.tokenKindTab[@"{"] = @(JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENCURLY);

        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_PIPE] = @"|";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN] = @"(";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSECURLY] = @"}";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_RETURNSYM] = @"return";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE] = @"~";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN] = @")";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMES] = @"*";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE] = @"delete";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_ISNOT] = @"!==";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUS] = @"+";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMESEQ] = @"*=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_INSTANCEOF] = @"instanceof";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFTEQ] = @"<<=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_IFSYM] = @"if";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS] = @"-";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL] = @"null";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFT] = @"<<";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_DIV] = @"/";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSEQ] = @"+=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_XOREQ] = @"^=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENBRACKET] = @"[";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED] = @"undefined";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF] = @"typeof";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_OR] = @"||";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_FUNCTION] = @"function";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEBRACKET] = @"]";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_CARET] = @"^";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_EQ] = @"==";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_CONTINUESYM] = @"continue";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_BREAKSYM] = @"break";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSEQ] = @"-=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_COLON] = @":";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_INSYM] = @"in";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI] = @";";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_FORSYM] = @"for";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS] = @"++";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_LT] = @"<";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_MODEQ] = @"%=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHT] = @">>";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_GT] = @">";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID] = @"void";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_QUESTION] = @"?";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_WHILESYM] = @"while";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_ANDEQ] = @"&=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXTEQ] = @">>>=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_ELSESYM] = @"else";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_DIVEQ] = @"/=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_AND] = @"&&";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_VAR] = @"var";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_OREQ] = @"|=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEQ] = @">>=";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS] = @"--";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW] = @"new";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_NOT] = @"!";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXT] = @">>>";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS] = @"this";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_WITH] = @"with";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_IS] = @"===";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_MOD] = @"%";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_AMP] = @"&";
        self.tokenKindNameTab[JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENCURLY] = @"{";

    }
    return self;
}

- (void)start {
    [self program_];
}

- (void)program_ {
    
    [self execute:(id)^{
    
        PKTokenizer *t = self.tokenizer;
        
        // whitespace
        self.silentlyConsumesWhitespace = YES;
        t.whitespaceState.reportsWhitespaceTokens = YES;
        self.assembly.preservesWhitespaceTokens = YES;

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
        do {
            [self element_]; 
        } while ([self speculate:^{ [self element_]; }]);
        [self matchEOF:YES]; 
    } completion:^{
        [self matchEOF:YES];
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchProgram:)];
}

- (void)ifSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_IFSYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIf:)];
}

- (void)elseSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_ELSESYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchElse:)];
}

- (void)whileSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_WHILESYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWhile:)];
}

- (void)forSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_FORSYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFor:)];
}

- (void)inSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_INSYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIn:)];
}

- (void)breakSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_BREAKSYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBreak:)];
}

- (void)continueSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_CONTINUESYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchContinue:)];
}

- (void)with_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_WITH discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWith:)];
}

- (void)returnSym_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_RETURNSYM discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchReturn:)];
}

- (void)var_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_VAR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVar:)];
}

- (void)delete_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDelete:)];
}

- (void)keywordNew_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchKeywordNew:)];
}

- (void)this_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchThis:)];
}

- (void)false_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFalseLiteral:)];
}

- (void)true_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTrueLiteral:)];
}

- (void)null_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNull:)];
}

- (void)undefined_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUndefined:)];
}

- (void)void_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVoid:)];
}

- (void)typeof_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTypeof:)];
}

- (void)instanceof_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_INSTANCEOF discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchInstanceof:)];
}

- (void)function_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_FUNCTION discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFunction:)];
}

- (void)openCurly_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENCURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenCurly:)];
}

- (void)closeCurly_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSECURLY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseCurly:)];
}

- (void)openParen_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenParen:)];
}

- (void)closeParen_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseParen:)];
}

- (void)openBracket_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOpenBracket:)];
}

- (void)closeBracket_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEBRACKET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCloseBracket:)];
}

- (void)comma_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_COMMA discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchComma:)];
}

- (void)dot_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDot:)];
}

- (void)semi_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemi:)];
}

- (void)colon_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_COLON discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchColon:)];
}

- (void)equals_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_EQUALS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEquals:)];
}

- (void)not_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_NOT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNot:)];
}

- (void)lt_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_LT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLt:)];
}

- (void)gt_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_GT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGt:)];
}

- (void)amp_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_AMP discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAmp:)];
}

- (void)pipe_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_PIPE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPipe:)];
}

- (void)caret_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_CARET discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCaret:)];
}

- (void)tilde_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTilde:)];
}

- (void)question_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_QUESTION discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchQuestion:)];
}

- (void)plus_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlus:)];
}

- (void)minus_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinus:)];
}

- (void)times_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMES discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTimes:)];
}

- (void)div_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_DIV discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDiv:)];
}

- (void)mod_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_MOD discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMod:)];
}

- (void)or_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_OR discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOr:)];
}

- (void)and_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_AND discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAnd:)];
}

- (void)ne_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_NE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNe:)];
}

- (void)isnot_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_ISNOT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIsnot:)];
}

- (void)eq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_EQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEq:)];
}

- (void)is_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_IS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIs:)];
}

- (void)le_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_LE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLe:)];
}

- (void)ge_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_GE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchGe:)];
}

- (void)plusPlus_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlusPlus:)];
}

- (void)minusMinus_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinusMinus:)];
}

- (void)plusEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlusEq:)];
}

- (void)minusEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinusEq:)];
}

- (void)timesEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMESEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTimesEq:)];
}

- (void)divEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_DIVEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDivEq:)];
}

- (void)modEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_MODEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchModEq:)];
}

- (void)shiftLeft_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftLeft:)];
}

- (void)shiftRight_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRight:)];
}

- (void)shiftRightExt_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXT discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRightExt:)];
}

- (void)shiftLeftEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFTEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftLeftEq:)];
}

- (void)shiftRightEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRightEq:)];
}

- (void)shiftRightExtEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXTEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftRightExtEq:)];
}

- (void)andEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_ANDEQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndEq:)];
}

- (void)xorEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_XOREQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchXorEq:)];
}

- (void)orEq_ {
    
    [self match:JAVASCRIPTWHITESPACE_TOKEN_KIND_OREQ discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrEq:)];
}

- (void)assignmentOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_EQUALS, 0]) {
        [self equals_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSEQ, 0]) {
        [self plusEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSEQ, 0]) {
        [self minusEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMESEQ, 0]) {
        [self timesEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DIVEQ, 0]) {
        [self divEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_MODEQ, 0]) {
        [self modEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFTEQ, 0]) {
        [self shiftLeftEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEQ, 0]) {
        [self shiftRightEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXTEQ, 0]) {
        [self shiftRightExtEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_ANDEQ, 0]) {
        [self andEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_XOREQ, 0]) {
        [self xorEq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_OREQ, 0]) {
        [self orEq_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'assignmentOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAssignmentOperator:)];
}

- (void)relationalOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_LT, 0]) {
        [self lt_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_GT, 0]) {
        [self gt_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_GE, 0]) {
        [self ge_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_LE, 0]) {
        [self le_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_INSTANCEOF, 0]) {
        [self instanceof_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'relationalOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchRelationalOperator:)];
}

- (void)equalityOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_EQ, 0]) {
        [self eq_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_NE, 0]) {
        [self ne_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_IS, 0]) {
        [self is_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_ISNOT, 0]) {
        [self isnot_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'equalityOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchEqualityOperator:)];
}

- (void)shiftOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTLEFT, 0]) {
        [self shiftLeft_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHT, 0]) {
        [self shiftRight_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_SHIFTRIGHTEXT, 0]) {
        [self shiftRightExt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'shiftOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchShiftOperator:)];
}

- (void)incrementOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS, 0]) {
        [self plusPlus_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS, 0]) {
        [self minusMinus_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'incrementOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchIncrementOperator:)];
}

- (void)unaryOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE, 0]) {
        [self tilde_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE, 0]) {
        [self delete_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF, 0]) {
        [self typeof_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID, 0]) {
        [self void_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'unaryOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryOperator:)];
}

- (void)multiplicativeOperator_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_TIMES, 0]) {
        [self times_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DIV, 0]) {
        [self div_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_MOD, 0]) {
        [self mod_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'multiplicativeOperator'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMultiplicativeOperator:)];
}

- (void)element_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_FUNCTION, 0]) {
        [self func_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_BREAKSYM, JAVASCRIPTWHITESPACE_TOKEN_KIND_CONTINUESYM, JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE, JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE, JAVASCRIPTWHITESPACE_TOKEN_KIND_FORSYM, JAVASCRIPTWHITESPACE_TOKEN_KIND_IFSYM, JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL, JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENCURLY, JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_RETURNSYM, JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI, JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS, JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE, JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE, JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF, JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED, JAVASCRIPTWHITESPACE_TOKEN_KIND_VAR, JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID, JAVASCRIPTWHITESPACE_TOKEN_KIND_WHILESYM, JAVASCRIPTWHITESPACE_TOKEN_KIND_WITH, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self stmt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'element'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchElement:)];
}

- (void)func_ {
    
    [self function_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN block:^{ 
        [self identifier_]; 
        [self openParen_]; 
    } completion:^{ 
        [self openParen_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self paramListOpt_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];
        [self compoundStmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchFunc:)];
}

- (void)paramListOpt_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self paramList_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchParamListOpt:)];
}

- (void)paramList_ {
    
    [self identifier_]; 
    while ([self speculate:^{ [self commaIdentifier_]; }]) {
        [self commaIdentifier_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchParamList:)];
}

- (void)commaIdentifier_ {
    
    [self comma_]; 
    [self identifier_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaIdentifier:)];
}

- (void)compoundStmt_ {
    
    [self openCurly_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSECURLY block:^{ 
        [self stmts_]; 
        [self closeCurly_]; 
    } completion:^{ 
        [self closeCurly_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchCompoundStmt:)];
}

- (void)stmts_ {
    
    while ([self speculate:^{ [self stmt_]; }]) {
        [self stmt_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStmts:)];
}

- (void)stmt_ {
    
    if ([self speculate:^{ [self semi_]; }]) {
        [self semi_]; 
    } else if ([self speculate:^{ [self ifStmt_]; }]) {
        [self ifStmt_]; 
    } else if ([self speculate:^{ [self ifElseStmt_]; }]) {
        [self ifElseStmt_]; 
    } else if ([self speculate:^{ [self whileStmt_]; }]) {
        [self whileStmt_]; 
    } else if ([self speculate:^{ [self forParenStmt_]; }]) {
        [self forParenStmt_]; 
    } else if ([self speculate:^{ [self forBeginStmt_]; }]) {
        [self forBeginStmt_]; 
    } else if ([self speculate:^{ [self forInStmt_]; }]) {
        [self forInStmt_]; 
    } else if ([self speculate:^{ [self breakStmt_]; }]) {
        [self breakStmt_]; 
    } else if ([self speculate:^{ [self continueStmt_]; }]) {
        [self continueStmt_]; 
    } else if ([self speculate:^{ [self withStmt_]; }]) {
        [self withStmt_]; 
    } else if ([self speculate:^{ [self returnStmt_]; }]) {
        [self returnStmt_]; 
    } else if ([self speculate:^{ [self compoundStmt_]; }]) {
        [self compoundStmt_]; 
    } else if ([self speculate:^{ [self variablesOrExprStmt_]; }]) {
        [self variablesOrExprStmt_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'stmt'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStmt:)];
}

- (void)ifStmt_ {
    
    [self ifSym_]; 
    [self condition_]; 
    [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIfStmt:)];
}

- (void)ifElseStmt_ {
    
    [self ifSym_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_ELSESYM block:^{ 
        [self condition_]; 
        [self stmt_]; 
        [self elseSym_]; 
    } completion:^{ 
        [self elseSym_]; 
    }];
        [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIfElseStmt:)];
}

- (void)whileStmt_ {
    
    [self whileSym_]; 
    [self condition_]; 
    [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWhileStmt:)];
}

- (void)forParenStmt_ {
    
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self forParen_]; 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self exprOpt_]; 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self exprOpt_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];
        [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForParenStmt:)];
}

- (void)forBeginStmt_ {
    
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self forBegin_]; 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self exprOpt_]; 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self exprOpt_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];
        [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForBeginStmt:)];
}

- (void)forInStmt_ {
    
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_INSYM block:^{ 
        [self forBegin_]; 
        [self inSym_]; 
    } completion:^{ 
        [self inSym_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self expr_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];
        [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForInStmt:)];
}

- (void)breakStmt_ {
    
    [self breakSym_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchBreakStmt:)];
}

- (void)continueStmt_ {
    
    [self continueSym_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchContinueStmt:)];
}

- (void)withStmt_ {
    
    [self with_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN block:^{ 
        [self openParen_]; 
    } completion:^{ 
        [self openParen_]; 
    }];
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self expr_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];
        [self stmt_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchWithStmt:)];
}

- (void)returnStmt_ {
    
    [self returnSym_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self exprOpt_]; 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchReturnStmt:)];
}

- (void)variablesOrExprStmt_ {
    
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_SEMI block:^{ 
        [self variablesOrExpr_]; 
        [self semi_]; 
    } completion:^{ 
        [self semi_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchVariablesOrExprStmt:)];
}

- (void)condition_ {
    
    [self openParen_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self expr_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchCondition:)];
}

- (void)forParen_ {
    
    [self forSym_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN block:^{ 
        [self openParen_]; 
    } completion:^{ 
        [self openParen_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchForParen:)];
}

- (void)forBegin_ {
    
    [self forParen_]; 
    [self variablesOrExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchForBegin:)];
}

- (void)variablesOrExpr_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_VAR, 0]) {
        [self varVariables_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE, JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE, JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL, JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS, JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE, JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE, JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF, JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED, JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self expr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'variablesOrExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchVariablesOrExpr:)];
}

- (void)varVariables_ {
    
    [self var_]; 
    [self variables_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVarVariables:)];
}

- (void)variables_ {
    
    [self variable_]; 
    while ([self speculate:^{ [self commaVariable_]; }]) {
        [self commaVariable_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchVariables:)];
}

- (void)commaVariable_ {
    
    [self comma_]; 
    [self variable_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaVariable:)];
}

- (void)variable_ {
    
    [self identifier_]; 
    if ([self speculate:^{ [self assignment_]; }]) {
        [self assignment_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchVariable:)];
}

- (void)assignment_ {
    
    [self equals_]; 
    [self assignmentExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAssignment:)];
}

- (void)exprOpt_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DELETE, JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE, JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW, JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUSMINUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL, JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUSPLUS, JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS, JAVASCRIPTWHITESPACE_TOKEN_KIND_TILDE, JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE, JAVASCRIPTWHITESPACE_TOKEN_KIND_TYPEOF, JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED, JAVASCRIPTWHITESPACE_TOKEN_KIND_VOID, TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self expr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExprOpt:)];
}

- (void)expr_ {
    
    [self assignmentExpr_]; 
    if ([self speculate:^{ [self commaExpr_]; }]) {
        [self commaExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)commaExpr_ {
    
    [self comma_]; 
    [self expr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaExpr:)];
}

- (void)assignmentExpr_ {
    
    [self conditionalExpr_]; 
    if ([self speculate:^{ [self extraAssignment_]; }]) {
        [self extraAssignment_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAssignmentExpr:)];
}

- (void)extraAssignment_ {
    
    [self assignmentOperator_]; 
    [self assignmentExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchExtraAssignment:)];
}

- (void)conditionalExpr_ {
    
    [self orExpr_]; 
    if ([self speculate:^{ [self ternaryExpr_]; }]) {
        [self ternaryExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchConditionalExpr:)];
}

- (void)ternaryExpr_ {
    
    [self question_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_COLON block:^{ 
        [self assignmentExpr_]; 
        [self colon_]; 
    } completion:^{ 
        [self colon_]; 
    }];
        [self assignmentExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTernaryExpr:)];
}

- (void)orExpr_ {
    
    [self andExpr_]; 
    while ([self speculate:^{ [self orAndExpr_]; }]) {
        [self orAndExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchOrExpr:)];
}

- (void)orAndExpr_ {
    
    [self or_]; 
    [self andExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrAndExpr:)];
}

- (void)andExpr_ {
    
    [self bitwiseOrExpr_]; 
    if ([self speculate:^{ [self andAndExpr_]; }]) {
        [self andAndExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAndExpr:)];
}

- (void)andAndExpr_ {
    
    [self and_]; 
    [self andExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAndAndExpr:)];
}

- (void)bitwiseOrExpr_ {
    
    [self bitwiseXorExpr_]; 
    if ([self speculate:^{ [self pipeBitwiseOrExpr_]; }]) {
        [self pipeBitwiseOrExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBitwiseOrExpr:)];
}

- (void)pipeBitwiseOrExpr_ {
    
    [self pipe_]; 
    [self bitwiseOrExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPipeBitwiseOrExpr:)];
}

- (void)bitwiseXorExpr_ {
    
    [self bitwiseAndExpr_]; 
    if ([self speculate:^{ [self caretBitwiseXorExpr_]; }]) {
        [self caretBitwiseXorExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBitwiseXorExpr:)];
}

- (void)caretBitwiseXorExpr_ {
    
    [self caret_]; 
    [self bitwiseXorExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCaretBitwiseXorExpr:)];
}

- (void)bitwiseAndExpr_ {
    
    [self equalityExpr_]; 
    if ([self speculate:^{ [self ampBitwiseAndExpression_]; }]) {
        [self ampBitwiseAndExpression_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBitwiseAndExpr:)];
}

- (void)ampBitwiseAndExpression_ {
    
    [self amp_]; 
    [self bitwiseAndExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAmpBitwiseAndExpression:)];
}

- (void)equalityExpr_ {
    
    [self relationalExpr_]; 
    if ([self speculate:^{ [self equalityOpEqualityExpr_]; }]) {
        [self equalityOpEqualityExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchEqualityExpr:)];
}

- (void)equalityOpEqualityExpr_ {
    
    [self equalityOperator_]; 
    [self equalityExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchEqualityOpEqualityExpr:)];
}

- (void)relationalExpr_ {
    
    [self shiftExpr_]; 
    while ([self speculate:^{ [self relationalOperator_]; [self shiftExpr_]; }]) {
        [self relationalOperator_]; 
        [self shiftExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchRelationalExpr:)];
}

- (void)shiftExpr_ {
    
    [self additiveExpr_]; 
    if ([self speculate:^{ [self shiftOpShiftExpr_]; }]) {
        [self shiftOpShiftExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchShiftExpr:)];
}

- (void)shiftOpShiftExpr_ {
    
    [self shiftOperator_]; 
    [self shiftExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchShiftOpShiftExpr:)];
}

- (void)additiveExpr_ {
    
    [self multiplicativeExpr_]; 
    if ([self speculate:^{ [self plusOrMinusExpr_]; }]) {
        [self plusOrMinusExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAdditiveExpr:)];
}

- (void)plusOrMinusExpr_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_PLUS, 0]) {
        [self plusExpr_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_MINUS, 0]) {
        [self minusExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'plusOrMinusExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPlusOrMinusExpr:)];
}

- (void)plusExpr_ {
    
    [self plus_]; 
    [self additiveExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPlusExpr:)];
}

- (void)minusExpr_ {
    
    [self minus_]; 
    [self additiveExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchMinusExpr:)];
}

- (void)multiplicativeExpr_ {
    
    [self unaryExpr_]; 
    if ([self speculate:^{ [self multiplicativeOperator_]; [self multiplicativeExpr_]; }]) {
        [self multiplicativeOperator_]; 
        [self multiplicativeExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMultiplicativeExpr:)];
}

- (void)unaryExpr_ {
    
    if ([self speculate:^{ [self memberExpr_]; }]) {
        [self memberExpr_]; 
    } else if ([self speculate:^{ [self unaryExpr1_]; }]) {
        [self unaryExpr1_]; 
    } else if ([self speculate:^{ [self unaryExpr2_]; }]) {
        [self unaryExpr2_]; 
    } else if ([self speculate:^{ [self unaryExpr3_]; }]) {
        [self unaryExpr3_]; 
    } else if ([self speculate:^{ [self unaryExpr4_]; }]) {
        [self unaryExpr4_]; 
    } else if ([self speculate:^{ [self unaryExpr6_]; }]) {
        [self unaryExpr6_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'unaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr:)];
}

- (void)unaryExpr1_ {
    
    [self unaryOperator_]; 
    [self unaryExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr1:)];
}

- (void)unaryExpr2_ {
    
    [self minus_]; 
    [self unaryExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr2:)];
}

- (void)unaryExpr3_ {
    
    [self incrementOperator_]; 
    [self memberExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr3:)];
}

- (void)unaryExpr4_ {
    
    [self memberExpr_]; 
    [self incrementOperator_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr4:)];
}

- (void)callNewExpr_ {
    
    [self keywordNew_]; 
    [self constructor_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCallNewExpr:)];
}

- (void)unaryExpr6_ {
    
    [self delete_]; 
    [self memberExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchUnaryExpr6:)];
}

- (void)constructor_ {
    
    if ([self speculate:^{ [self this_]; [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT block:^{ [self dot_]; } completion:^{ [self dot_]; }];}]) {
        [self this_]; 
        [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT block:^{ 
            [self dot_]; 
        } completion:^{ 
            [self dot_]; 
        }];
    }
    [self constructorCall_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchConstructor:)];
}

- (void)constructorCall_ {
    
    [self identifier_]; 
    if ([self speculate:^{ if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, 0]) {[self parenArgListParen_]; } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT, 0]) {[self dot_]; [self constructorCall_]; } else {[self raise:@"No viable alternative found in rule 'constructorCall'."];}}]) {
        if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, 0]) {
            [self parenArgListParen_]; 
        } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT, 0]) {
            [self dot_]; 
            [self constructorCall_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'constructorCall'."];
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchConstructorCall:)];
}

- (void)parenArgListParen_ {
    
    [self openParen_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self argListOpt_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchParenArgListParen:)];
}

- (void)memberExpr_ {
    
    [self primaryExpr_]; 
    if ([self speculate:^{ [self dotBracketOrParenExpr_]; }]) {
        [self dotBracketOrParenExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchMemberExpr:)];
}

- (void)dotBracketOrParenExpr_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_DOT, 0]) {
        [self dotMemberExpr_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENBRACKET, 0]) {
        [self bracketMemberExpr_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, 0]) {
        [self parenMemberExpr_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'dotBracketOrParenExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchDotBracketOrParenExpr:)];
}

- (void)dotMemberExpr_ {
    
    [self dot_]; 
    [self memberExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDotMemberExpr:)];
}

- (void)bracketMemberExpr_ {
    
    [self openBracket_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEBRACKET block:^{ 
        [self expr_]; 
        [self closeBracket_]; 
    } completion:^{ 
        [self closeBracket_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchBracketMemberExpr:)];
}

- (void)parenMemberExpr_ {
    
    [self openParen_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self argListOpt_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchParenMemberExpr:)];
}

- (void)argListOpt_ {
    
    if ([self speculate:^{ [self argList_]; }]) {
        [self argList_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArgListOpt:)];
}

- (void)argList_ {
    
    [self assignmentExpr_]; 
    while ([self speculate:^{ [self commaAssignmentExpr_]; }]) {
        [self commaAssignmentExpr_]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchArgList:)];
}

- (void)commaAssignmentExpr_ {
    
    [self comma_]; 
    [self assignmentExpr_]; 

    [self fireAssemblerSelector:@selector(parser:didMatchCommaAssignmentExpr:)];
}

- (void)primaryExpr_ {
    
    if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_KEYWORDNEW, 0]) {
        [self callNewExpr_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_OPENPAREN, 0]) {
        [self parenExprParen_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self identifier_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self numLiteral_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self stringLiteral_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_FALSE, 0]) {
        [self false_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_TRUE, 0]) {
        [self true_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_NULL, 0]) {
        [self null_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_UNDEFINED, 0]) {
        [self undefined_]; 
    } else if ([self predicts:JAVASCRIPTWHITESPACE_TOKEN_KIND_THIS, 0]) {
        [self this_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimaryExpr:)];
}

- (void)parenExprParen_ {
    
    [self openParen_]; 
    [self tryAndRecover:JAVASCRIPTWHITESPACE_TOKEN_KIND_CLOSEPAREN block:^{ 
        [self expr_]; 
        [self closeParen_]; 
    } completion:^{ 
        [self closeParen_]; 
    }];

    [self fireAssemblerSelector:@selector(parser:didMatchParenExprParen:)];
}

- (void)identifier_ {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIdentifier:)];
}

- (void)numLiteral_ {
    
    [self matchNumber:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNumLiteral:)];
}

- (void)stringLiteral_ {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStringLiteral:)];
}

@end