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

#import "TDNumberStateTest.h"

@implementation TDNumberStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
    r = [[PKReader alloc] init];
    numberState = t.numberState;
}


- (void)tearDown {
    [t release];
    [r release];
}


- (void)testHexSuffix0 {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    
    s = @"0h";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0h", tok.stringValue);
}


- (void)testHexSuffix00 {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    
    s = @"00h";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"00h", tok.stringValue);
}


- (void)testHexSuffix10 {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    
    s = @"10h";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)16.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"10h", tok.stringValue);
}


- (void)testHexSuffix1a {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    
    s = @"1ah";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)26.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1ah", tok.stringValue);
}


- (void)testHexSuffixFF {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"ffh";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)255.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"ffh", tok.stringValue);
}


- (void)testHexSuffixFF_FF {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"ff ffh";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"ff", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)255.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"ffh", tok.stringValue);
}


- (void)testHexSuffix12FF {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"12 ffh";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)12.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"12", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)255.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"ffh", tok.stringValue);
}


- (void)testHexSuffix12FFhF {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"12 ffhf";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)12.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"12", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"ffhf", tok.stringValue);
}


- (void)testHexSuffix0000_FFFF {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t.numberState addGroupingSeparator:'_' forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"0000_ffffh";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0xFFFF, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0000_ffffh", tok.stringValue);
}


- (void)testHexSuffixAndPrefix0000_FFFF {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t.numberState addGroupingSeparator:'_' forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"$0000_ffff 0000_ffffh";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0xFFFF, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$0000_ffff", tok.stringValue);

    tok = [t nextToken];
    TDEquals((PKFloat)0xFFFF, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0000_ffffh", tok.stringValue);
}


- (void)testHexSuffixFFFoobar {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"ffh foobar";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)255.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"ffh", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"foobar", tok.stringValue);
}


- (void)testHexSuffixFFHot {
    [t.numberState addSuffix:@"h" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'a' to:'f'];
    [t setTokenizerState:t.numberState from:'A' to:'F'];
    t.numberState.fallbackState = t.wordState;
    
    s = @"ffh hot";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)255.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"ffh", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"hot", tok.stringValue);
}


- (void)testBinSuffix0 {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    
    s = @"0b";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0b", tok.stringValue);
}


- (void)testBinSuffix00 {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    
    s = @"00b";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"00b", tok.stringValue);
}


- (void)testBinSuffix1 {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    
    s = @"1b";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1b", tok.stringValue);
}


- (void)testBinSuffix1001 {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    
    s = @"1001b";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)9.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1001b", tok.stringValue);
}


- (void)testBinSuffix1001_0000 {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    [t.numberState addGroupingSeparator:'_' forRadix:2.0];
    
    s = @"1001_0000b";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0x90, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1001_0000b", tok.stringValue);
}


- (void)testBinSuffix1001_0000Foobar {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    [t.numberState addGroupingSeparator:'_' forRadix:2.0];
    
    s = @"1001_0000b foobar";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0x90, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1001_0000b", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"foobar", tok.stringValue);
}


- (void)testBinSuffix1001_0000Bat {
    [t.numberState addSuffix:@"b" forRadix:2.0];
    [t.numberState addGroupingSeparator:'_' forRadix:2.0];
    
    s = @"1001_0000b bat";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0x90, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1001_0000b", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"bat", tok.stringValue);
}


- (void)testHexSymbolPrefix0 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$0";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$0", tok.stringValue);
}


- (void)testHexSymbolPrefix0_10 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$0 10";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$0", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)10.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"10", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testHexSymbolFakePrefix {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"$", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testHexSymbolFakePrefix2 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$ 1";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"$", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testHexSymbolFakePrefix3 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$ ff";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEqualObjects(@"$", tok.stringValue);
    
    tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@"ff", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testHexSymbolPrefix_10 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"10";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)10.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"10", tok.stringValue);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testHexSymbolPrefix1 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$1";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$1", tok.stringValue);
}


- (void)testHexSymbolPrefixA {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$A";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)10.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$A", tok.stringValue);
}


- (void)testHexSymbolPrefixa {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$a";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)10.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$a", tok.stringValue);
}


- (void)testHexSymbolPrefix10 {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$10";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)16.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$10", tok.stringValue);
}


- (void)testHexSymbolPrefixFF {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$FF";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)255.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$FF", tok.stringValue);
}


- (void)testHexSymbolPrefixFFFF_FFFF {
    [t.numberState addPrefix:@"$" forRadix:16.0];
    [t.numberState addGroupingSeparator:'_' forRadix:16.0];
    [t setTokenizerState:t.numberState from:'$' to:'$'];
    
    s = @"$FFFF_FFFF";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0xFFFFFFFF, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"$FFFF_FFFF", tok.stringValue);
}


- (void)testBinSymbolPrefix0 {
    [t.numberState addPrefix:@"%" forRadix:2.0];
    [t setTokenizerState:t.numberState from:'%' to:'%'];
    
    s = @"%0";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"%0", tok.stringValue);
}


- (void)testBinSymbolPrefix1 {
    [t.numberState addPrefix:@"%" forRadix:2.0];
    [t setTokenizerState:t.numberState from:'%' to:'%'];
    
    s = @"%1";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"%1", tok.stringValue);
}


- (void)testBinSymbolPrefix10 {
    [t.numberState addPrefix:@"%" forRadix:2.0];
    [t setTokenizerState:t.numberState from:'%' to:'%'];
    
    s = @"%10";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"%10", tok.stringValue);
}


- (void)testBinSymbolPrefix0010 {
    [t.numberState addPrefix:@"%" forRadix:2.0];
    [t setTokenizerState:t.numberState from:'%' to:'%'];
    
    s = @"%0010";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)2.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"%0010", tok.stringValue);
}


- (void)testBinSymbolPrefix0001_0001 {
    [t.numberState addPrefix:@"%" forRadix:2.0];
    [t.numberState addGroupingSeparator:'_' forRadix:2.0];
    [t setTokenizerState:t.numberState from:'%' to:'%'];
    
    s = @"%0001_0001";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)17.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"%0001_0001", tok.stringValue);
}


- (void)testWordFallbackState {
    s = @".";
    t.string = s;
    t.numberState.fallbackState = t.wordState;
    [t.wordState setWordChars:YES from:'.' to:'.'];
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isWord);
    TDEqualObjects(@".", tok.stringValue);
}


- (void)testSymbolFallbackState {
    s = @".";
    t.string = s;
    t.numberState.fallbackState = t.symbolState;

    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEqualObjects(@".", tok.stringValue);
}


- (void)testDefaultFallbackState {
    s = @".";
    t.string = s;
    
    PKToken *tok = [t nextToken];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isSymbol);
    TDEqualObjects(@".", tok.stringValue);
}


- (void)testSingleDigit {
    s = @"3";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)3.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"3", tok.stringValue);
}


- (void)testDoubleDigit {
    s = @"47";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)47.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"47", tok.stringValue);
}


- (void)testTripleDigit {
    s = @"654";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)654.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"654", tok.stringValue);
}


- (void)testSingleDigitPositive {
    s = @"+3";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)3.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+3", tok.stringValue);
}


- (void)testDoubleDigitPositive {
    s = @"+22";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)22.0, tok.floatValue);
    TDTrue(tok.isNumber);
}


- (void)testDoubleDigitPositiveSpace {
    s = @"+22 ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)22.0, tok.floatValue);
    TDTrue(tok.isNumber);
}


- (void)testMultipleDots {
    s = @"1.1.1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1.1", tok.stringValue);

    tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@".1", tok.stringValue);
}


- (void)testOneDot {
    s = @"1.";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1", tok.stringValue);
}


- (void)testCustomOneDot {
    s = @"1.";
    t.string = s;
    r.string = s;
    numberState.allowsTrailingDecimalSeparator = YES;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1.", tok.stringValue);    
}


- (void)testOneDotZero {
    s = @"1.0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1.0", tok.stringValue);
}


- (void)testPositiveOneDot {
    s = @"+1.";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+1", tok.stringValue);
}


- (void)testPositiveOneDotCustom {
    s = @"+1.";
    t.string = s;
    r.string = s;
    numberState.allowsTrailingDecimalSeparator = YES;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+1.", tok.stringValue);
}


- (void)testPositiveOneDotZero {
    s = @"+1.0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+1.0", tok.stringValue);
}


- (void)testPositiveOneDotZeroSpace {
    s = @"+1.0 ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+1.0", tok.stringValue);
}


- (void)testNegativeOneDot {
    s = @"-1.";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-1", tok.stringValue);
}


- (void)testNegativeOneDotCustom {
    s = @"-1.";
    t.string = s;
    r.string = s;
    numberState.allowsTrailingDecimalSeparator = YES;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-1.", tok.stringValue);
}


- (void)testNegativeOneDotSpace {
    s = @"-1. ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-1", tok.stringValue);
}


- (void)testNegativeOneDotZero {
    s = @"-1.0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-1.0", tok.stringValue);
}


- (void)testNegativeOneDotZeroSpace {
    s = @"-1.0 ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-1.0", tok.stringValue);
}


- (void)testOneDotOne {
    s = @"1.1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1.1", tok.stringValue);
}


- (void)testZeroDotOne {
    s = @"0.1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0.1", tok.stringValue);
}


- (void)testDotOne {
    s = @".1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@".1", tok.stringValue);
}


- (void)testDotZero {
    s = @".0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@".0", tok.stringValue);
}


- (void)testNegativeDotZero {
    s = @"-.0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.0", tok.stringValue);
}


- (void)testPositiveDotZero {
    s = @"+.0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+.0", tok.stringValue);
}


- (void)testPositiveDotOne {
    s = @"+.1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+.1", tok.stringValue);
}


- (void)testNegativeDotOne {
    s = @"-.1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.1, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.1", tok.stringValue);
}


- (void)testNegativeDotOneOne {
    s = @"-.11";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.11, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.11", tok.stringValue);
}


- (void)testNegativeDotOneOneOne {
    s = @"-.111";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.111, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.111", tok.stringValue);
}


- (void)testNegativeDotOneOneOneZero {
    s = @"-.1110";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.111, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.1110", tok.stringValue);
}


- (void)testNegativeDotOneOneOneZeroZero {
    s = @"-.11100";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.111, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.11100", tok.stringValue);
}


- (void)testNegativeDotOneOneOneZeroSpace {
    s = @"-.1110 ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.111, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-.1110", tok.stringValue);
}


- (void)testZeroDotThreeSixtyFive {
    s = @"0.365";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.365, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0.365", tok.stringValue);
}


- (void)testNegativeZeroDotThreeSixtyFive {
    s = @"-0.365";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.365, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-0.365", tok.stringValue);
}


- (void)testNegativeTwentyFourDotThreeSixtyFive {
    s = @"-24.365";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-24.365, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-24.365", tok.stringValue);
}


- (void)testTwentyFourDotThreeSixtyFive {
    s = @"24.365";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)24.365, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"24.365", tok.stringValue);
}


- (void)testZero {
    s = @"0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"0", tok.stringValue);
}


- (void)testNegativeOne {
    s = @"-1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-1", tok.stringValue);
}


- (void)testOne {
    s = @"1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"1", tok.stringValue);
}


- (void)testPositiveOne {
    s = @"+1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)1.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+1", tok.stringValue);
}


- (void)testPositiveZero {
    s = @"+0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+0", tok.stringValue);
}


- (void)testPositiveZeroSpace {
    s = @"+0 ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"+0", tok.stringValue);
}


- (void)testNegativeZero {
    s = @"-0";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)-0.0, tok.floatValue);
    TDTrue(tok.isNumber);
    TDEqualObjects(@"-0", tok.stringValue);
}


- (void)testNull {
    s = @"NULL";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testNil {
    s = @"nil";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testEmptyString {
    s = @"";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testDot {
    s = @".";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testDotSpace {
    s = @". ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testDotSpaceOne {
    s = @". 1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testPlus {
    s = @"+";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testPlusSpace {
    s = @"+ ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testPlusSpaceOne {
    s = @"+ 1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testMinus {
    s = @"-";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testMinusSpace {
    s = @"- ";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testMinusSpaceOne {
    s = @"- 1";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
    TDEquals((PKFloat)0.0, tok.floatValue);
    TDFalse(tok.isNumber);
}


- (void)testInitSig {
    s = @"- (id)init {";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"-");
    TDEquals((PKFloat)0.0, tok.floatValue);
}


- (void)testInitSig2 {
    s = @"-(id)init {";
    t.string = s;
    r.string = s;
    PKToken *tok = [numberState nextTokenFromReader:r startingWith:[r read] tokenizer:t];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"-");
    TDEquals((PKFloat)0.0, tok.floatValue);
}


- (void)testParenStuff {
    s = @"-(ab+5)";
    t.string = s;
    r.string = s;
    PKToken *tok = [t nextToken];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"-");
    TDEquals((PKFloat)0.0, tok.floatValue);
    
    tok = [t nextToken];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals((PKFloat)0.0, tok.floatValue);
}


- (void)testMultiCharPlusPlusAndExplicitlyPositiveNumbers {
    s = @"++ +1 -2 + 3++";
    [t.symbolState add:@"++"];
    [t setTokenizerState:t.numberState from:'+' to:'+'];
    
    t.string = s;
    r.string = s;
    PKToken *tok = nil;
    
    tok = [t nextToken];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"++");
    TDEquals((PKFloat)0.0, tok.floatValue);
    
    tok = [t nextToken];
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"+1");
    TDEquals((PKFloat)1.0, tok.floatValue);

    tok = [t nextToken];
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"-2");
    TDEquals((PKFloat)-2.0, tok.floatValue);

    tok = [t nextToken];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"+");
    TDEquals((PKFloat)0.0, tok.floatValue);
    
    tok = [t nextToken];
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"3");
    TDEquals((PKFloat)3.0, tok.floatValue);

    tok = [t nextToken];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"++");
    TDEquals((PKFloat)0.0, tok.floatValue);
}


- (void)testAllowsFloatingPoint {
    s = @"3.14";
    t.string = s;
    r.string = s;
    t.numberState.allowsFloatingPoint = NO;
    PKToken *tok = [t nextToken];

	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"3");
    TDEquals((PKFloat)3.0, tok.floatValue);
    
    tok = [t nextToken];
	TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEquals((PKFloat)0.0, tok.floatValue);

    tok = [t nextToken];
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"14");
    TDEquals((PKFloat)14.0, tok.floatValue);
}


- (void)testCommaDecimalSeparator {
    s = @"3,14";
    t.string = s;
    r.string = s;
    t.numberState.decimalSeparator = ',';
    [t.numberState addGroupingSeparator:'.' forRadix:10.0];

    PKToken *tok = [t nextToken];
    
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"3,14");
    TDEquals((PKFloat)3.14, tok.floatValue);
}


- (void)testSlashDecimalSeparator {
    s = @"3/14";
    t.string = s;
    r.string = s;
    t.numberState.decimalSeparator = '/';
    PKToken *tok = [t nextToken];
    
    TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"3/14");
    TDEquals((PKFloat)3.14, tok.floatValue);
}


- (void)testDefaultGroupingSeparator {
    s = @"2,001";
    t.string = s;
    r.string = s;
    [t.numberState addGroupingSeparator:',' forRadix:10.0];
    PKToken *tok = [t nextToken];
    
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"2,001");
    TDEquals((PKFloat)2001.0, tok.floatValue);
}


- (void)testDefaultGroupingSeparator2 {
    s = @"2,001 5,000,000 5,000.000";
    t.string = s;
    r.string = s;
    [t.numberState addGroupingSeparator:',' forRadix:10.0];
    PKToken *tok = [t nextToken];
    
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"2,001");
    TDEquals((PKFloat)2001.0, tok.floatValue);

    tok = [t nextToken];
    
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"5,000,000");
    TDEquals((PKFloat)5000000.0, tok.floatValue);

    tok = [t nextToken];
    
	TDTrue(tok.isNumber);
    TDEqualObjects(tok.stringValue, @"5,000.000");
    TDEquals((PKFloat)5000.0, tok.floatValue);
}

@end
