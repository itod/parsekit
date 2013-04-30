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
#import "DemoASTViewController.h"

@implementation DemoAppDelegate

- (void)dealloc {
    self.tabView = nil;
    self.tokensViewController = nil;
    self.treesViewController = nil;
    self.ASTViewController = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    self.tokensViewController = [[[DemoTokensViewController alloc] init] autorelease];
    self.treesViewController = [[[DemoTreesViewController alloc] init] autorelease];
    self.ASTViewController = [[[DemoASTViewController alloc] init] autorelease];
    
    NSTabViewItem *item = [_tabView tabViewItemAtIndex:0];
    [item setView:[_tokensViewController view]];
    
    item = [_tabView tabViewItemAtIndex:1];
    [item setView:[_treesViewController view]];
    
    item = [_tabView tabViewItemAtIndex:2];
    [item setView:[_ASTViewController view]];
    
    [_tabView selectTabViewItemAtIndex:1];
}

@end
