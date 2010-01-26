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

@interface TDJsonParser : PKAlternation {
    BOOL shouldAssemble;
    PKParser *stringParser;
    PKParser *numberParser;
    PKParser *nullParser;
    PKCollectionParser *booleanParser;
    PKCollectionParser *arrayParser;
    PKCollectionParser *objectParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *commaValueParser;
    PKCollectionParser *propertyParser;
    PKCollectionParser *commaPropertyParser;
    
    PKToken *curly;
    PKToken *bracket;
}

- (id)initWithIntentToAssemble:(BOOL)shouldAssemble;

- (id)parse:(NSString *)s;

@property (nonatomic, retain) PKParser *stringParser;
@property (nonatomic, retain) PKParser *numberParser;
@property (nonatomic, retain) PKParser *nullParser;
@property (nonatomic, retain) PKCollectionParser *booleanParser;
@property (nonatomic, retain) PKCollectionParser *arrayParser;
@property (nonatomic, retain) PKCollectionParser *objectParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *commaValueParser;
@property (nonatomic, retain) PKCollectionParser *propertyParser;
@property (nonatomic, retain) PKCollectionParser *commaPropertyParser;
@end