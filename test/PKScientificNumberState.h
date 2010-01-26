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

#import <ParseKit/PKNumberState.h>

/*!
    @class      PKScientificNumberState 
    @brief      A <tt>PKScientificNumberState</tt> object returns a number from a reader.
    @details    <p>This state's idea of a number expands on its superclass, allowing an 'e' followed by an integer to represent 10 to the indicated power. For example, this state will recognize <tt>1e2</tt> as equaling <tt>100</tt>.</p>
                <p>This class exists primarily to show how to introduce a new tokenizing state.</p>
*/
@interface PKScientificNumberState : PKNumberState {
    BOOL allowsScientificNotation;
    CGFloat exp;
    BOOL negativeExp;
}

@property (nonatomic) BOOL allowsScientificNotation;
@end
