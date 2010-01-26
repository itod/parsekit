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

@interface TDPlistParser : PKAlternation {
    PKCollectionParser *dictParser;
    PKCollectionParser *keyValuePairParser;
    PKCollectionParser *arrayParser;
    PKCollectionParser *commaValueParser;
    PKCollectionParser *keyParser;
    PKCollectionParser *valueParser;
    PKCollectionParser *stringParser;
    PKParser *numParser;
    PKParser *nullParser;
    PKToken *curly;
    PKToken *paren;
}
- (id)parse:(NSString *)s;

@property (nonatomic, retain) PKCollectionParser *dictParser;
@property (nonatomic, retain) PKCollectionParser *keyValuePairParser;
@property (nonatomic, retain) PKCollectionParser *arrayParser;
@property (nonatomic, retain) PKCollectionParser *commaValueParser;
@property (nonatomic, retain) PKCollectionParser *keyParser;
@property (nonatomic, retain) PKCollectionParser *valueParser;
@property (nonatomic, retain) PKCollectionParser *stringParser;
@property (nonatomic, retain) PKParser *numParser;
@property (nonatomic, retain) PKParser *nullParser;
@end
