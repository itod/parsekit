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

@property (retain) PKCollectionParser *locationPath;
@property (retain) PKCollectionParser *absoluteLocationPath;
@property (retain) PKCollectionParser *relativeLocationPath;
@property (retain) PKCollectionParser *step;
@property (retain) PKCollectionParser *axisSpecifier;
@property (retain) PKCollectionParser *axisName;
@property (retain) PKCollectionParser *nodeTest;
@property (retain) PKCollectionParser *predicate;
@property (retain) PKCollectionParser *predicateExpr;
@property (retain) PKCollectionParser *abbreviatedAbsoluteLocationPath;
@property (retain) PKCollectionParser *abbreviatedRelativeLocationPath;
@property (retain) PKCollectionParser *abbreviatedStep;
@property (retain) PKCollectionParser *abbreviatedAxisSpecifier;
@property (retain) PKCollectionParser *expr;
@property (retain) PKCollectionParser *primaryExpr;
@property (retain) PKCollectionParser *functionCall;
@property (retain) PKCollectionParser *argument;
@property (retain) PKCollectionParser *unionExpr;
@property (retain) PKCollectionParser *pathExpr;
@property (retain) PKCollectionParser *filterExpr;
@property (retain) PKCollectionParser *orExpr;
@property (retain) PKCollectionParser *andExpr;
@property (retain) PKCollectionParser *equalityExpr;
@property (retain) PKCollectionParser *relationalExpr;
@property (retain) PKCollectionParser *additiveExpr;
@property (retain) PKCollectionParser *multiplicativeExpr;
@property (retain) PKCollectionParser *unaryExpr;
@property (retain) PKCollectionParser *exprToken;
@property (retain) PKParser *literal;
@property (retain) PKParser *number;
@property (retain) PKCollectionParser *operator;
@property (retain) PKCollectionParser *operatorName;
@property (retain) PKParser *multiplyOperator;
@property (retain) PKParser *functionName;
@property (retain) PKCollectionParser *variableReference;
@property (retain) PKCollectionParser *nameTest;
@property (retain) PKCollectionParser *nodeType;
@property (retain) PKCollectionParser *QName;
@end
