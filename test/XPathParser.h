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

@class XPathAssembler;
@class PKAssembly;

@interface XPathParser : PKSequence {
    XPathAssembler *xpathAssembler;
    PKCollectionParser *locationPath;
    PKCollectionParser *absoluteLocationPath;
    PKCollectionParser *relativeLocationPath;
    PKCollectionParser *step;
    PKCollectionParser *axisSpecifier;
    PKCollectionParser *axisName;
    PKCollectionParser *nodeTest;
    PKCollectionParser *predicate;
    PKCollectionParser *predicateExpr;
    PKCollectionParser *abbreviatedAbsoluteLocationPath;
    PKCollectionParser *abbreviatedRelativeLocationPath;
    PKCollectionParser *abbreviatedStep;
    PKCollectionParser *abbreviatedAxisSpecifier;
    PKCollectionParser *expr;
    PKCollectionParser *primaryExpr;
    PKCollectionParser *functionCall;
    PKCollectionParser *argument;
    PKCollectionParser *unionExpr;
    PKCollectionParser *pathExpr;
    PKCollectionParser *filterExpr;
    PKCollectionParser *orExpr;
    PKCollectionParser *andExpr;
    PKCollectionParser *equalityExpr;
    PKCollectionParser *relationalExpr;
    PKCollectionParser *additiveExpr;
    PKCollectionParser *multiplicativeExpr;
    PKCollectionParser *unaryExpr;
    PKCollectionParser *exprToken;
    PKParser *literal;
    PKParser *number;
    PKCollectionParser *operator;
    PKCollectionParser *operatorName;
    PKParser *multiplyOperator;
    PKParser *functionName;
    PKCollectionParser *variableReference;
    PKCollectionParser *nameTest;
    PKCollectionParser *nodeType;
    PKCollectionParser *QName;
}
- (id)parse:(NSString *)s;
- (PKAssembly *)assemblyWithString:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *locationPath;
@property (nonatomic, retain) PKCollectionParser *absoluteLocationPath;
@property (nonatomic, retain) PKCollectionParser *relativeLocationPath;
@property (nonatomic, retain) PKCollectionParser *step;
@property (nonatomic, retain) PKCollectionParser *axisSpecifier;
@property (nonatomic, retain) PKCollectionParser *axisName;
@property (nonatomic, retain) PKCollectionParser *nodeTest;
@property (nonatomic, retain) PKCollectionParser *predicate;
@property (nonatomic, retain) PKCollectionParser *predicateExpr;
@property (nonatomic, retain) PKCollectionParser *abbreviatedAbsoluteLocationPath;
@property (nonatomic, retain) PKCollectionParser *abbreviatedRelativeLocationPath;
@property (nonatomic, retain) PKCollectionParser *abbreviatedStep;
@property (nonatomic, retain) PKCollectionParser *abbreviatedAxisSpecifier;
@property (nonatomic, retain) PKCollectionParser *expr;
@property (nonatomic, retain) PKCollectionParser *primaryExpr;
@property (nonatomic, retain) PKCollectionParser *functionCall;
@property (nonatomic, retain) PKCollectionParser *argument;
@property (nonatomic, retain) PKCollectionParser *unionExpr;
@property (nonatomic, retain) PKCollectionParser *pathExpr;
@property (nonatomic, retain) PKCollectionParser *filterExpr;
@property (nonatomic, retain) PKCollectionParser *orExpr;
@property (nonatomic, retain) PKCollectionParser *andExpr;
@property (nonatomic, retain) PKCollectionParser *equalityExpr;
@property (nonatomic, retain) PKCollectionParser *relationalExpr;
@property (nonatomic, retain) PKCollectionParser *additiveExpr;
@property (nonatomic, retain) PKCollectionParser *multiplicativeExpr;
@property (nonatomic, retain) PKCollectionParser *unaryExpr;
@property (nonatomic, retain) PKCollectionParser *exprToken;
@property (nonatomic, retain) PKParser *literal;
@property (nonatomic, retain) PKParser *number;
@property (nonatomic, retain) PKCollectionParser *operator;
@property (nonatomic, retain) PKCollectionParser *operatorName;
@property (nonatomic, retain) PKParser *multiplyOperator;
@property (nonatomic, retain) PKParser *functionName;
@property (nonatomic, retain) PKCollectionParser *variableReference;
@property (nonatomic, retain) PKCollectionParser *nameTest;
@property (nonatomic, retain) PKCollectionParser *nodeType;
@property (nonatomic, retain) PKCollectionParser *QName;
@end
