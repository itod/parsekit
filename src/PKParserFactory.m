//
//  PKParserFactory.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf All rights reserved.
//

#import "PKParserFactory.h"
#import <ParseKit/ParseKit.h>
#import "PKGrammarParser.h"
#import "NSString+ParseKitAdditions.h"
#import "NSArray+ParseKitAdditions.h"

#import "PKBaseNode.h"
#import "PKRootNode.h"
#import "PKDefinitionNode.h"
#import "PKReferenceNode.h"
#import "PKConstantNode.h"
#import "PKLiteralNode.h"
#import "PKDelimitedNode.h"
#import "PKPatternNode.h"
#import "PKCompositeNode.h"
#import "PKCollectionNode.h"
#import "PKAlternationNode.h"
#import "PKCardinalNode.h"
#import "PKOptionalNode.h"
#import "PKMultipleNode.h"

#import "PKDefinitionPhaseVisitor.h"
#import "PKResolutionPhaseVisitor.h"

@interface PKParser (PKParserFactoryAdditionsFriend)
- (void)setTokenizer:(PKTokenizer *)t;
@end

@interface PKCollectionParser ()
@property (nonatomic, readwrite, retain) NSMutableArray *subparsers;
@end

@interface PKRepetition ()
@property (nonatomic, readwrite, retain) PKParser *subparser;
@end

@interface PKNegation ()
@property (nonatomic, readwrite, retain) PKParser *subparser;
@end

@interface PKDifference ()
@property (nonatomic, readwrite, retain) PKParser *subparser;
@property (nonatomic, readwrite, retain) PKParser *minus;
@end

@interface PKPattern ()
@property (nonatomic, assign) PKTokenType tokenType;
@end

void PKReleaseSubparserTree(PKParser *p) {
    if ([p isKindOfClass:[PKCollectionParser class]]) {
        PKCollectionParser *c = (PKCollectionParser *)p;
        NSArray *subs = c.subparsers;
        if (subs) {
            [subs retain];
            c.subparsers = nil;
            for (PKParser *s in subs) {
                PKReleaseSubparserTree(s);
            }
            [subs release];
        }
    } else if ([p isMemberOfClass:[PKRepetition class]]) {
        PKRepetition *r = (PKRepetition *)p;
		PKParser *sub = r.subparser;
        if (sub) {
            [sub retain];
            r.subparser = nil;
            PKReleaseSubparserTree(sub);
            [sub release];
        }
    } else if ([p isMemberOfClass:[PKNegation class]]) {
        PKNegation *n = (PKNegation *)p;
		PKParser *sub = n.subparser;
        if (sub) {
            [sub retain];
            n.subparser = nil;
            PKReleaseSubparserTree(sub);
            [sub release];
        }
    } else if ([p isMemberOfClass:[PKDifference class]]) {
        PKDifference *d = (PKDifference *)p;
		PKParser *sub = d.subparser;
        if (sub) {
            [sub retain];
            d.subparser = nil;
            PKReleaseSubparserTree(sub);
            [sub release];
        }
		PKParser *m = d.minus;
        if (m) {
            [m retain];
            d.minus = nil;
            PKReleaseSubparserTree(m);
            [m release];
        }
    }
}

@interface PKParserFactory ()
- (NSDictionary *)symbolTableFromGrammar:(NSString *)g error:(NSError **)outError;

- (PKTokenizer *)tokenizerForParsingGrammar;

- (PKAlternation *)zeroOrOne:(PKParser *)p;
- (PKSequence *)oneOrMore:(PKParser *)p;

- (void)parser:(PKParser *)p didMatchTokenizerDirective:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDecl:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchCallback:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSubExpr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchTrackExpr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchStartProduction:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchVarProduction:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchIntersection:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDifference:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPattern:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDiscard:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchLiteral:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchVariable:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchSpecificConstant:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDelimitedString:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPhraseCardinality:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchCardinality:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNegation:(PKAssembly *)a;

@property (nonatomic, retain) PKGrammarParser *grammarParser;
@property (nonatomic, assign) id assembler;
@property (nonatomic, assign) id preassembler;

@property (nonatomic, retain) NSMutableDictionary *directiveTab;

@property (nonatomic, retain) PKRootNode *rootNode;
@property (nonatomic, assign) BOOL wantsCharacters;
@property (nonatomic, retain) PKToken *equals;
@property (nonatomic, retain) PKToken *curly;
@property (nonatomic, retain) PKToken *paren;
@property (nonatomic, retain) PKToken *square;

@property (nonatomic, retain) PKToken *rootToken;
@property (nonatomic, retain) PKToken *defToken;
@property (nonatomic, retain) PKToken *refToken;
@property (nonatomic, retain) PKToken *seqToken;
@property (nonatomic, retain) PKToken *orToken;
@property (nonatomic, retain) PKToken *trackToken;
@property (nonatomic, retain) PKToken *diffToken;
@property (nonatomic, retain) PKToken *intToken;
@property (nonatomic, retain) PKToken *optToken;
@property (nonatomic, retain) PKToken *multiToken;
@property (nonatomic, retain) PKToken *repToken;
@property (nonatomic, retain) PKToken *cardToken;
@property (nonatomic, retain) PKToken *negToken;
@property (nonatomic, retain) PKToken *litToken;
@property (nonatomic, retain) PKToken *delimToken;
@end

@implementation PKParserFactory

+ (PKParserFactory *)factory {
    return [[[PKParserFactory alloc] init] autorelease];
}


- (id)init {
    self = [super init];
    if (self) {
        self.grammarParser = [[[PKGrammarParser alloc] initWithAssembler:self] autorelease];
        self.equals     = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"=" floatValue:0.0];
        self.curly      = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0.0];
        self.paren      = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0.0];
        self.square     = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"[" floatValue:0.0];

        self.rootToken  = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"ROOT" floatValue:0.0];
        self.defToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"$" floatValue:0.0];
        self.refToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"#" floatValue:0.0];
        self.seqToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0.0];
        self.orToken    = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"|" floatValue:0.0];
        self.trackToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"[" floatValue:0.0];
        self.diffToken  = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"-" floatValue:0.0];
        self.intToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"&" floatValue:0.0];
        self.optToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"?" floatValue:0.0];
        self.multiToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"+" floatValue:0.0];
        self.repToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"*" floatValue:0.0];
        self.cardToken  = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0.0];
        self.negToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"~" floatValue:0.0];
        self.litToken   = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"'" floatValue:0.0];
        self.delimToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"%{" floatValue:0.0];
        
        self.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorOnAll;
    }
    return self;
}


- (void)dealloc {
    self.grammarParser = nil;
    self.assembler = nil;
    self.preassembler = nil;
    
    self.directiveTab = nil;
    self.rootNode = nil;
    self.equals = nil;
    self.curly = nil;
    self.paren = nil;
    self.square = nil;
    self.rootToken = nil;
    self.defToken = nil;
    self.refToken = nil;
    self.seqToken = nil;
    self.orToken = nil;
    self.diffToken = nil;
    self.intToken = nil;
    self.optToken = nil;
    self.multiToken = nil;
    self.repToken = nil;
    self.cardToken = nil;
    self.negToken = nil;
    self.litToken = nil;
    self.delimToken = nil;
    [super dealloc];
}


- (PKAlternation *)zeroOrOne:(PKParser *)p {
    PKAlternation *a = [PKAlternation alternation];
    [a add:[PKEmpty empty]];
    [a add:p];
    return a;
}


- (PKSequence *)oneOrMore:(PKParser *)p {
    PKSequence *s = [PKSequence sequence];
    [s add:p];
    [s add:[PKRepetition repetitionWithSubparser:p]];
    return s;
}


- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a error:(NSError **)outError {
    return [self parserFromGrammar:g assembler:a preassembler:nil error:outError];
}


- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a preassembler:(id)pa error:(NSError **)outError {
    PKParser *result = nil;

    @try {
        self.assembler = a;
        self.preassembler = pa;
        
        NSDictionary *symTab = [self symbolTableFromGrammar:g error:outError];
        PKTokenizer *t = [self tokenizerFromGrammarSettings];
        PKParser *start = [self parserFromSymbolTable:symTab];
        
        //NSLog(@"start %@", start);
        
        self.assembler = nil;
        
        if (start && [start isKindOfClass:[PKParser class]]) {
            start.tokenizer = t;
            result = start;
        } else {
            [NSException raise:@"PKGrammarException" format:NSLocalizedString(@"An unknown error occurred while parsing the grammar. The provided language grammar was invalid.", @"")];
        }
        
        return result;

    }
    @catch (NSException *ex) {
        if (outError) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[ex userInfo]];

            // get reason
            NSString *reason = [ex reason];
            if ([reason length]) [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
            
            // get domain
            NSString *name = [ex name];
            NSString *domain = name ? name : @"PKGrammarException";

            // convert to NSError
            NSError *err = [NSError errorWithDomain:domain code:47 userInfo:[[userInfo copy] autorelease]];
            *outError = err;
        } else {
            [ex raise];
        }
    }
}


- (NSDictionary *)symbolTableFromGrammar:(NSString *)g error:(NSError **)outError {
    NSMutableDictionary *symTab = [NSMutableDictionary dictionary];
    [self ASTFromGrammar:g symbolTable:symTab error:outError];

    //NSLog(@"rootNode %@", rootNode);

    PKResolutionPhaseVisitor *resv = [[[PKResolutionPhaseVisitor alloc] init] autorelease];
    resv.symbolTable = symTab;
    [rootNode visit:resv];

    return [[symTab copy] autorelease];
}


- (PKAST *)ASTFromGrammar:(NSString *)g error:(NSError **)outError {
    NSMutableDictionary *symTab = [NSMutableDictionary dictionary];
    return [self ASTFromGrammar:g symbolTable:symTab error:outError];
}


- (PKAST *)ASTFromGrammar:(NSString *)g symbolTable:(NSMutableDictionary *)symTab error:(NSError **)outError {
    self.directiveTab = [NSMutableDictionary dictionary];
    self.rootNode = [PKRootNode nodeWithToken:rootToken];
    
    PKTokenizer *t = [self tokenizerForParsingGrammar];
    t.string = g;

    grammarParser.parser.tokenizer = t;
    [grammarParser.parser parse:g error:outError];
        
    PKDefinitionPhaseVisitor *defv = [[[PKDefinitionPhaseVisitor alloc] init] autorelease];
    defv.symbolTable = symTab;
    defv.assembler = self.assembler;
    defv.preassembler = self.preassembler;
    defv.assemblerSettingBehavior = self.assemblerSettingBehavior;
    [rootNode visit:defv];

    return rootNode;
}


#pragma mark -
#pragma mark Private

- (PKTokenizer *)tokenizerForParsingGrammar {
    PKTokenizer *t = [PKTokenizer tokenizer];
    
    [t.symbolState add:@"%{"];
    [t.symbolState add:@"/i"];
    
    // customize tokenizer to find tokenizer customization directives
    [t setTokenizerState:t.wordState from:'@' to:'@'];
    
    // add support for tokenizer directives like @commentState.fallbackState
    [t.wordState setWordChars:YES from:'.' to:'.'];
    [t.wordState setWordChars:NO from:'-' to:'-'];
    
    // setup comments
    [t setTokenizerState:t.commentState from:'/' to:'/'];
    [t.commentState addSingleLineStartMarker:@"//"];
    [t.commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
    
    // comment state should fallback to delimit state to match regex delimited strings
    t.commentState.fallbackState = t.delimitState;
    
    // regex delimited strings
    [t.delimitState addStartMarker:@"/" endMarker:@"/" allowedCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    [t.delimitState addStartMarker:@"/" endMarker:@"/i" allowedCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
    
    return t;
}


- (PKTokenizer *)tokenizerFromGrammarSettings {
    self.wantsCharacters = [self boolForTokenForKey:@"@wantsCharacters"];
    
    PKTokenizer *t = [PKTokenizer tokenizer];
    [t.commentState removeSingleLineStartMarker:@"//"];
    [t.commentState removeMultiLineStartMarker:@"/*"];
    
    t.whitespaceState.reportsWhitespaceTokens = [self boolForTokenForKey:@"@reportsWhitespaceTokens"];
    t.commentState.reportsCommentTokens = [self boolForTokenForKey:@"@reportsCommentTokens"];
    t.commentState.balancesEOFTerminatedComments = [self boolForTokenForKey:@"balancesEOFTerminatedComments"];
    t.quoteState.balancesEOFTerminatedQuotes = [self boolForTokenForKey:@"@balancesEOFTerminatedQuotes"];
    t.delimitState.balancesEOFTerminatedStrings = [self boolForTokenForKey:@"@balancesEOFTerminatedStrings"];
    t.numberState.allowsTrailingDecimalSeparator = [self boolForTokenForKey:@"@allowsTrailingDecimalSeparator"];
    t.numberState.allowsScientificNotation = [self boolForTokenForKey:@"@allowsScientificNotation"];
    
    BOOL yn = YES;
    if ([directiveTab objectForKey:@"@allowsFloatingPoint"]) {
        yn = [self boolForTokenForKey:@"@allowsFloatingPoint"];
    }
    t.numberState.allowsFloatingPoint = yn;
    
    [self setTokenizerState:t.wordState onTokenizer:t forTokensForKey:@"@wordState"];
    [self setTokenizerState:t.numberState onTokenizer:t forTokensForKey:@"@numberState"];
    [self setTokenizerState:t.quoteState onTokenizer:t forTokensForKey:@"@quoteState"];
    [self setTokenizerState:t.delimitState onTokenizer:t forTokensForKey:@"@delimitState"];
    [self setTokenizerState:t.symbolState onTokenizer:t forTokensForKey:@"@symbolState"];
    [self setTokenizerState:t.commentState onTokenizer:t forTokensForKey:@"@commentState"];
    [self setTokenizerState:t.whitespaceState onTokenizer:t forTokensForKey:@"@whitespaceState"];
    
    [self setFallbackStateOn:t.commentState withTokenizer:t forTokensForKey:@"@commentState.fallbackState"];
    [self setFallbackStateOn:t.delimitState withTokenizer:t forTokensForKey:@"@delimitState.fallbackState"];
    
    NSArray *toks = nil;
    
    // muli-char symbols
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@symbol"]];
    toks = [toks arrayByAddingObjectsFromArray:[directiveTab objectForKey:@"@symbols"]];
    [directiveTab removeObjectForKey:@"@symbol"];
    [directiveTab removeObjectForKey:@"@symbols"];
    for (PKToken *tok in toks) {
        if (tok.isQuotedString) {
            [t.symbolState add:[tok.stringValue stringByTrimmingQuotes]];
        }
    }
    
    // wordChars
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@wordChar"]];
    toks = [toks arrayByAddingObjectsFromArray:[directiveTab objectForKey:@"@wordChars"]];
    [directiveTab removeObjectForKey:@"@wordChar"];
    [directiveTab removeObjectForKey:@"@wordChars"];
    for (PKToken *tok in toks) {
        if (tok.isQuotedString) {
			NSString *s = [tok.stringValue stringByTrimmingQuotes];
			if ([s length]) {
				PKUniChar c = [s characterAtIndex:0];
				[t.wordState setWordChars:YES from:c to:c];
			}
        }
    }
    
    // whitespaceChars
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@whitespaceChar"]];
    toks = [toks arrayByAddingObjectsFromArray:[directiveTab objectForKey:@"@whitespaceChars"]];
    [directiveTab removeObjectForKey:@"@whitespaceChar"];
    [directiveTab removeObjectForKey:@"@whitespaceChars"];
    for (PKToken *tok in toks) {
        if (tok.isQuotedString) {
			NSString *s = [tok.stringValue stringByTrimmingQuotes];
			if ([s length]) {
                PKUniChar c = 0;
                if ([s hasPrefix:@"#x"]) {
                    c = (PKUniChar)[s integerValue];
                } else {
                    c = [s characterAtIndex:0];
                }
                [t.whitespaceState setWhitespaceChars:YES from:c to:c];
			}
        }
    }
    
    // single-line comments
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@singleLineComment"]];
    toks = [toks arrayByAddingObjectsFromArray:[directiveTab objectForKey:@"@singleLineComments"]];
    [directiveTab removeObjectForKey:@"@singleLineComment"];
    [directiveTab removeObjectForKey:@"@singleLineComments"];
    for (PKToken *tok in toks) {
        if (tok.isQuotedString) {
            NSString *s = [tok.stringValue stringByTrimmingQuotes];
            [t.commentState addSingleLineStartMarker:s];
        }
    }
    
    // multi-line comments
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@multiLineComment"]];
    toks = [toks arrayByAddingObjectsFromArray:[directiveTab objectForKey:@"@multiLineComments"]];
    NSAssert(0 == [toks count] % 2, @"@multiLineComments must be specified as quoted strings in multiples of 2");
    [directiveTab removeObjectForKey:@"@multiLineComment"];
    [directiveTab removeObjectForKey:@"@multiLineComments"];
    if ([toks count] > 1) {
        for (NSInteger i = 0; i < [toks count] - 1; i++) {
            PKToken *startTok = [toks objectAtIndex:i];
            PKToken *endTok = [toks objectAtIndex:++i];
            if (startTok.isQuotedString && endTok.isQuotedString) {
                NSString *start = [startTok.stringValue stringByTrimmingQuotes];
                NSString *end = [endTok.stringValue stringByTrimmingQuotes];
                [t.commentState addMultiLineStartMarker:start endMarker:end];
            }
        }
    }
    
    // number state prefixes
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@prefixForRadix"]];
    NSAssert(0 == [toks count] % 2, @"@prefixForRadix must be specified as quoted strings in multiples of 2");
    [directiveTab removeObjectForKey:@"@prefixForRadix"];
    if ([toks count] > 1) {
        for (NSInteger i = 0; i < [toks count] - 1; i++) {
            PKToken *prefixTok = [toks objectAtIndex:i];
            PKToken *radixTok = [toks objectAtIndex:++i];
            if (prefixTok.isQuotedString && radixTok.isNumber) {
                NSString *prefix = [prefixTok.stringValue stringByTrimmingQuotes];
                PKFloat radix = radixTok.floatValue;
                [t.numberState addPrefix:prefix forRadix:radix];
            }
        }
    }
    
    // number state suffix
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@suffixForRadix"]];
    NSAssert(0 == [toks count] % 2, @"@suffixForRadix must be specified as quoted strings in multiples of 2");
    [directiveTab removeObjectForKey:@"@suffixForRadix"];
    if ([toks count] > 1) {
        for (NSInteger i = 0; i < [toks count] - 1; i++) {
            PKToken *suffixTok = [toks objectAtIndex:i];
            PKToken *radixTok = [toks objectAtIndex:++i];
            if (suffixTok.isQuotedString && radixTok.isNumber) {
                NSString *suffix = [suffixTok.stringValue stringByTrimmingQuotes];
                PKFloat radix = radixTok.floatValue;
                if (radix > 0.0) {
                    [t.numberState addSuffix:suffix forRadix:radix];
                }
            }
        }
    }
    
    // number grouping separator
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@groupingSeparatorForRadix"]];
    NSAssert(0 == [toks count] % 2, @"@groupingSeparatorForRadix must be specified as quoted strings in multiples of 2");
    [directiveTab removeObjectForKey:@"@groupingSeparatorForRadix"];
    if ([toks count] > 1) {
        for (NSInteger i = 0; i < [toks count] - 1; i++) {
            PKToken *sepTok = [toks objectAtIndex:i];
            PKToken *radixTok = [toks objectAtIndex:++i];
            if (sepTok.isQuotedString && radixTok.isNumber) {
                NSString *sepStr = [sepTok.stringValue stringByTrimmingQuotes];
                if (1 == [sepStr length]) {
                    PKFloat radix = radixTok.floatValue;
                    if (radix > 0.0) {
                        PKUniChar c = [sepStr characterAtIndex:0];
                        [t.numberState addGroupingSeparator:c forRadix:radix];
                    }
                }
            }
        }
    }
    
    // delimited strings
    toks = [NSArray arrayWithArray:[directiveTab objectForKey:@"@delimitedString"]];
    toks = [toks arrayByAddingObjectsFromArray:[directiveTab objectForKey:@"@delimitedStrings"]];
    NSAssert(0 == [toks count] % 3, @"@delimitedString must be specified as quoted strings in multiples of 3");
    [directiveTab removeObjectForKey:@"@delimitedString"];
    [directiveTab removeObjectForKey:@"@delimitedStrings"];
    if ([toks count] > 1) {
        for (NSInteger i = 0; i < [toks count] - 2; i++) {
            PKToken *startTok = [toks objectAtIndex:i];
            PKToken *endTok = [toks objectAtIndex:++i];
            PKToken *charSetTok = [toks objectAtIndex:++i];
            if (startTok.isQuotedString && endTok.isQuotedString) {
                NSString *start = [startTok.stringValue stringByTrimmingQuotes];
                NSString *end = [endTok.stringValue stringByTrimmingQuotes];
                NSCharacterSet *charSet = nil;
                if (charSetTok.isQuotedString) {
                    charSet = [NSCharacterSet characterSetWithCharactersInString:[charSetTok.stringValue stringByTrimmingQuotes]];
                }
                [t.delimitState addStartMarker:start endMarker:end allowedCharacterSet:charSet];
            }
        }
    }
    
    return t;
}


- (BOOL)boolForTokenForKey:(NSString *)key {
    BOOL result = NO;
    NSArray *toks = [directiveTab objectForKey:key];
    if ([toks count]) {
        NSAssert(1 == [toks count], @"");
        PKToken *tok = [toks objectAtIndex:0];
        if (tok.isWord && [tok.stringValue isEqualToString:@"YES"]) {
            result = YES;
        }
    }
    [directiveTab removeObjectForKey:key];
    return result;
}


- (void)setTokenizerState:(PKTokenizerState *)state onTokenizer:(PKTokenizer *)t forTokensForKey:(NSString *)key {
    NSArray *toks = [directiveTab objectForKey:key];
    for (PKToken *tok in toks) {
        if (tok.isQuotedString) {
            NSString *s = [tok.stringValue stringByTrimmingQuotes];
            if (1 == [s length]) {
                PKUniChar c = [s characterAtIndex:0];
                [t setTokenizerState:state from:c to:c];
            }
        }
    }
    [directiveTab removeObjectForKey:key];
}


- (void)setFallbackStateOn:(PKTokenizerState *)state withTokenizer:(PKTokenizer *)t forTokensForKey:(NSString *)key {
    NSArray *toks = [directiveTab objectForKey:key];
    if ([toks count]) {
        PKToken *tok = [toks objectAtIndex:0];
        if (tok.isWord) {
            PKTokenizerState *fallbackState = [t valueForKey:tok.stringValue];
            if (state != fallbackState) {
                state.fallbackState = fallbackState;
            }
        }
    }
    [directiveTab removeObjectForKey:key];
}


- (PKParser *)parserFromSymbolTable:(NSDictionary *)symTab {
    PKParser *p = symTab[@"@start"];
    NSAssert([p isKindOfClass:[PKParser class]], @"");
    
    return p;
}


- (void)parser:(PKParser *)p didMatchTokenizerDirective:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    NSArray *argToks = [[a objectsAbove:equals] reversedArray];
    [a pop]; // discard '='
    
    PKToken *nameTok = [a pop];
    NSAssert(nameTok, @"");
    NSAssert([nameTok isKindOfClass:[PKToken class]], @"");
    NSAssert(nameTok.isWord, @"");
    
    NSString *prodName = [NSString stringWithFormat:@"%@", nameTok.stringValue];
    NSMutableArray *allToks = directiveTab[prodName];
    if (!allToks) {
        allToks = [NSMutableArray arrayWithCapacity:[argToks count]];
    }
    [allToks addObjectsFromArray:argToks];
    directiveTab[prodName] = allToks;
}


- (void)parser:(PKParser *)p didMatchStartProduction:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);

    PKToken *tok = [a pop];
    NSAssert(tok, @"");
    NSAssert([tok isKindOfClass:[PKToken class]], @"");
    NSAssert(tok.isWord, @"");
    
    NSAssert([tok.stringValue length], @"");
    NSAssert([tok.stringValue isEqualToString:@"@start"], @"");
    
    PKDefinitionNode *node = [PKDefinitionNode nodeWithToken:tok];
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchVarProduction:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);

    PKToken *tok = [a pop];
    NSAssert(tok, @"");
    NSAssert([tok isKindOfClass:[PKToken class]], @"");
    NSAssert(tok.isWord, @"");
    
    NSAssert([tok.stringValue length], @"");
    //NSAssert(islower([tok.stringValue characterAtIndex:0]), @"");

    PKDefinitionNode *node = [PKDefinitionNode nodeWithToken:tok];
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchDecl:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    NSArray *nodes = [a objectsAbove:equals];
    NSAssert([nodes count], @"");

    [a pop]; // '='
    
    PKDefinitionNode *defNode = [a pop];
    NSAssert([defNode isKindOfClass:[PKDefinitionNode class]], @"");
        
    PKBaseNode *node = nil;
    
    if (1 == [nodes count]) {
        node = [nodes lastObject];
    } else {
        PKCollectionNode *seqNode = [PKCollectionNode nodeWithToken:seqToken];
        for (PKBaseNode *child in [nodes reverseObjectEnumerator]) {
            NSAssert([child isKindOfClass:[PKBaseNode class]], @"");
            [seqNode addChild:child];
        }
        node = seqNode;
    }
    
    [defNode addChild:node];

    [self.rootNode addChild:defNode];
}


- (void)parser:(PKParser *)p didMatchTrackExpr:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    NSArray *nodes = [a objectsAbove:square];
    NSAssert([nodes count], @"");
    [a pop]; // pop '['
    
    PKCollectionNode *trackNode = [PKCollectionNode nodeWithToken:trackToken];

    if ([nodes count] > 1) {
        for (PKBaseNode *child in [nodes reverseObjectEnumerator]) {
            NSAssert([child isKindOfClass:[PKBaseNode class]], @"");
            [trackNode addChild:child];
        }
    } else if ([nodes count]) {
        PKBaseNode *node = [nodes lastObject];
        if (seqToken == node.token) {
            PKCollectionNode *seqNode = (PKCollectionNode *)node;
            NSAssert([seqNode isKindOfClass:[PKCollectionNode class]], @"");

            for (PKBaseNode *child in seqNode.children) {
                [trackNode addChild:child];
            }
        } else {
            [trackNode addChild:node];
        }
        
    }
    [a push:trackNode];
}


- (void)parser:(PKParser *)p didMatchSubExpr:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    NSArray *nodes = [a objectsAbove:paren];
    NSAssert([nodes count], @"");
    [a pop]; // pop '('
    
    PKBaseNode *node = nil;
    
    if (1 == [nodes count]) {
        node = [nodes lastObject];
    } else {
        PKCollectionNode *seqNode = [PKCollectionNode nodeWithToken:seqToken];
        for (PKBaseNode *child in [nodes reverseObjectEnumerator]) {
            NSAssert([child isKindOfClass:[PKBaseNode class]], @"");
            [seqNode addChild:child];
        }
        node = seqNode;
    }
    
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchCallback:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKToken *selNameTok2 = [a pop];
    PKToken *selNameTok1 = [a pop];
    NSString *selName = [NSString stringWithFormat:@"%@:%@:", selNameTok1.stringValue, selNameTok2.stringValue];
    
    PKDefinitionNode *defNode = [a pop];
    NSAssert([defNode isKindOfClass:[PKDefinitionNode class]] ,@"");
    
    defNode.callbackName = selName;
    [a push:defNode];
}


- (void)parser:(PKParser *)p didMatchPattern:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKToken *tok = [a pop]; // opts (as Number*) or %{'/', '/'}
    NSAssert([tok isMemberOfClass:[PKToken class]], @"");
    NSAssert(tok.isDelimitedString, @"");
    
    NSString *s = tok.stringValue;
    NSAssert([s length] > 2, @"");
    
    NSAssert([s hasPrefix:@"/"], @"");
    //NSAssert([s hasSuffix:@"/"], @"");
    
    PKPatternOptions opts = PKPatternOptionsNone;
    NSString *optStr = nil;
    
    NSUInteger len = [s length];
    NSRange r = [s rangeOfString:@"/" options:NSBackwardsSearch];
    NSAssert(r.length, @"");
    NSAssert(len > 2, @"");
    
    if (r.location < len - 1) {
        NSUInteger loc = r.location + 1;
        r = NSMakeRange(loc, len - loc);
        optStr = [s substringWithRange:r];
        s = [s substringWithRange:NSMakeRange(0, loc)];
        
        if (NSNotFound != [optStr rangeOfString:@"i"].location) {
            opts |= PKPatternOptionsIgnoreCase;
        }
        if (NSNotFound != [optStr rangeOfString:@"m"].location) {
            opts |= PKPatternOptionsMultiline;
        }
        if (NSNotFound != [optStr rangeOfString:@"x"].location) {
            opts |= PKPatternOptionsComments;
        }
        if (NSNotFound != [optStr rangeOfString:@"s"].location) {
            opts |= PKPatternOptionsDotAll;
        }
        if (NSNotFound != [optStr rangeOfString:@"w"].location) {
            opts |= PKPatternOptionsUnicodeWordBoundaries;
        }
    }
    s = [s stringByTrimmingQuotes];

    PKPatternNode *patNode = [PKPatternNode nodeWithToken:tok];
    patNode.string = s;
    patNode.options = opts;

    [a push:patNode];
}


- (void)parser:(PKParser *)p didMatchDiscard:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);

    PKBaseNode *node = [a pop];
    NSAssert([node isKindOfClass:[PKBaseNode class]], @"");
    node.discard = YES;
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchLiteral:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKToken *tok = [a pop];

    PKLiteralNode *litNode = nil;
    
    NSAssert(tok.isQuotedString, @"");
    NSAssert([tok.stringValue length], @"");
    litNode = [PKLiteralNode nodeWithToken:tok];
    litNode.wantsCharacters = self.wantsCharacters;

    [a push:litNode];
}


- (void)parser:(PKParser *)p didMatchVariable:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    // parser:didMatchVariable: [@start, =, foo]@start/=/foo^;/foo/=/Word/;

    PKToken *tok = [a pop];
    NSAssert(tok, @"");
    NSAssert([tok isKindOfClass:[PKToken class]], @"");
    NSAssert(tok.isWord, @"");
    
    NSAssert([tok.stringValue length], @"");
    NSAssert(islower([tok.stringValue characterAtIndex:0]), @"");

    PKReferenceNode *node = [PKReferenceNode nodeWithToken:tok];
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKToken *tok = [a pop];
    
    PKConstantNode *node = [PKConstantNode nodeWithToken:tok];
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchSpecificConstant:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKToken *quoteTok = [a pop];
    NSString *literal = [quoteTok.stringValue stringByTrimmingQuotes];
    
    PKToken *classTok = [a pop]; // pop 'Symbol'
    
    PKConstantNode *constNode = [PKConstantNode nodeWithToken:classTok];
    constNode.literal = literal;
    
    [a push:constNode];
}


- (void)parser:(PKParser *)p didMatchDelimitedString:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    NSArray *toks = [a objectsAbove:delimToken];
    [a pop]; // discard '(' fence
    
    NSAssert([toks count] > 0 && [toks count] < 3, @"");
    NSString *start = [[[toks lastObject] stringValue] stringByTrimmingQuotes];
    NSString *end = nil;
    if ([toks count] > 1) {
        end = [[[toks objectAtIndex:0] stringValue] stringByTrimmingQuotes];
    }

    PKDelimitedNode *delimNode = [PKDelimitedNode nodeWithToken:delimToken];
    delimNode.startMarker = start;
    delimNode.endMarker = end;
    
    [a push:delimNode];
}


- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKToken *tok = [a pop];
    
    if (self.wantsCharacters) {
        PKUniChar c = [tok.stringValue characterAtIndex:0];
        [a push:[PKSpecificChar specificCharWithChar:c]];
    } else {
        [a push:[NSNumber numberWithDouble:tok.floatValue]];
    }
}


- (void)parser:(PKParser *)p didMatchDifference:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKBaseNode *minusNode = [a pop];
    PKBaseNode *subNode = [a pop];
    NSAssert([minusNode isKindOfClass:[PKBaseNode class]], @"");
    NSAssert([subNode isKindOfClass:[PKBaseNode class]], @"");
    
    PKCompositeNode *diffNode = [PKCompositeNode nodeWithToken:diffToken];
    [diffNode addChild:subNode];
    [diffNode addChild:minusNode];
    
    [a push:diffNode];
}


- (void)parser:(PKParser *)p didMatchIntersection:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    PKBaseNode *predicateNode = [a pop];
    PKBaseNode *subNode = [a pop];
    NSAssert([predicateNode isKindOfClass:[PKBaseNode class]], @"");
    NSAssert([subNode isKindOfClass:[PKBaseNode class]], @"");
    
    PKCollectionNode *diffNode = [PKCollectionNode nodeWithToken:intToken];
    [diffNode addChild:subNode];
    [diffNode addChild:predicateNode];
    
    [a push:diffNode];
}


- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    PKBaseNode *subNode = [a pop];
    NSAssert([subNode isKindOfClass:[PKBaseNode class]], @"");
    
    PKCompositeNode *repNode = [PKCompositeNode nodeWithToken:repToken];
    [repNode addChild:subNode];
    
    [a push:repNode];
}


- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    PKBaseNode *subNode = [a pop];
    NSAssert([subNode isKindOfClass:[PKBaseNode class]], @"");
    
    PKMultipleNode *multiNode = [PKMultipleNode nodeWithToken:multiToken];
    [multiNode addChild:subNode];
    
    [a push:multiNode];
}


- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    PKBaseNode *subNode = [a pop];
    NSAssert([subNode isKindOfClass:[PKBaseNode class]], @"");
    
    PKOptionalNode *optNode = [PKOptionalNode nodeWithToken:optToken];
    [optNode addChild:subNode];
    
    [a push:optNode];
}


- (void)parser:(PKParser *)p didMatchNegation:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);

    PKBaseNode *subNode = [a pop];
    NSAssert([subNode isKindOfClass:[PKBaseNode class]], @"");
    
    PKCompositeNode *negNode = [PKCompositeNode nodeWithToken:negToken];
    [negNode addChild:subNode];
    
    [a push:negNode];
}


- (void)parser:(PKParser *)p didMatchPhraseCardinality:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    
    NSRange r = [[a pop] rangeValue];
    
    PKBaseNode *child = [a pop];
    NSAssert([child isKindOfClass:[PKBaseNode class]], @"");
    
    PKCardinalNode *cardNode = [PKCardinalNode nodeWithToken:cardToken];
    
    NSInteger start = r.location;
    NSInteger end = r.length;
    
    cardNode.rangeStart = start;
    cardNode.rangeEnd = end;
    
    [cardNode addChild:child];

    [a push:cardNode];
}


- (void)parser:(PKParser *)p didMatchCardinality:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);
    NSArray *nums = [a objectsAbove:self.curly];
    [a pop]; // discard '{' tok

    NSAssert([nums count] > 0, @"");
    
    NSNumber *n = [nums lastObject];
    PKFloat start = [n doubleValue];
    PKFloat end = start;
    if ([nums count] > 1) {
        n = nums[0];
        end = [n doubleValue];
    }
    
    NSAssert(start <= end, @"");
    
    NSRange r = NSMakeRange(start, end);
    [a push:[NSValue valueWithRange:r]];
}


- (NSArray *)objectsAbove:(PKToken *)tokA or:(PKToken *)tokB in:(PKAssembly *)a {
    NSMutableArray *result = [NSMutableArray array];
    
    while (![a isStackEmpty]) {
        id obj = [a pop];
        if ([obj isEqual:tokA] || [obj isEqual:tokB]) {
            [a push:obj];
            break;
        }
        [result addObject:obj];
    }
    
    return result;
}


- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a {
    //NSLog(@"%@ %@", NSStringFromSelector(_cmd), a);

    NSArray *rhsNodes = [a objectsAbove:orToken];
    
    PKToken *orTok = [a pop]; // pop '|'
    NSAssert([orTok isKindOfClass:[PKToken class]], @"");
    NSAssert(orTok.isSymbol, @"");
    NSAssert([orTok.stringValue isEqualToString:@"|"], @"");

    PKAlternationNode *orNode = [PKAlternationNode nodeWithToken:orTok];
    
    PKBaseNode *left = nil;

    NSArray *lhsNodes = [self objectsAbove:paren or:equals in:a];
    if (1 == [lhsNodes count]) {
        left = [lhsNodes lastObject];
    } else {
        PKCollectionNode *seqNode = [PKCollectionNode nodeWithToken:seqToken];
        for (PKBaseNode *child in [lhsNodes reverseObjectEnumerator]) {
            NSAssert([child isKindOfClass:[PKBaseNode class]], @"");
            [seqNode addChild:child];
        }
        left = seqNode;
    }
    [orNode addChild:left];

    PKBaseNode *right = nil;

    if (1 == [rhsNodes count]) {
        right = [rhsNodes lastObject];
    } else {
        PKCollectionNode *seqNode = [PKCollectionNode nodeWithToken:seqToken];
        for (PKBaseNode *child in [rhsNodes reverseObjectEnumerator]) {
            NSAssert([child isKindOfClass:[PKBaseNode class]], @"");
            [seqNode addChild:child];
        }
        right = seqNode;
    }
    [orNode addChild:right];

    [a push:orNode];
}

@synthesize grammarParser;
@synthesize assembler;
@synthesize preassembler;

@synthesize directiveTab;
@synthesize rootNode;
@synthesize wantsCharacters;
@synthesize equals;
@synthesize curly;
@synthesize paren;
@synthesize square;

@synthesize rootToken;
@synthesize defToken;
@synthesize refToken;
@synthesize seqToken;
@synthesize orToken;
@synthesize trackToken;
@synthesize diffToken;
@synthesize intToken;
@synthesize optToken;
@synthesize multiToken;
@synthesize repToken;
@synthesize cardToken;
@synthesize negToken;
@synthesize litToken;
@synthesize delimToken;

@synthesize assemblerSettingBehavior;
@end
