//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#if PEGKIT
#import <PEGKit/PKSymbolState.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKSymbolRootNode.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKTokenizer.h>
#else
#import <ParseKit/PKSymbolState.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#endif

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@end

@interface PKSymbolState ()
- (PKToken *)symbolTokenWith:(PKUniChar)cin;
- (PKToken *)symbolTokenWithSymbol:(NSString *)s;

@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) NSMutableSet *addedSymbols;
@end

@implementation PKSymbolState {
    BOOL *_prevented;
}

- (id)init {
    self = [super init];
    if (self) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.addedSymbols = [NSMutableSet set];
        _prevented = (void *)calloc(128, sizeof(BOOL));
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.addedSymbols = nil;
    if (_prevented) {
        free(_prevented);
    }
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    NSString *symbol = [_rootNode nextSymbol:r startingWith:cin];
    NSUInteger len = [symbol length];

    while (len > 1) {
        if ([_addedSymbols containsObject:symbol]) {
            return [self symbolTokenWithSymbol:symbol];
        }

        symbol = [symbol substringToIndex:[symbol length] - 1];
        len = [symbol length];
        [r unread:1];
    }
    
    if (1 == len) {
        BOOL isPrevented = NO;
        if (_prevented[cin]) {
            PKUniChar peek = [r read];
            if (peek != EOF) {
                isPrevented = YES;
                [r unread:1];
            }
        }
        
        if (!isPrevented) {
            return [self symbolTokenWith:cin];
        }
    }

    PKTokenizerState *state = [self nextTokenizerStateFor:cin tokenizer:t];
    if (!state || state == self) {
        return [self symbolTokenWith:cin];
    } else {
        return [state nextTokenFromReader:r startingWith:cin tokenizer:t];
    }
}


- (void)add:(NSString *)s {
    NSParameterAssert(s);
    [_rootNode add:s];
    [_addedSymbols addObject:s];
}


- (void)remove:(NSString *)s {
    NSParameterAssert(s);
    [_rootNode remove:s];
    [_addedSymbols removeObject:s];
}


- (void)prevent:(PKUniChar)c {
    PKAssertMainThread();
    NSParameterAssert(c > 0);
    _prevented[c] = YES;
}


- (PKToken *)symbolTokenWith:(PKUniChar)cin {
    return [self symbolTokenWithSymbol:[NSString stringWithFormat:@"%C", (unichar)cin]];
}


- (PKToken *)symbolTokenWithSymbol:(NSString *)s {
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:s floatValue:0.0];
    tok.offset = offset;
    return tok;
}

@end
