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

@interface TDNSPredicateBuilder : NSObject {
    NSString *defaultAttr;
    NSString *defaultRelation;
    NSString *defaultValue;
    PKToken *nonReservedWordFence;
    PKCollectionParser *exprParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *termParser;
    PKCollectionParser *andPrimaryExprParser;
    PKCollectionParser *primaryExprParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *negatedPredicateParser;
    PKCollectionParser *predicateParser;
    PKCollectionParser *completePredicateParser;
    PKCollectionParser *attrValuePredicateParser;
    PKCollectionParser *attrPredicateParser;
	PKCollectionParser *valuePredicateParser;
    PKCollectionParser *attrParser;
    PKCollectionParser *tagParser;
    PKCollectionParser *relationParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *boolParser;
    PKParser *trueParser;
    PKParser *falseParser;
    PKCollectionParser *stringParser;
    PKParser *quotedStringParser;
    PKCollectionParser *unquotedStringParser;
    PKCollectionParser *reservedWordParser;
    PKParser *nonReservedWordParser;
    PKPattern *reservedWordPattern;
    PKParser *numberParser;

}
- (NSPredicate *)buildFrom:(NSString *)s;

@property (nonatomic, copy) NSString *defaultAttr;
@property (nonatomic, copy) NSString *defaultRelation;
@property (nonatomic, copy) NSString *defaultValue;

@property (nonatomic, retain) PKCollectionParser *exprParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *andPrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *primaryExprParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *negatedPredicateParser;
@property (nonatomic, retain) PKCollectionParser *predicateParser;
@property (nonatomic, retain) PKCollectionParser *completePredicateParser;
@property (nonatomic, retain) PKCollectionParser *attrValuePredicateParser;
@property (nonatomic, retain) PKCollectionParser *attrPredicateParser;
@property (nonatomic, retain) PKCollectionParser *valuePredicateParser;
@property (nonatomic, retain) PKCollectionParser *attrParser;
@property (nonatomic, retain) PKCollectionParser *tagParser;
@property (nonatomic, retain) PKCollectionParser *relationParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *boolParser;
@property (nonatomic, retain) PKParser *trueParser;
@property (nonatomic, retain) PKParser *falseParser;
@property (nonatomic, retain) PKCollectionParser *stringParser;
@property (nonatomic, retain) PKParser *quotedStringParser;
@property (nonatomic, retain) PKCollectionParser *unquotedStringParser;
@property (nonatomic, retain) PKCollectionParser *reservedWordParser;
@property (nonatomic, retain) PKParser *nonReservedWordParser;
@property (nonatomic, retain) PKPattern *reservedWordPattern;
@property (nonatomic, retain) PKParser *numberParser;
@end
