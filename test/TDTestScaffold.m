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

#import "TDTestScaffold.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#define RUN_ALL_TEST_CASES 1
#define SOLO_TEST_CASE @"JavaScriptParserTest" // TDParserFactoryASTTest TDParserFactorySymbolTableTest TDParserFactoryParserTest TDParseTreeTest TDParserFactoryASTRewriteTest

@interface XCTestSuite (TDAdditions)
- (void)addSuitesForClassNames:(NSArray *)classNames;
@end

XCTestSuite *TDSoloTestSuite() {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"Solo Test Suite"];
    
    NSArray *classNames = [NSArray arrayWithObject:SOLO_TEST_CASE];
    
    [suite addSuitesForClassNames:classNames];
    return suite;
}

XCTestSuite *TDTokensTestSuite() {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"Tokens Test Suite"];
    
    NSArray *classNames = [NSArray arrayWithObjects:
                           @"TDReaderTest",
                           @"TDTokenizerTest",
                           @"TDTokenizerTest",
                           @"TDNumberStateTest",
                           @"TDQuoteStateTest",
                           @"TDWhitespaceStateTest",
                           @"TDWordStateTest",
                           @"TDSlashStateTest",
                           @"TDSymbolStateTest",
                           @"TDCommentStateTest",
                           @"TDDelimitStateTest",
                           @"TDURLStateTest",
                           @"TDEmailStateTest",
                           @"TDTwitterStateTest",
                           @"TDTokenizerStateTest",
                           @"TDTokenizerBlocksTest",
                           @"TDParserBlocksTest",
                           nil];
    
    [suite addSuitesForClassNames:classNames];
    return suite;
}

XCTestSuite *TDCharsTestSuite() {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"Chars Test Suite"];
    
    NSArray *classNames = [NSArray arrayWithObjects:
                           @"TDCharacterAssemblyTest",
                           @"TDDigitTest",
                           @"TDCharTest",
                           @"TDLetterTest",
                           @"TDSpecificCharTest",
                           nil];
    
    [suite addSuitesForClassNames:classNames];
    return suite;
}

XCTestSuite *TDParseTestSuite() {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"Parse Test Suite"];
    
    NSArray *classNames = [NSArray arrayWithObjects:
                           @"TDParserTest",
                           @"TDTokenAssemblyTest",
                           @"TDLiteralTest",
                           @"TDPatternTest",
                           @"TDRepetitionTest",
                           @"TDSequenceTest",
                           @"TDAlternationTest",
                           @"TDSymbolTest",
                           @"TDRobotCommandTest",
                           @"TDXmlParserTest",
                           @"TDJsonParserTest",
                           @"TDFastJsonParserTest",
                           @"TDRegularParserTest",
                           @"TDRegexMatcherTest",
                           @"SRGSParserTest",
                           @"EBNFParserTest",
                           @"TDPlistParserTest",
                           @"TDXmlNameTest",
                           @"XPathParserTest",
                           @"XMLReaderTest",
                           @"TDXmlTokenizerTest",
                           @"TDArithmeticParserTest",
                           @"TDScientificNumberStateTest",
                           @"TDTokenArraySourceTest",
                           @"TDDifferenceTest",
                           @"TDNegationTest",
                           nil];
    
    [suite addSuitesForClassNames:classNames];
    return suite;
}

XCTestSuite *TDParserFactoryTestSuite() {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"ParserFactory Test Suite"];
    
    NSArray *classNames = [NSArray arrayWithObjects:
                           @"TDParserFactoryTest",
                           @"TDParserFactoryTest2",
                           @"TDParserFactoryPatternTest",
                           @"TDMiniCSSAssemblerTest",
                           @"TDPredicateEvaluatorTest",
                           @"TDNSPredicateEvaluatorTest",
                           @"TDNSPredicateBuilderTest",
                           @"TDJavaScriptParserTest",
                           @"TDXMLParserTest",
                           @"XPathParserGrammarTest",
                           @"ERBTest",
                           @"TDParseTreeTest",
                           @"SAXTest",
                           nil];
    
    [suite addSuitesForClassNames:classNames];
    return suite;
}

@implementation XCTestSuite (TDAdditions)

+ (id)testSuiteForBundlePath:(NSString *)path {
    XCTestSuite *suite = nil;
    
#if RUN_ALL_TEST_CASES
    suite = [self defaultTestSuite];
#else
    suite = [self testSuiteWithName:@"My Tests"]; 
    //    [suite addTest:TDCharsTestSuite()];
    //    [suite addTest:TDTokensTestSuite()];
    //    [suite addTest:TDParseTestSuite()];
    //    [suite addTest:TDParserFactoryTestSuite()];
    [suite addTest:TDSoloTestSuite()];
#endif
    
    return suite;
}


- (void)addSuitesForClassNames:(NSArray *)classNames {
    for (NSString *className in classNames) {
        XCTestSuite *suite = [XCTestSuite testSuiteForTestCaseWithName:className];
        [self addTest:suite];
    }
}

#pragma clang diagnostic pop

@end
