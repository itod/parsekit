//
//  PEGParser.m
//  PEGKit
//
//  Created by Todd Ditchendorf on 3/26/13.
//
//

#import <PEGKit/PEGParser.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKWhitespaceState.h>
#import <PEGKit/PEGTokenAssembly.h>
#import <PEGKit/PEGRecognitionException.h>
#import "NSArray+ParseKitAdditions.h"

#define FAILED -1
#define NUM_DISPLAY_OBJS 6

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]

@interface NSObject ()
- (void)parser:(PEGParser *)p didFailToMatch:(PKAssembly *)a;
@end

@interface PEGTokenAssembly ()
- (void)consume:(PKToken *)tok;
@property (nonatomic, readwrite, retain) NSMutableArray *stack;
@end

@interface PEGParser ()
@property (nonatomic, assign) id assembler; // weak ref
@property (nonatomic, retain) PEGRecognitionException *exception;
@property (nonatomic, retain) NSMutableArray *lookahead;
@property (nonatomic, retain) NSMutableArray *markers;
@property (nonatomic, assign) NSInteger p;
@property (nonatomic, assign, readonly) BOOL isSpeculating;
@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
@property (nonatomic, retain) NSCountedSet *resyncSet;
@property (nonatomic, retain) NSString *startRuleName;
@property (nonatomic, retain) NSString *statementTerminator;
@property (nonatomic, retain) NSString *singleLineCommentMarker;
@property (nonatomic, retain) NSString *blockStartMarker;
@property (nonatomic, retain) NSString *blockEndMarker;
@property (nonatomic, retain) NSString *braces;

- (NSInteger)tokenKindForString:(NSString *)str;
- (NSString *)stringForTokenKind:(NSInteger)tokenKind;
- (BOOL)lookahead:(NSInteger)x predicts:(NSInteger)tokenKind;
- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName;

- (void)discard;

// error recovery
- (void)pushFollow:(NSInteger)tokenKind;
- (void)popFollow:(NSInteger)tokenKind;
- (BOOL)resync;

// convenience
- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;
- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;

// backtracking
- (NSInteger)mark;
- (void)unmark;
- (void)seek:(NSInteger)index;
- (void)sync:(NSInteger)i;
- (void)fill:(NSInteger)n;

// memoization
- (BOOL)alreadyParsedRule:(NSMutableDictionary *)memoization;
- (void)memoize:(NSMutableDictionary *)memoization atIndex:(NSInteger)startTokenIndex failed:(BOOL)failed;
- (void)clearMemo;
@end

@implementation PEGParser

- (id)init {
    self = [super init];
    if (self) {
        self.enableActions = YES;
        
        // create a single exception for reuse in control flow
        self.exception = [[[PEGRecognitionException alloc] init] autorelease];
        
        self.tokenKindTab = [NSMutableDictionary dictionary];

        self.tokenKindNameTab = [NSMutableArray array];
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_INVALID] = @"";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_NUMBER] = @"Number";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_QUOTEDSTRING] = @"Quoted String";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_SYMBOL] = @"Symbol";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_WORD] = @"Word";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_LOWERCASEWORD] = @"Lowercase Word";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_UPPERCASEWORD] = @"Uppercase Word";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_WHITESPACE] = @"Whitespace";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_COMMENT] = @"Comment";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_DELIMITEDSTRING] = @"Delimited String";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_URL] = @"URL";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_EMAIL] = @"Email";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_TWITTER] = @"Twitter";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_HASHTAG] = @"Hashtag";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_EMPTY] = @"Empty";
        self.tokenKindNameTab[TOKEN_KIND_BUILTIN_ANY] = @"Any";
}
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.assembly = nil;
    self.assembler = nil;
    self.exception = nil;
    self.lookahead = nil;
    self.markers = nil;
    self.tokenKindTab = nil;
    self.tokenKindNameTab = nil;
    self.resyncSet = nil;
    self.startRuleName = nil;
    self.statementTerminator = nil;
    self.singleLineCommentMarker = nil;
    self.blockStartMarker = nil;
    self.blockEndMarker = nil;
    self.braces = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark PKTokenizerDelegate

- (NSInteger)tokenizer:(PKTokenizer *)t tokenKindForStringValue:(NSString *)str {
    NSParameterAssert([str length]);
    return [self tokenKindForString:str];
}


- (NSInteger)tokenKindForString:(NSString *)str {
    NSInteger tokenKind = TOKEN_KIND_BUILTIN_INVALID;
    
    id obj = self.tokenKindTab[str];
    if (obj) {
        tokenKind = [obj integerValue];
    }
    
    return tokenKind;
}


- (NSString *)stringForTokenKind:(NSInteger)tokenKind {
    NSString *str = nil;
    
    if (TOKEN_KIND_BUILTIN_EOF == tokenKind) {
        str = [[PKToken EOFToken] stringValue];
    } else {
        str = self.tokenKindNameTab[tokenKind];
    }

    return str;
}


- (id)parseStream:(NSInputStream *)input assembler:(id)a error:(NSError **)outError {
    NSParameterAssert(input);
    
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    
    PKTokenizer *t = _tokenizer;
    
    if (t) {
        t.stream = input;
    } else {
        t = [PKTokenizer tokenizerWithStream:input];
    }

    id result = [self parseWithTokenizer:t assembler:a error:outError];
    
    [input close];
    [input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    return result;
}


- (id)parseString:(NSString *)input assembler:(id)a error:(NSError **)outError {
    NSParameterAssert(input);

    PKTokenizer *t = _tokenizer;
    
    if (t) {
        t.string = input;
    } else {
        t = [PKTokenizer tokenizerWithString:input];
    }
    
    id result = [self parseWithTokenizer:t assembler:a error:outError];
    return result;
}


- (id)parseWithTokenizer:(PKTokenizer *)t assembler:(id)a error:(NSError **)outError {
    id result = nil;
    
    // setup
    self.assembler = a;
    self.tokenizer = t;
    self.assembly = [PEGTokenAssembly assemblyWithTokenizer:_tokenizer];
    
    self.tokenizer.delegate = self;
    
    if (_silentlyConsumesWhitespace) {
        _tokenizer.whitespaceState.reportsWhitespaceTokens = YES;
        _assembly.preservesWhitespaceTokens = YES;
    }
    
    // setup speculation
    self.p = 0;
    self.lookahead = [NSMutableArray array];
    self.markers = [NSMutableArray array];

    if (_enableAutomaticErrorRecovery) {
        self.resyncSet = [NSCountedSet set];
    }
    
    [self clearMemo];
    
    @try {

        @autoreleasepool {
            // parse
            [self start];
            
            //NSLog(@"%@", _assembly);
            
            // get result
            if (_assembly.target) {
                result = _assembly.target;
            } else {
                result = _assembly;
            }

            [result retain]; // +1
        }
        [result autorelease]; // -1

    }
    @catch (PEGRecognitionException *rex) {
        NSString *domain = @"PKParseException";
        NSString *reason = [rex currentReason];
        NSLog(@"%@", reason);

        if (outError) {
            *outError = [self errorWithDomain:domain reason:reason];
        } else {
            [NSException raise:domain format:reason, nil];
        }
    }
    @catch (NSException *ex) {
        NSString *domain = NSGenericException;
        NSString *reason = [ex reason];
        NSLog(@"%@", reason);
        
        if (outError) {
            *outError = [self errorWithDomain:domain reason:reason];
        } else {
            [NSException raise:domain format:reason, nil];
        }
    }
    @finally {
        //self.tokenizer.delegate = nil;
        //self.tokenizer = nil;
        self.assembler = nil;
        self.assembly = nil;
        self.lookahead = nil;
        self.markers = nil;
        self.resyncSet = nil;
    }
    
    return result;
}


- (NSError *)errorWithDomain:(NSString *)domain reason:(NSString *)reason {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    // get reason
    if ([reason length]) [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    
    // convert to NSError
    NSError *err = [NSError errorWithDomain:domain code:47 userInfo:[[userInfo copy] autorelease]];
    return err;
}


- (void)match:(NSInteger)tokenKind discard:(BOOL)discard {
    NSParameterAssert(tokenKind != TOKEN_KIND_BUILTIN_INVALID);
    NSAssert(_lookahead, @"");
    
    // always match empty without consuming
    if (TOKEN_KIND_BUILTIN_EMPTY == tokenKind) return;

    PKToken *lt = LT(1); // NSLog(@"%@", lt);
    
    BOOL matches = lt.tokenKind == tokenKind || (TOKEN_KIND_BUILTIN_ANY == tokenKind && PKTokenTypeEOF != lt.tokenType);

    if (matches) {
        if (TOKEN_KIND_BUILTIN_EOF != tokenKind) {
            [self consume:lt];
            if (discard) [self discard];
        }
    } else {
        NSString *msg = [NSString stringWithFormat:@"Expected : %@", [self stringForTokenKind:tokenKind]];
        [self raise:msg];
    }
}


- (void)consume:(PKToken *)tok {
    if (!self.isSpeculating) {
        [_assembly consume:tok];
        //NSLog(@"%@", _assembly);
    }

    self.p++;
    
    // have we hit end of buffer when not backtracking?
    if (_p == [_lookahead count] && !self.isSpeculating) {
        // if so, it's an opp to start filling at index 0 again
        self.p = 0;
        [_lookahead removeAllObjects]; // size goes to 0, but retains memory on heap
        [self clearMemo]; // clear all rule_memo dictionaries
    }
    
    [self sync:1];
}


- (void)discard {
    if (self.isSpeculating) return;
    
    NSAssert(![_assembly isStackEmpty], @"");
    [_assembly pop];
}


- (void)fireAssemblerSelector:(SEL)sel {
    if (self.isSpeculating) return;
    
    if (_assembler && [_assembler respondsToSelector:sel]) {
        [_assembler performSelector:sel withObject:self withObject:_assembly];
    }
}


- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName {
    if (self.isSpeculating) return;
    
    if (_assembler && [_assembler respondsToSelector:sel]) {
        [_assembler performSelector:sel withObject:self withObject:ruleName];
    }
}


- (PKToken *)LT:(NSInteger)i {
    PKToken *tok = nil;
    
    for (;;) {
        [self sync:i];

        NSUInteger idx = _p + i - 1;
        NSAssert(idx < [_lookahead count], @"");
        
        tok = _lookahead[idx];
        if (_silentlyConsumesWhitespace && tok.isWhitespace) {
            [self consume:tok];
        } else {
            break;
        }
    }
    
    return tok;
}


- (NSInteger)LA:(NSInteger)i {
    return [LT(i) tokenKind];
}


- (double)LF:(NSInteger)i {
    return [LT(i) floatValue];
}


- (NSString *)LS:(NSInteger)i {
    return [LT(i) stringValue];
}


- (NSInteger)mark {
    [_markers addObject:@(_p)];
    return _p;
}


- (void)unmark {
    NSInteger marker = [[_markers lastObject] integerValue];
    [_markers removeLastObject];
    
    [self seek:marker];
}


- (void)seek:(NSInteger)index {
    self.p = index;
}


- (BOOL)isSpeculating {
    return [_markers count] > 0;
}


- (void)sync:(NSInteger)i {
    NSInteger lastNeededIndex = _p + i - 1;
    NSInteger lastFullIndex = [_lookahead count] - 1;
    
    if (lastNeededIndex > lastFullIndex) { // out of tokens ?
        NSInteger n = lastNeededIndex - lastFullIndex; // get n tokens
        [self fill:n];
    }
}


- (void)fill:(NSInteger)n {
    for (NSInteger i = 0; i <= n; ++i) { // <= ?? fetches an extra lookahead tok
        PKToken *tok = [_tokenizer nextToken];

        // set token kind
        if (TOKEN_KIND_BUILTIN_INVALID == tok.tokenKind) {
            tok.tokenKind = [self tokenKindForToken:tok];
        }
        
        NSAssert(tok, @"");
        //NSLog(@"-nextToken: %@", [tok debugDescription]);

        [_lookahead addObject:tok];
    }
}


- (NSInteger)tokenKindForToken:(PKToken *)tok {
    NSString *key = tok.stringValue;
    
    NSInteger x = tok.tokenKind;
    
    if (TOKEN_KIND_BUILTIN_INVALID == x) {
        x = [self tokenKindForString:key];
    
        if (TOKEN_KIND_BUILTIN_INVALID == x) {
            x = tok.tokenType;
        }
    }
    
    return x;
}


- (void)raiseFormat:(NSString *)fmt, ... {
    va_list vargs;
    va_start(vargs, fmt);
    
    NSString *str = [[[NSString alloc] initWithFormat:fmt arguments:vargs] autorelease];

    va_end(vargs);

    _exception.currentReason = str;
    
    //NSLog(@"%@", str);

    // reuse
    @throw _exception;
}


- (void)raise:(NSString *)msg {
    NSString *fmt = nil;
    
#if defined(__LP64__)
    fmt = @"\n\n%@\nLine : %lu\nNear : %@\nFound : %@\n\n";
#else
    fmt = @"\n\n%@\nLine : %u\nNear : %@\nFound : %@\n\n";
#endif
    
    PKToken *lt = LT(1);
    
    NSUInteger lineNum = lt.lineNumber;
    //NSAssert(NSNotFound != lineNum, @"");

    NSMutableString *after = [NSMutableString string];
    NSString *delim = _silentlyConsumesWhitespace ? @"" : @" ";
    
    for (PKToken *tok in [_lookahead reverseObjectEnumerator]) {
        if (tok.lineNumber < lineNum - 1) break;
        if (tok.lineNumber == lineNum) {
            [after insertString:[NSString stringWithFormat:@"%@%@", tok.stringValue, delim] atIndex:0];
        }
    }
    
    NSString *found = lt ? lt.stringValue : @"-nothing-";
    [self raiseFormat:fmt, msg, lineNum, after, found];
}


- (void)pushFollow:(NSInteger)tokenKind {
    NSParameterAssert(TOKEN_KIND_BUILTIN_INVALID != tokenKind);
    if (!_enableAutomaticErrorRecovery) return;
    
    NSAssert(_resyncSet, @"");
    [_resyncSet addObject:@(tokenKind)];
}


- (void)popFollow:(NSInteger)tokenKind {
    NSParameterAssert(TOKEN_KIND_BUILTIN_INVALID != tokenKind);
    if (!_enableAutomaticErrorRecovery) return;

    NSAssert(_resyncSet, @"");
    [_resyncSet removeObject:@(tokenKind)];
}


- (BOOL)resync {
    BOOL result = NO;

    if (_enableAutomaticErrorRecovery) {
        for (;;) {
            //NSLog(@"\n\nLT 1: '%@'\n%@\nla: %@\nresyncSet: %@", LT(1), self.assembly, _lookahead, _resyncSet);
            
            PKToken *lt = LT(1);
            
            NSAssert([_resyncSet count], @"");
            result = [_resyncSet containsObject:@(lt.tokenKind)];

            if (result) {
                [self fireAssemblerSelector:@selector(parser:didFailToMatch:)];
                break;
            }
            
            if (lt.isEOF) break;

            [self consume:lt];
        }
    }
    
    return result;
}


- (BOOL)predicts:(NSInteger)firstTokenKind, ... {
    NSParameterAssert(firstTokenKind != TOKEN_KIND_BUILTIN_INVALID);
    
    NSInteger la = LA(1);
    
    if ([self lookahead:la predicts:firstTokenKind]) {
        return YES;
    }
    
    BOOL result = NO;
    
    va_list vargs;
    va_start(vargs, firstTokenKind);
    
    int nextTokenKind;
    while ((nextTokenKind = va_arg(vargs, int))) {
        if ([self lookahead:la predicts:nextTokenKind]) {
            result = YES;
            break;
        }
    }
    
    va_end(vargs);
    
    return result;
}


- (BOOL)lookahead:(NSInteger)la predicts:(NSInteger)tokenKind {
    BOOL result = NO;
    
    if (TOKEN_KIND_BUILTIN_ANY == tokenKind && la != TOKEN_KIND_BUILTIN_EOF) {
        result = YES;
    } else if (la == tokenKind) {
        result = YES;
    }
    
    return result;
}


- (BOOL)speculate:(PKSSpeculateBlock)block {
    NSParameterAssert(block);
    
    BOOL success = YES;
    [self mark];
    
    @try {
        if (block) block();
    }
    @catch (PEGRecognitionException *ex) {
        success = NO;
    }
    
    [self unmark];
    return success;
}


- (id)execute:(PKSActionBlock)block {
    NSParameterAssert(block);
    if (self.isSpeculating || !_enableActions) return nil;

    id result = nil;
    if (block) result = block();
    return result;
}


- (void)tryAndRecover:(NSInteger)tokenKind block:(PKSResyncBlock)block completion:(PKSResyncBlock)completion {
    NSParameterAssert(block);
    NSParameterAssert(completion);
    
    [self pushFollow:tokenKind];
    @try {
        block();
    }
    @catch (PEGRecognitionException *ex) {
        if ([self resync]) {
            completion();
        } else {
            @throw ex;
        }
    }
    @finally {
        [self popFollow:tokenKind];
    }
}


- (BOOL)test:(PKSPredicateBlock)block {
    NSParameterAssert(block);
    
    BOOL result = YES;
    if (block) result = block();
    return result;
}


- (void)testAndThrow:(PKSPredicateBlock)block {
    NSParameterAssert(block);
    
    if (![self test:block]) {
        [self raise:@"Predicate Failed"];
    }
}


- (void)parseRule:(SEL)ruleSelector withMemo:(NSMutableDictionary *)memoization {
    BOOL failed = NO;
    NSInteger startTokenIndex = self.p;
    if (self.isSpeculating && [self alreadyParsedRule:memoization]) return;
                                
    @try { [self performSelector:ruleSelector]; }
    @catch (PEGRecognitionException *ex) { failed = YES; @throw ex; }
    @finally {
        if (self.isSpeculating) [self memoize:memoization atIndex:startTokenIndex failed:failed];
    }
}


- (BOOL)alreadyParsedRule:(NSMutableDictionary *)memoization {
    
    id idxKey = @(self.p);
    NSNumber *memoObj = memoization[idxKey];
    if (!memoObj) return NO;
    
    NSInteger memo = [memoObj integerValue];
    if (FAILED == memo) {
        [self raiseFormat:@"already failed prior attempt at start token index %@", idxKey];
    }
    
    [self seek:memo];
    return YES;
}


- (void)memoize:(NSMutableDictionary *)memoization atIndex:(NSInteger)startTokenIndex failed:(BOOL)failed {
    id idxKey = @(startTokenIndex);
    
    NSInteger stopTokenIdex = failed ? FAILED : self.p;
    id idxVal = @(stopTokenIdex);

    memoization[idxKey] = idxVal;
}


- (void)clearMemo {
    
}


- (BOOL)popBool {
    id obj = [self.assembly pop];
    return [obj boolValue];
}


- (NSInteger)popInteger {
    id obj = [self.assembly pop];
    return [obj integerValue];
}


- (double)popDouble {
    id obj = [self.assembly pop];
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [obj doubleValue];
    } else {
        return [(PKToken *)obj floatValue];
    }
}


- (PKToken *)popToken {
    PKToken *tok = [self.assembly pop];
    NSAssert([tok isKindOfClass:[PKToken class]], @"");
    return tok;
}


- (NSString *)popString {
    id obj = [self.assembly pop];
    if ([obj respondsToSelector:@selector(stringValue)]) {
        return [obj stringValue];
    } else {
        return [obj description];
    }
}


- (void)pushBool:(BOOL)yn {
    [self.assembly push:(id)(yn ? kCFBooleanTrue : kCFBooleanFalse)];
}


- (void)pushInteger:(NSInteger)i {
    [self.assembly push:@(i)];
}


- (void)pushDouble:(double)d {
    [self.assembly push:@(d)];
}


- (void)start {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
}


- (void)matchEOF:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_EOF discard:discard];
}


- (void)matchAny:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_ANY discard:discard];
}


- (void)matchEmpty:(BOOL)discard {
    NSParameterAssert(!discard);
}


- (void)matchWord:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_WORD discard:discard];
}


- (void)matchNumber:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_NUMBER discard:discard];
}


- (void)matchSymbol:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_SYMBOL discard:discard];
}


- (void)matchComment:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_COMMENT discard:discard];
}


- (void)matchWhitespace:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_WHITESPACE discard:discard];
}


- (void)matchQuotedString:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_QUOTEDSTRING discard:discard];
}


- (void)matchDelimitedString:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_DELIMITEDSTRING discard:discard];
}


- (void)matchURL:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_URL discard:discard];
}


- (void)matchEmail:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_EMAIL discard:discard];
}

@end
