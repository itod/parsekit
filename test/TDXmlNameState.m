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

#import "TDXmlNameState.h"
#import "PKTokenizer.h"
#import "PKReader.h"
#import "TDXmlToken.h"

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@end

@interface TDXmlNameState ()
+ (BOOL)isNameChar:(PKUniChar)c;
+ (BOOL)isValidStartSymbolChar:(PKUniChar)c;
+ (BOOL)isValidNonStartSymbolChar:(PKUniChar)c;
@end

//Name       ::=       (Letter | '_' | ':') (NameChar)*
@implementation TDXmlNameState

//- (BOOL)isWhitespace:(PKUniChar)c {
//    return (' ' == c || '\n' == c || '\r' == c || '\t' == c);
//}


//    NameChar       ::=        Letter | Digit | '.' | '-' | '_' | ':' | CombiningChar | Extender
+ (BOOL)isNameChar:(PKUniChar)c {
    if (isalpha(c)) {
        return YES;
    } else if (isdigit(c)) {
        return YES;
    } else if ([[self class] isValidNonStartSymbolChar:c]) {
        return YES;
    }
    // TODO CombiningChar & Extender
    return NO;
}


+ (BOOL)isValidStartSymbolChar:(PKUniChar)c {
    return ('_' == c || ':' == c);
}


+ (BOOL)isValidNonStartSymbolChar:(PKUniChar)c {
    return ('_' == c || '.' == c || '-' == c || ':' == c);
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    [self resetWithReader:r];
    
    NSInteger c = cin;
    do {
        [self append:c];
        c = [r read];
    } while ([[self class] isNameChar:c]);
    
    if (PKEOF != c) {
        [r unread];
    }

    if ([[self bufferedString] length] == 1 && [[self class] isValidStartSymbolChar:cin]) {
        return [t.symbolState nextTokenFromReader:r startingWith:cin tokenizer:t];
    } else {
//        return [[[TDXmlToken alloc] initWithTokenType:TDTT_NAME 
//                                           stringValue:[[stringbuf copy] autorelease] 
//                                            floatValue:0.0] autorelease];
        return nil;
    }
}

@end
