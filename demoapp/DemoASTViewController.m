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

#import "DemoASTViewController.h"
#import "PKASTView.h"
#import "PKParseTree.h"
#import "PKRuleNode.h"
#import "PKTokenNode.h"
#import "PKParseTreeAssembler.h"
#import <ParseKit/ParseKit.h>

#define PKAssertMainThread() NSAssert1([NSThread isMainThread], @"%s should be called on the main thread only.", __PRETTY_FUNCTION__);
#define PKAssertNotMainThread() NSAssert1(![NSThread isMainThread], @"%s should be called on the main thread only.", __PRETTY_FUNCTION__);

@implementation DemoASTViewController

- (id)init {
    return [self initWithNibName:@"ASTView" bundle:nil];
}


- (void)dealloc {
    self.ASTView = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
//    self.grammarString = @"@allowsScientificNotation=YES;\nstart = expr;\nexpr = addExpr;\naddExpr = multExpr (('+'|'-') multExpr)*;\nmultExpr = atom (('*'|'/') atom)*;\natom = Number;";
//    self.grammarString = @"start = array;array = '[' Number (commaNumber)* ']';commaNumber = ',' Number;";
//    self.grammarString = @"start = array;array = foo | Word; foo = 'foo';";
//    self.grammarString = @"allowsScientificNotation = YES;     start        = Empty | array | object;          object        = '{' (Empty | property (',' property)*) '}';     property      = name ':' value;     name  = QuotedString;          array         = '[' (Empty | value (',' value)*) ']';          value         = 'null' | boolean | array | object | number | string;          string        = QuotedString;     number        = Number;     boolean       = 'true' | 'false';";
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"expression" ofType:@"grammar"];
    self.grammarString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

//    self.inString = @"4.0*.4 + 2e-12/-47 +3";
//    self.inString = @"[1,2]";
//    self.inString = @"foo";
    self.inputString = @"foo or bar.baz('hello', yes, 10.1)";
}


- (void)doParse {
    PKAssertNotMainThread();

    PKAST *root = [[PKParserFactory factory] ASTFromGrammar:self.grammarString error:nil];
    [_ASTView drawAST:root];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self done];
    });
}

@end

