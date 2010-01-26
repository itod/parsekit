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

@protocol TDPredicateEvaluatorDelegate <NSObject>
- (id)valueForAttributeKey:(NSString *)key;
- (CGFloat)floatForAttributeKey:(NSString *)key;
- (BOOL)boolForAttributeKey:(NSString *)key;
@end

@interface TDPredicateEvaluator : NSObject {
    id <TDPredicateEvaluatorDelegate>delegate;
    PKCollectionParser *exprParser;
    PKCollectionParser *orTermParser;
    PKCollectionParser *termParser;
    PKCollectionParser *andPrimaryExprParser;
    PKCollectionParser *primaryExprParser;
    PKCollectionParser *phraseParser;
    PKCollectionParser *negatedPredicateParser;
    PKCollectionParser *predicateParser;
    PKCollectionParser *attrParser;
    PKCollectionParser *tagParser;
    PKCollectionParser *eqStringPredicateParser;
    PKCollectionParser *eqNumberPredicateParser;
    PKCollectionParser *eqBoolPredicateParser;
    PKCollectionParser *neStringPredicateParser;
    PKCollectionParser *neNumberPredicateParser;
    PKCollectionParser *neBoolPredicateParser;
    PKCollectionParser *gtPredicateParser;
    PKCollectionParser *gteqPredicateParser;
    PKCollectionParser *ltPredicateParser;
    PKCollectionParser *lteqPredicateParser;
    PKCollectionParser *beginswithPredicateParser;
    PKCollectionParser *containsPredicateParser;
    PKCollectionParser *endswithPredicateParser;
    PKCollectionParser *matchesPredicateParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *boolParser;
    PKParser *trueParser;
    PKParser *falseParser;
    PKParser *stringParser;
    PKParser *numberParser;
}
- (id)initWithDelegate:(id <TDPredicateEvaluatorDelegate>)d;
- (BOOL)evaluate:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *exprParser;
@property (nonatomic, retain) PKCollectionParser *orTermParser;
@property (nonatomic, retain) PKCollectionParser *termParser;
@property (nonatomic, retain) PKCollectionParser *andPrimaryExprParser;
@property (nonatomic, retain) PKCollectionParser *primaryExprParser;
@property (nonatomic, retain) PKCollectionParser *phraseParser;
@property (nonatomic, retain) PKCollectionParser *negatedPredicateParser;
@property (nonatomic, retain) PKCollectionParser *predicateParser;
@property (nonatomic, retain) PKCollectionParser *attrParser;
@property (nonatomic, retain) PKCollectionParser *tagParser;
@property (nonatomic, retain) PKCollectionParser *eqStringPredicateParser;
@property (nonatomic, retain) PKCollectionParser *eqNumberPredicateParser;
@property (nonatomic, retain) PKCollectionParser *eqBoolPredicateParser;
@property (nonatomic, retain) PKCollectionParser *neStringPredicateParser;
@property (nonatomic, retain) PKCollectionParser *neNumberPredicateParser;
@property (nonatomic, retain) PKCollectionParser *neBoolPredicateParser;
@property (nonatomic, retain) PKCollectionParser *gtPredicateParser;
@property (nonatomic, retain) PKCollectionParser *gteqPredicateParser;
@property (nonatomic, retain) PKCollectionParser *ltPredicateParser;
@property (nonatomic, retain) PKCollectionParser *lteqPredicateParser;
@property (nonatomic, retain) PKCollectionParser *beginswithPredicateParser;
@property (nonatomic, retain) PKCollectionParser *containsPredicateParser;
@property (nonatomic, retain) PKCollectionParser *endswithPredicateParser;
@property (nonatomic, retain) PKCollectionParser *matchesPredicateParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *boolParser;
@property (nonatomic, retain) PKParser *trueParser;
@property (nonatomic, retain) PKParser *falseParser;
@property (nonatomic, retain) PKParser *stringParser;
@property (nonatomic, retain) PKParser *numberParser;
@end
