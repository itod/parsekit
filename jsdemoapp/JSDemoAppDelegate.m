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

#import "JSDemoAppDelegate.h"
#import <WebKit/WebKit.h>
#import <JSParseKit/JSParseKit.h>

@interface NSObject (JSDemoAppExtras)
- (id)inspector;
- (void)showConsole:(id)sender;
@end

@interface JSDemoAppDelegate ()
+ (void)setUpDefaults;
@end

@implementation JSDemoAppDelegate

+ (void)load {
    if ([JSDemoAppDelegate class] == self) {
        [self setUpDefaults];
    }
}


+ (void)setUpDefaults {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultValues" ofType:@"plist"];
    id defaultValues = [NSMutableDictionary dictionaryWithContentsOfFile:path];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaultValues];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [pool release];
}


- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}


- (void)dealloc {
    self.webView = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"html"];
    [comboBox setStringValue:[[NSURL fileURLWithPath:path] absoluteString]];
    [self goToLocation:self];
}


#pragma mark -
#pragma mark Actions

- (IBAction)openLocation:(id)sender {
    [window makeFirstResponder:comboBox];
}


- (IBAction)goToLocation:(id)sender {
    NSString *URLString = [comboBox stringValue];
    
    if (![URLString length]) {
        NSBeep();
        return;
    }
    
    if (![URLString hasPrefix:@"file://"] && ![URLString hasPrefix:@"http://"] && ![URLString hasPrefix:@"https://"]) {
        URLString = [NSString stringWithFormat:@"http://%@", URLString];
        [comboBox setStringValue:URLString];
    }
    
    [webView setMainFrameURL:URLString];
}


- (IBAction)collect:(id)sender {
    JSGlobalContextRef ctx = [[webView mainFrame] globalContext];
    JSGarbageCollect(ctx);
}


- (IBAction)showConsole:(id)sender {
    [[webView inspector] showConsole:sender];
}


#pragma mark -
#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {    
    if (frame != [sender mainFrame]) return;
    
    [window setTitle:title];
}


- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    if (frame != [sender mainFrame]) return;
    
    NSString *URLString = [[[[frame provisionalDataSource] request] URL] absoluteString];
    [comboBox setStringValue:URLString];
}        


- (void)webView:(WebView *)sender didReceiveServerRedirectForProvisionalLoadForFrame:(WebFrame *)frame {
    if (frame != [sender mainFrame]) return;
    
    NSString *URLString = [[[[frame provisionalDataSource] request] URL] absoluteString];
    [comboBox setStringValue:URLString];
}


- (void)webView:(WebView *)sender willPerformClientRedirectToURL:(NSURL *)URL delay:(NSTimeInterval)seconds fireDate:(NSDate *)date forFrame:(WebFrame *)frame {
    [comboBox setStringValue:[URL absoluteString]];
}


- (void)webView:(WebView *)sender didClearWindowObject:(WebScriptObject *)windowObject forFrame:(WebFrame *)frame {
    PKJSParseKitSetUpContext([[sender mainFrame] globalContext]);
}

@synthesize webView;
@end
