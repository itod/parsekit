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

#import "DemoTreesViewController.h"
#import "PKParseTreeView.h"
#import "TDSourceCodeTextView.h"
#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"
#import "PKParseTreeAssembler.h"
#import <ParseKit/ParseKit.h>

#import "JavaScriptSyntaxParser.h"
#import "ExpressionSyntaxParser.h"
#import "PKSParseTreeAssembler.h"

#define PKAssertMainThread() NSAssert1([NSThread isMainThread], @"%s should be called on the main thread only.", __PRETTY_FUNCTION__);
#define PKAssertNotMainThread() NSAssert1(![NSThread isMainThread], @"%s should be called on the main thread only.", __PRETTY_FUNCTION__);

@implementation DemoTreesViewController

- (id)init {
    return [self initWithNibName:@"TreesView" bundle:nil];
}


- (void)dealloc {
    self.parseTreeView = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
//    self.grammarString = @"@allowsScientificNotation=YES;\nstart = expr;\nexpr = addExpr;\naddExpr = multExpr (('+'|'-') multExpr)*;\nmultExpr = atom (('*'|'/') atom)*;\natom = Number;";
//    self.grammarString = @"start = array;array = '[' Number (commaNumber)* ']';commaNumber = ',' Number;";
//    self.grammarString = @"start = array;array = foo | Word; foo = 'foo';";
//    self.grammarString = @"@allowsScientificNotation = YES;     start        = Empty | array | object;          object        = '{' (Empty | property (',' property)*) '}';     property      = name ':' value;     name  = QuotedString;          array         = '[' (Empty | value (',' value)*) ']';          value         = 'null' | boolean | array | object | number | string;          string        = QuotedString;     number        = Number;     boolean       = 'true' | 'false';";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"grammar"];
    self.grammarString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
//    self.grammarString =
//    @"expr      = orExpr;\n"
//    @"orExpr    = andExpr orTerm*;\n"
//    @"orTerm    = 'or' andExpr;\n"
//    @"andExpr   = atom andTerm*;\n"
//    @"andTerm   = 'and' atom;\n"
//    @"atom      = Word;\n";



//    self.inString = @"4.0*.4 + 2e-12/-47 +3";
//    self.inString = @"[1,2]";
//    self.inString = @"foo";
    self.inputString = @"bar('foo');";
//    self.inputString = @"foo or bar";
}


- (void)doParse {
    PKAssertNotMainThread();

//    PKParseTreeAssembler *as = [[[PKParseTreeAssembler alloc] init] autorelease];
//    PKParser *p = [[PKParserFactory factory] parserFromGrammar:self.grammarString assembler:as preassembler:as error:nil];
//    PKParseTree *tr = [p parse:self.inputString error:nil];


//    PEGParser *p = [[[ExpressionSyntaxParser alloc] init] autorelease];
    PEGParser *p = [[[JavaScriptSyntaxParser alloc] init] autorelease];
    PKSParseTreeAssembler *ass = [[[PKSParseTreeAssembler alloc] init] autorelease];
    
    [p parseString:self.inputString assembler:ass error:nil];
    
    PKParseTree *tr = ass.root;
    
    if ([tr isKindOfClass:[PKParseTree class]]) {
        [_parseTreeView drawParseTree:tr];
    }
    
//    // release
//    PKReleaseSubparserTree(p);

    dispatch_async(dispatch_get_main_queue(), ^{
        [self done];
    });
}

@end

