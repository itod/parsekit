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

#import <Cocoa/Cocoa.h>

@class TDSourceCodeTextView;

@interface DemoBaseViewController : NSViewController

- (IBAction)parse:(id)sender;

- (void)done;
- (void)renderGutters;

@property (retain) IBOutlet TDSourceCodeTextView *grammarTextView;
@property (retain) IBOutlet TDSourceCodeTextView *inputTextView;

@property (retain) NSString *grammarString;
@property (retain) NSString *inputString;
@property BOOL busy;
@end
