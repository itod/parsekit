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

#import <ParseKit/PKCollectionParser.h>
#import <ParseKit/PKCompositeParser.h>

@interface PKGrammarParser : NSObject {
    id assembler;
    PKCompositeParser *parser;
    PKCollectionParser *statementParser;
    PKCollectionParser *tokenizerDirectiveParser;
    PKCollectionParser *declParser;
    PKCollectionParser *productionParser;
    PKParser *varProductionParser;
    PKCollectionParser *startProductionParser;
    PKCollectionParser *exprParser;
    PKCollectionParser *termParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *nextFactorParser;
    PKCollectionParser *phraseParser;
    PKParser *actionParser;
    PKParser *semanticPredicateParser;
    PKCollectionParser *phraseStarParser;
    PKCollectionParser *phrasePlusParser;
    PKCollectionParser *phraseQuestionParser;
    PKCollectionParser *primaryExprParser;
    PKCollectionParser *negatedPrimaryExprParser;
    PKCollectionParser *barePrimaryExprParser;
    PKCollectionParser *predicateParser;
    PKCollectionParser *intersectionParser;
    PKCollectionParser *differenceParser;
    PKCollectionParser *atomicValueParser;
    PKCollectionParser *parserParser;
    PKCollectionParser *discardParser;
    PKCollectionParser *patternParser;
    PKCollectionParser *delimitedStringParser;
    PKParser *literalParser;
    PKParser *variableParser;
    PKParser *constantParser;
    PKCollectionParser *specificConstantParser;
}

- (id)initWithAssembler:(id)a;

@property (nonatomic, retain) PKCompositeParser *parser;
@property (nonatomic, retain) PKCollectionParser *statementParser;
@property (nonatomic, retain) PKCollectionParser *tokenizerDirectiveParser;
@property (nonatomic, retain) PKCollectionParser *declParser;
@property (nonatomic, retain) PKCollectionParser *productionParser;
@property (nonatomic, retain) PKParser *varProductionParser;
@property (nonatomic, retain) PKCollectionParser *startProductionParser;
@property (nonatomic, retain) PKCollectionParser *exprParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *factorParser;
@property (nonatomic, retain) PKCollectionParser *nextFactorParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKParser *actionParser;
@property (nonatomic, retain) PKParser *semanticPredicateParser;
@property (nonatomic, retain) PKCollectionParser *phraseStarParser;
@property (nonatomic, retain) PKCollectionParser *phrasePlusParser;
@property (nonatomic, retain) PKCollectionParser *phraseQuestionParser;
@property (nonatomic, retain) PKCollectionParser *primaryExprParser;
@property (nonatomic, retain) PKCollectionParser *negatedPrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *barePrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *predicateParser;
@property (nonatomic, retain) PKCollectionParser *intersectionParser;
@property (nonatomic, retain) PKCollectionParser *differenceParser;
@property (nonatomic, retain) PKCollectionParser *atomicValueParser;
@property (nonatomic, retain) PKCollectionParser *parserParser;
@property (nonatomic, retain) PKCollectionParser *discardParser;
@property (nonatomic, retain) PKCollectionParser *patternParser;
@property (nonatomic, retain) PKCollectionParser *delimitedStringParser;
@property (nonatomic, retain) PKParser *literalParser;
@property (nonatomic, retain) PKParser *variableParser;
@property (nonatomic, retain) PKParser *constantParser;
@property (nonatomic, retain) PKCollectionParser *specificConstantParser;
@end
