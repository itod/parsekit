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

#import "TDXmlNameTest.h"
#import "TDXmlNameState.h"
#import "TDXmlNmtokenState.h"
#import "TDXmlToken.h"

@implementation TDXmlNameTest
//
//- (void)test {
//    NSString *s = @"_foob?ar _foobar 2baz";
//    PKTokenizer *t = [PKTokenizer tokenizerWithString:s];
//    
//    //Name       ::=       (Letter | '_' | ':') (NameChar)*
//    TDXmlNameState *nameState = [[[TDXmlNameState alloc] init] autorelease];
//    
//    [t setTokenizerState:nameState from: '_' to: '_'];
//    [t setTokenizerState:nameState from: ':' to: ':'];
//    [t setTokenizerState:nameState from: 'a' to: 'z'];
//    [t setTokenizerState:nameState from: 'A' to: 'Z'];
//    [t setTokenizerState:nameState from:0xc0 to:0xff];
//    
//    TDXmlNmtokenState *nmtokenState = [[[TDXmlNmtokenState alloc] init] autorelease];
//    [t setTokenizerState:nmtokenState from: '0' to: '9'];
//    
//    TDXmlToken *tok = nil;
//    
//    // _foob
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isName);
//
//    // '?'
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isSymbol);
//    
//    // ar
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isName);
//    
//    // _foobar
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isName);
//    
//    // 2baz
//    tok = (TDXmlToken *)[t nextToken];
//    TDNotNil(tok);
//    TDTrue(tok.isNmtoken);
//    NSLog(@"tok: %@", tok);
//    
//}

@end
