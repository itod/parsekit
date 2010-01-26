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

#import <Foundation/Foundation.h>

@class PKToken;

@interface JSONAssembler : NSObject {
    NSMutableAttributedString *displayString;
    id defaultAttrs;
    id objectAttrs;
    id arrayAttrs;
    id propertyNameAttrs;
    id valueAttrs;
    id constantAttrs;
    
    PKToken *comma;
    PKToken *curly;
    PKToken *bracket;
}
@property (retain) NSMutableAttributedString *displayString;
@property (retain) id defaultAttrs;
@property (retain) id objectAttrs;
@property (retain) id arrayAttrs;
@property (retain) id propertyNameAttrs;
@property (retain) id valueAttrs;
@property (retain) id constantAttrs;
@property (retain) PKToken *comma;
@property (retain) PKToken *curly;
@property (retain) PKToken *bracket;
@end
