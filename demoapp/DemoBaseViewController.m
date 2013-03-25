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

#import "DemoBaseViewController.h"
#import "TDSourceCodeTextView.h"
#import <ParseKit/ParseKit.h>

#define PKAssertMainThread() NSAssert1([NSThread isMainThread], @"%s should be called on the main thread only.", __PRETTY_FUNCTION__);
#define PKAssertNotMainThread() NSAssert1(![NSThread isMainThread], @"%s should be called on the main thread only.", __PRETTY_FUNCTION__);

@interface DemoBaseViewController ()
- (void)renderGutters;
@end

@implementation DemoBaseViewController

- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b {
    if (self = [super initWithNibName:name bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.grammarTextView = nil;
    self.inputTextView = nil;
    self.grammarString = nil;
    self.inputString = nil;
    [super dealloc];
}


- (void)awakeFromNib {    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:[[self view] window]];
}


- (void)windowDidBecomeMain:(NSNotification *)n {
    [self renderGutters];
}


- (void)renderGutters {
    [_grammarTextView renderGutter];
    [_inputTextView renderGutter];
}


- (IBAction)parse:(id)sender {
    PKAssertMainThread();
    if (self.busy || ![_inputString length] || ![_grammarString length]) {
        NSBeep();
        return;
    }
    
    self.busy = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doParse];
    });
}


- (void)doParse {
    NSAssert(0, @"");
}


- (void)done {
    PKAssertMainThread();
    self.busy = NO;
}    


#pragma mark -
#pragma mark NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)sv canCollapseSubview:(NSView *)v {
    return v == [[sv subviews] objectAtIndex:1];
}


- (BOOL)splitView:(NSSplitView *)sv shouldCollapseSubview:(NSView *)v forDoubleClickOnDividerAtIndex:(NSInteger)i {
    return [self splitView:sv canCollapseSubview:v];
}


// maintain constant splitview width when resizing window
- (void)splitView:(NSSplitView *)sv resizeSubviewsWithOldSize:(NSSize)oldSize {    
    NSRect newFrame = [sv frame]; // get the new size of the whole splitView
    NSView *top = [[sv subviews] objectAtIndex:0];
    NSRect topFrame = [top frame];
    NSView *bottom = [[sv subviews] objectAtIndex:1];
    NSRect bottomFrame = [bottom frame];
    
    CGFloat dividerThickness = [sv dividerThickness];
    topFrame.size.width = newFrame.size.width;
    
    bottomFrame.size.height = newFrame.size.height - topFrame.size.height - dividerThickness;
    bottomFrame.size.width = newFrame.size.width;
    topFrame.origin.y = 0;
    
    [top setFrame:topFrame];
    [bottom setFrame:bottomFrame];
}


- (CGFloat)splitView:(NSSplitView *)sv constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)i {
    if (0 == i) {
        return 200.0;
    } else {
        return proposedMin;
    }
}


- (CGFloat)splitView:(NSSplitView *)sv constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)i {
    return proposedMax;
}

@end

