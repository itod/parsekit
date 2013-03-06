//
//  TDParserFactory.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/3/12.
//
//

#import "TDParserFactory.h"
#import <ParseKit/ParseKit.h>
#import "TDGrammarParser.h"
#import "NSString+ParseKitAdditions.h"
#import "NSArray+ParseKitAdditions.h"

#import "PKAST.h"
#import "PKNodeVariable.h"
#import "PKNodeConstant.h"
#import "PKNodeDelimited.h"
#import "PKNodePattern.h"
#import "PKNodeComposite.h"
#import "PKNodeCollection.h"
#import "PKNodeCardinal.h"
#import "PKNodeOptional.h"
#import "PKNodeMultiple.h"
//#import "PKNodeRepetition.h"
//#import "PKNodeDifference.h"
//#import "PKNodeNegation.h"

#define USE_TRACK 0

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

@interface TDParserFactory ()
- (PKTokenizer *)tokenizerForParsingGrammar;
- (PKTokenizer *)tokenizerFromGrammarSettings;
- (PKParser *)parserFromAST:(PKNodeBase *)rootNode;

- (void)parser:(PKParser *)p didMatchStatement:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchCallback:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchExpression:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchAnd:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchIntersection:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDifference:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPatternOptions:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPattern:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDiscard:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchLiteral:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchVariable:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchDelimitedString:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchPhraseCardinality:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchCardinality:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a;
- (void)parser:(PKParser *)p didMatchNegation:(PKAssembly *)a;

@property (nonatomic, retain) TDGrammarParser *grammarParser;
@property (nonatomic, assign) id assembler;
@property (nonatomic, assign) id preassembler;
@property (nonatomic, assign) BOOL wantsCharacters;
@property (nonatomic, retain) PKToken *equals;
@property (nonatomic, retain) PKToken *curly;
@property (nonatomic, retain) PKToken *paren;

@property (nonatomic, retain) PKToken *seqToken;
@property (nonatomic, retain) PKToken *trackToken;
@property (nonatomic, retain) PKToken *delimToken;
@property (nonatomic, retain) PKToken *patternToken;

@property (nonatomic, retain) NSMutableDictionary *productionTab;
@property (nonatomic, retain) NSMutableDictionary *callbackTab;
@end

@implementation TDParserFactory {

}

+ (TDParserFactory *)factory {
    return [[[TDParserFactory alloc] init] autorelease];
}


- (id)init {
    self = [super init];
    if (self) {
        self.grammarParser = [[[TDGrammarParser alloc] initWithAssembler:self] autorelease];
        self.equals = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"=" floatValue:0.0];
        self.curly = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0.0];
        self.paren = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0.0];

        self.seqToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"SEQ" floatValue:0.0];
        self.trackToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"TRACK" floatValue:0.0];
        self.delimToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"DELIM" floatValue:0.0];
}
    return self;
}


- (void)dealloc {
    self.grammarParser = nil;
    self.assembler = nil;
    self.preassembler = nil;
    self.equals = nil;
    self.curly = nil;
    self.paren = nil;
    
    self.seqToken = nil;
    self.trackToken = nil;
    self.delimToken = nil;
    self.patternToken = nil;
    
    self.productionTab = nil;
    self.callbackTab = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a error:(NSError **)outError {
    return [self parserFromGrammar:g assembler:a preassembler:nil error:outError];
}


- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a preassembler:(id)pa error:(NSError **)outError {
    PKParser *result = nil;
    
    @try {
        self.assembler = a;
        self.preassembler = pa;
        
        PKNodeBase *rootNode = (PKNodeBase *)[self ASTFromGrammar:g error:outError];
        
        NSLog(@"rootNode %@", rootNode);

        PKTokenizer *t = [self tokenizerFromGrammarSettings];
        PKParser *start = [self parserFromAST:rootNode];
        
        NSLog(@"start %@", start);

        self.assembler = nil;
        self.callbackTab = nil;
        self.productionTab = nil;
        
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


- (PKAST *)ASTFromGrammar:(NSString *)g error:(NSError **)outError {
    self.callbackTab = [NSMutableDictionary dictionary];
    self.productionTab = [NSMutableDictionary dictionary];

    PKTokenizer *t = [self tokenizerForParsingGrammar];
    t.string = g;
    
    _grammarParser.startParser.tokenizer = t;
    [_grammarParser.startParser parse:g error:outError];
    
    NSLog(@"%@", _productionTab);
    
    PKAST *rootNode = [_productionTab objectForKey:@"@start"];
    return rootNode;
}


#pragma mark -
#pragma mark Private

- (PKTokenizer *)tokenizerForParsingGrammar {
    PKTokenizer *t = [PKTokenizer tokenizer];
    
    t.whitespaceState.reportsWhitespaceTokens = YES;
    
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
    
    return t;
}


- (PKTokenizer *)tokenizerFromGrammarSettings {
    // TODO
    return [PKTokenizer tokenizer];
}


- (PKParser *)parserFromAST:(PKNodeBase *)rootNode {
    PKNodeVisitor *v = [[[PKNodeVisitor alloc] init] autorelease];
    
    v.assembler = _assembler;
    v.preassembler = _preassembler;

    PKNodeType nodeType = rootNode.type;
    switch (nodeType) {
        case PKNodeTypeVariable:
            [v visitVariable:(PKNodeVariable *)rootNode];
            break;
        case PKNodeTypeConstant:
            [v visitConstant:(PKNodeConstant *)rootNode];
            break;
        case PKNodeTypeDelimited:
            [v visitDelimited:(PKNodeDelimited *)rootNode];
            break;
        case PKNodeTypePattern:
            [v visitPattern:(PKNodePattern *)rootNode];
            break;
        case PKNodeTypeComposite:
            [v visitComposite:(PKNodeComposite *)rootNode];
            break;
        case PKNodeTypeCollection:
            [v visitCollection:(PKNodeCollection *)rootNode];
            break;
        case PKNodeTypeOptional:
            [v visitOptional:(PKNodeOptional *)rootNode];
            break;
        case PKNodeTypeMultiple:
            [v visitMultiple:(PKNodeMultiple *)rootNode];
            break;
        default:
            NSAssert1(0, @"unknown nodeType %d", nodeType);
            break;
    }
    
    PKParser *p = v.rootParser;
    return p;
}


#pragma mark -
#pragma mark Assembler Helpers

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


#pragma mark -
#pragma mark Assembler Callbacks

- (void)parser:(PKParser *)p didMatchDeclaration:(PKAssembly *)a {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *tok = [a pop];
    NSString *prodName = tok.stringValue;
    
    PKAST *prodNode = [_productionTab objectForKey:prodName];
    if (!prodNode) {
        prodNode = [PKNodeVariable ASTWithToken:tok];
        [_productionTab setObject:prodNode forKey:prodName];
    }
    
    [a push:prodNode];
}


- (void)parser:(PKParser *)p didMatchVariable:(PKAssembly *)a {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);

    PKToken *tok = [a pop];
    NSString *prodName = tok.stringValue;

    PKAST *prodNode = [_productionTab objectForKey:prodName];
    if (!prodNode) {
        prodNode = [PKNodeVariable ASTWithToken:tok];
        [_productionTab setObject:prodNode forKey:prodName];
    }
    [a push:prodNode];
}


- (void)parser:(PKParser *)p didMatchConstant:(PKAssembly *)a {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);

    PKToken *tok = [a pop];

    PKAST *parserNode = [PKNodeConstant ASTWithToken:tok];
    [a push:parserNode];
}


- (void)parser:(PKParser *)p didMatchOr:(PKAssembly *)a {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);

    PKAST *second = [a pop];
    PKToken *tok = [a pop]; // pop '|'
    PKAST *first = [a pop];
    
    NSAssert(tok.isSymbol, @"");
    NSAssert([first isKindOfClass:[PKAST class]], @"");
    NSAssert([second isKindOfClass:[PKAST class]], @"");

    PKAST *altNode = [PKNodeCollection ASTWithToken:tok];
    [altNode addChild:first];
    [altNode addChild:second];
    
    [a push:altNode];
}


- (void)parser:(PKParser *)p didMatchStatement:(PKAssembly *)a {
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSArray *children = [a objectsAbove:_equals];
    [a pop]; // '='
    
    PKAST *parent = [a pop];
    NSAssert([parent isKindOfClass:[PKAST class]], @"");

    for (PKAST *child in [children reverseObjectEnumerator]) {
        NSAssert([child isKindOfClass:[PKAST class]], @"");
        [parent addChild:child];
    }
    
    [a push:parent];
}


- (void)parser:(PKParser *)p didMatchCallback:(PKAssembly *)a {
    PKToken *selNameTok2 = [a pop];
    PKToken *selNameTok1 = [a pop];
    PKNodeVariable *node = [a pop];
    
    NSAssert([selNameTok1 isKindOfClass:[PKToken class]], @"");
    NSAssert([selNameTok2 isKindOfClass:[PKToken class]], @"");
    NSAssert(selNameTok1.isWord, @"");
    NSAssert(selNameTok2.isWord, @"");
    
    NSAssert([node isKindOfClass:[PKNodeVariable class]], @"");
    
    NSString *selName = [NSString stringWithFormat:@"%@:%@:", selNameTok1.stringValue, selNameTok2.stringValue];
    node.callbackName = selName;
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchExpression:(PKAssembly *)a {
}


- (void)parser:(PKParser *)p didMatchSubExpr:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);

    NSArray *objs = [a objectsAbove:_paren];
    NSAssert([objs count], @"");
    [a pop]; // pop '('
    
    if ([objs count] > 1) {
        PKAST *seqNode = [PKNodeCollection ASTWithToken:_seqToken];
        for (PKAST *child in [objs reverseObjectEnumerator]) {
            NSAssert([child isKindOfClass:[PKAST class]], @"");
            [seqNode addChild:child];
        }
        [a push:seqNode];
    } else if ([objs count]) {
        [a push:[objs objectAtIndex:0]];
    }
}


- (void)parser:(PKParser *)p didMatchDifference:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKAST *minus = [a pop];
    PKToken *tok = [a pop]; // '-'
    PKAST *sub = [a pop];
    
    NSAssert(tok.isSymbol, @"");
    NSAssert([minus isKindOfClass:[PKAST class]], @"");
    NSAssert([sub isKindOfClass:[PKAST class]], @"");
    
//    PKAST *diffNode = [PKNodeDifference ASTWithToken:tok];
    PKAST *diffNode = [PKNodeComposite ASTWithToken:tok];
    [diffNode addChild:sub];
    [diffNode addChild:minus];
    
    [a push:diffNode];
}


- (void)parser:(PKParser *)p didMatchIntersection:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKAST *predicate = [a pop];
    PKToken *tok = [a pop]; // '&'
    PKAST *sub = [a pop];
    
    NSAssert(tok.isSymbol, @"");
    NSAssert([predicate isKindOfClass:[PKAST class]], @"");
    NSAssert([sub isKindOfClass:[PKAST class]], @"");
    
    PKAST *intNode = [PKNodeCollection ASTWithToken:tok];
    [intNode addChild:sub];
    [intNode addChild:predicate];
    
    [a push:intNode];
}


- (void)parser:(PKParser *)p didMatchPatternOptions:(PKAssembly *)a {
    PKToken *tok = [a pop];
    NSAssert(tok.isWord, @"");
    
    NSString *s = tok.stringValue;
    NSAssert([s length] > 0, @"");
    
    PKPatternOptions opts = PKPatternOptionsNone;
    if (NSNotFound != [s rangeOfString:@"i"].location) {
        opts |= PKPatternOptionsIgnoreCase;
    }
    if (NSNotFound != [s rangeOfString:@"m"].location) {
        opts |= PKPatternOptionsMultiline;
    }
    if (NSNotFound != [s rangeOfString:@"x"].location) {
        opts |= PKPatternOptionsComments;
    }
    if (NSNotFound != [s rangeOfString:@"s"].location) {
        opts |= PKPatternOptionsDotAll;
    }
    if (NSNotFound != [s rangeOfString:@"w"].location) {
        opts |= PKPatternOptionsUnicodeWordBoundaries;
    }
    
    [a push:[NSNumber numberWithInteger:opts]];
}


- (void)parser:(PKParser *)p didMatchPattern:(PKAssembly *)a {
    id obj = [a pop]; // opts (as Number*) or DelimitedString('/', '/')
    
    PKPatternOptions opts = PKPatternOptionsNone;
    if ([obj isKindOfClass:[NSNumber class]]) {
        opts = [obj unsignedIntValue];
        obj = [a pop];
    }
    
    NSAssert([obj isMemberOfClass:[PKToken class]], @"");
    PKToken *tok = (PKToken *)obj;
    NSAssert(tok.isDelimitedString, @"");
    
    NSString *s = tok.stringValue;
    NSAssert([s length] > 2, @"");
    
    NSAssert([s hasPrefix:@"/"], @"");
    NSAssert([s hasSuffix:@"/"], @"");
    
    NSString *re = [s stringByTrimmingQuotes];
    
    PKNodePattern *patNode = (PKNodePattern *)[PKNodePattern ASTWithToken:tok];
    patNode.string = re;
    patNode.options = opts;
    
    [a push:patNode];
}


- (void)parser:(PKParser *)p didMatchDiscard:(PKAssembly *)a {
    PKNodeBase *node = [a pop];
    NSAssert([node isKindOfClass:[PKNodeBase class]], @"");

    node.discard = YES;
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchLiteral:(PKAssembly *)a {
    PKToken *tok = [a pop];

    PKAST *litNode = [PKNodeConstant ASTWithToken:tok];
    [a push:litNode];
}


- (void)parser:(PKParser *)p didMatchDelimitedString:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    NSArray *toks = [a objectsAbove:_paren];
    [a pop]; // discard '(' fence

    PKNodeDelimited *delimNode = (PKNodeDelimited *)[PKNodeDelimited ASTWithToken:_delimToken];

    NSAssert([toks count] > 0 && [toks count] < 3, @"");
    NSString *start = [[[toks lastObject] stringValue] stringByTrimmingQuotes];
    NSString *end = nil;
    if ([toks count] > 1) {
        end = [[[toks objectAtIndex:0] stringValue] stringByTrimmingQuotes];
    }
    
    delimNode.startMarker = start;
    delimNode.endMarker = end;
    
    [a push:delimNode];
}


- (void)parser:(PKParser *)p didMatchNum:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *tok = [a pop];
    [a push:[NSNumber numberWithFloat:tok.floatValue]];
}


- (void)parser:(PKParser *)p didMatchStar:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *tok = [a pop]; // '*'
    NSAssert(tok.isSymbol, @"");
    PKAST *sub = [a pop];
    NSAssert([sub isKindOfClass:[PKAST class]], @"");
    
    //    PKAST *starNode = [PKNodeRepetition ASTWithToken:tok];
    PKAST *starNode = [PKNodeComposite ASTWithToken:tok];
    [starNode addChild:sub];

    [a push:starNode];
}


- (void)parser:(PKParser *)p didMatchPlus:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *tok = [a pop]; // '+'
    NSAssert(tok.isSymbol, @"");
    PKAST *sub = [a pop];
    NSAssert([sub isKindOfClass:[PKAST class]], @"");
    
    PKAST *plusNode = [PKNodeCollection ASTWithToken:tok];
    [plusNode addChild:sub];
    
    [a push:plusNode];
}


- (void)parser:(PKParser *)p didMatchQuestion:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKToken *tok = [a pop]; // '?'
    NSAssert(tok.isSymbol, @"");
    PKAST *sub = [a pop];
    NSAssert([sub isKindOfClass:[PKAST class]], @"");
    
    PKAST *qNode = [PKNodeCollection ASTWithToken:tok];
    [qNode addChild:sub];
    
    [a push:qNode];
}


- (void)parser:(PKParser *)p didMatchNegation:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    
    PKAST *sub = [a pop];
    NSAssert([sub isKindOfClass:[PKAST class]], @"");
    PKToken *tok = [a pop]; // '~'
    NSAssert(tok.isSymbol, @"");

    //    PKAST *negNode = [PKNodeNegation ASTWithToken:tok];
    PKAST *negNode = [PKNodeComposite ASTWithToken:tok];
    [negNode addChild:sub];
    
    [a push:negNode];
}


- (void)parser:(PKParser *)p didMatchPhraseCardinality:(PKAssembly *)a {
    NSRange r = [[a pop] rangeValue];
    PKToken *tok = [a pop]; // '{' tok

    PKNodeBase *childNode = [a pop];
    PKNodeCardinal *node = (PKNodeCardinal *)[PKNodeCardinal ASTWithToken:tok];
    
    [node addChild:childNode];
    
    NSInteger start = r.location;
    NSInteger end = r.length;

    node.rangeStart = start;
    node.rangeEnd = end;
    
    [a push:node];
}


- (void)parser:(PKParser *)p didMatchCardinality:(PKAssembly *)a {
    NSArray *toks = [a objectsAbove:self.curly];
    
    NSAssert([toks count] > 0, @"");
    
    PKToken *tok = [toks lastObject];
    PKFloat start = tok.floatValue;
    PKFloat end = start;
    if ([toks count] > 1) {
        tok = [toks objectAtIndex:0];
        end = tok.floatValue;
    }
    
    NSAssert(start <= end, @"");
    
    NSRange r = NSMakeRange(start, end);
    [a push:[NSValue valueWithRange:r]];
}


- (void)parser:(PKParser *)p didMatchAnd:(PKAssembly *)a {
}

@end
