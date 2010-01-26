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

@interface EBNFParser : PKRepetition {
    PKCollectionParser *statementParser;
    PKCollectionParser *exprOrAssignmentParser;
    PKCollectionParser *assignmentParser;
    PKCollectionParser *declarationParser;
    PKCollectionParser *variableParser;
    PKCollectionParser *expressionParser;
    PKCollectionParser *termParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *factorParser;
    PKCollectionParser *nextFactorParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *phraseStarParser;
    PKCollectionParser *phraseQuestionParser;
    PKCollectionParser *phrasePlusParser;
    PKCollectionParser *atomicValueParser;
}
- (id)parse:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *statementParser;
@property (nonatomic, retain) PKCollectionParser *exprOrAssignmentParser;
@property (nonatomic, retain) PKCollectionParser *assignmentParser;
@property (nonatomic, retain) PKCollectionParser *declarationParser;
@property (nonatomic, retain) PKCollectionParser *variableParser;
@property (nonatomic, retain) PKCollectionParser *expressionParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *factorParser;
@property (nonatomic, retain) PKCollectionParser *nextFactorParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *phraseStarParser;
@property (nonatomic, retain) PKCollectionParser *phraseQuestionParser;
@property (nonatomic, retain) PKCollectionParser *phrasePlusParser;
@property (nonatomic, retain) PKCollectionParser *atomicValueParser;
@end
