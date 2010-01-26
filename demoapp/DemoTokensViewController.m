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

#import "DemoTokensViewController.h"
#import <ParseKit/ParseKit.h>
#import "PKParseTreeView.h"

@interface DemoTokensViewController ()
- (void)doParse;
- (void)done;
@end

@implementation DemoTokensViewController

- (id)init {
    return [self initWithNibName:@"TokensView" bundle:nil];
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b {
    if (self = [super initWithNibName:name bundle:b]) {
        self.tokenizer = [[[PKTokenizer alloc] init] autorelease];
        
        [tokenizer.symbolState add:@"::"];
        [tokenizer.symbolState add:@"<="];
        [tokenizer.symbolState add:@">="];
        [tokenizer.symbolState add:@"=="];
        [tokenizer.symbolState add:@"!="];
        [tokenizer.symbolState add:@"+="];
        [tokenizer.symbolState add:@"-="];
        [tokenizer.symbolState add:@"*="];
        [tokenizer.symbolState add:@"/="];
        [tokenizer.symbolState add:@":="];
        [tokenizer.symbolState add:@"++"];
        [tokenizer.symbolState add:@"--"];
        [tokenizer.symbolState add:@"<>"];
        [tokenizer.symbolState add:@"=:="];
    }
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.inString = nil;
    self.outString = nil;
    self.tokString = nil;
    self.toks = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSString *s = [NSString stringWithFormat:@"%C", 0xab];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:s];
    [tokenField setTokenizingCharacterSet:set];
}


- (IBAction)parse:(id)sender {
    if (![inString length]) {
        NSBeep();
        return;
    }
    
    self.busy = YES;
    
    //[self doParse];
    [NSThread detachNewThreadSelector:@selector(doParse) toTarget:self withObject:nil];
}


- (void)doParse {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    //self.tokenizer = [PKTokenizer tokenizer];
    self.tokenizer.string = self.inString;
    
    
    self.toks = [NSMutableArray array];
    PKToken *tok = nil;
    PKToken *eof = [PKToken EOFToken];
    while (eof != (tok = [tokenizer nextToken])) {
        [toks addObject:tok];
    }
    
    [self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];
    
    [pool drain];
}


- (void)done {
    NSMutableString *s = [NSMutableString string];
    for (PKToken *tok in toks) {
        [s appendFormat:@"%@ %C", tok.stringValue, 0xab];
    }
    self.tokString = [[s copy] autorelease];
    
    s = [NSMutableString string];
    for (PKToken *tok in toks) {
        [s appendFormat:@"%@\n", [tok debugDescription]];
    }
    self.outString = [[s copy] autorelease];
    self.busy = NO;
}

@synthesize tokenizer;
@synthesize inString;
@synthesize outString;
@synthesize tokString;
@synthesize toks;
@synthesize busy;
@end
