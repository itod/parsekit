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

#import <ParseKit/ParseKit.h>

@interface TDRegularParser : PKSequence {
    PKCollectionParser *expressionParser;
    PKCollectionParser *termParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *nextFactorParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *phraseStarParser;
    PKCollectionParser *phrasePlusParser;
    PKCollectionParser *phraseQuestionParser;
    PKCollectionParser *letterOrDigitParser;
}
+ (id)parserFromGrammar:(NSString *)s;

@property (retain) PKCollectionParser *expressionParser;
@property (retain) PKCollectionParser *termParser;
@property (retain) PKCollectionParser *orTermParser;
@property (retain) PKCollectionParser *factorParser;
@property (retain) PKCollectionParser *nextFactorParser;
@property (retain) PKCollectionParser *phraseParser;
@property (retain) PKCollectionParser *phraseStarParser;
@property (retain) PKCollectionParser *phrasePlusParser;
@property (retain) PKCollectionParser *phraseQuestionParser;
@property (retain) PKCollectionParser *letterOrDigitParser;
@end
