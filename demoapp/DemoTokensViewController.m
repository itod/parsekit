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
        
        [_tokenizer.symbolState add:@"::"];
        [_tokenizer.symbolState add:@"<="];
        [_tokenizer.symbolState add:@">="];
        [_tokenizer.symbolState add:@"=="];
        [_tokenizer.symbolState add:@"!="];
        [_tokenizer.symbolState add:@"+="];
        [_tokenizer.symbolState add:@"-="];
        [_tokenizer.symbolState add:@"*="];
        [_tokenizer.symbolState add:@"/="];
        [_tokenizer.symbolState add:@":="];
        [_tokenizer.symbolState add:@"++"];
        [_tokenizer.symbolState add:@"--"];
        [_tokenizer.symbolState add:@"<>"];
        [_tokenizer.symbolState add:@"=:="];
    }
    return self;
}


- (void)dealloc {
    self.tokenField = nil;
    self.tokenizer = nil;
    self.inputString = nil;
    self.outString = nil;
    self.tokString = nil;
    self.toks = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSString *s = [NSString stringWithFormat:@"%C", (unichar)0xab];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:s];
    [_tokenField setTokenizingCharacterSet:set];
}


- (IBAction)parse:(id)sender {
    if (![_inputString length]) {
        NSBeep();
        return;
    }
    
    self.busy = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doParse];
    });
}


- (void)doParse {
    //self.tokenizer = [PKTokenizer tokenizer];
    self.tokenizer.string = self.inputString;
    
    
    self.toks = [NSMutableArray array];
    PKToken *tok = nil;
    PKToken *eof = [PKToken EOFToken];
    while (eof != (tok = [_tokenizer nextToken])) {
        [_toks addObject:tok];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self done];
    });
}


- (void)done {
    NSMutableString *s = [NSMutableString string];
    for (PKToken *tok in _toks) {
        [s appendFormat:@"%@ %C", tok.stringValue, (unichar)0xab];
    }
    self.tokString = [[s copy] autorelease];
    
    s = [NSMutableString string];
    for (PKToken *tok in _toks) {
        [s appendFormat:@"%@\n", [tok debugDescription]];
    }
    self.outString = [[s copy] autorelease];
    self.busy = NO;
}

@end
