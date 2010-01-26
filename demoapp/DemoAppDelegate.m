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

#import "DemoAppDelegate.h"
#import "DemoTokensViewController.h"
#import "DemoTreesViewController.h"

@implementation DemoAppDelegate

- (void)dealloc {
    self.tokensViewController = nil;
    self.treesViewController = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    self.tokensViewController = [[[DemoTokensViewController alloc] init] autorelease];
    self.treesViewController = [[[DemoTreesViewController alloc] init] autorelease];
    
    NSTabViewItem *item = [tabView tabViewItemAtIndex:0];
    [item setView:[tokensViewController view]];

    item = [tabView tabViewItemAtIndex:1];
    [item setView:[treesViewController view]];
}

@synthesize tokensViewController;
@synthesize treesViewController;
@end
