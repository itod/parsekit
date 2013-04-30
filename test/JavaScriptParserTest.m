
//
//  JavaScriptParserTest.m
//  JavaScript
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "JavaScriptParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "JavaScriptParser.h"

@interface JavaScriptParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) JavaScriptParser *parser;
@end

@implementation JavaScriptParserTest {
    BOOL flag;
}

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"javascript" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"JavaScript";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorAll;
    _visitor.enableAutomaticErrorRecovery = YES;
    _visitor.enableMemoization = NO;
    
    [_root visit:_visitor];
    
    self.parser = [[[JavaScriptParser alloc] init] autorelease];

#if TD_EMIT
    path = [@"~/work/parsekit/trunk/test/JavaScriptParser.h" stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [@"~/work/parsekit/trunk/test/JavaScriptParser.m" stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}


- (void)parser:(PKSParser *)p didMatchVarVariables:(PKAssembly *)a {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, a);
    flag = YES;
}
- (void)testVarFooEqBar {
    _parser.enableAutomaticErrorRecovery = YES;
    
    NSError *err = nil;
    flag = NO;
    PKAssembly *res = [_parser parseString:@"var foo = 'bar';" assembler:self error:&err];
    TDEqualObjects(@"[var, foo, =, 'bar', ;]var/foo/=/'bar'/;^", [res description]);
    TDEquals(YES, flag);
}

- (void)testDocWriteNewDate {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"document.write(new Date().toUTCString());" assembler:nil error:&err];
    TDEqualObjects(@"[document, ., write, (, new, Date, (, ), ., toUTCString, (, ), ), ;]document/./write/(/new/Date/(/)/./toUTCString/(/)/)/;^", [res description]);
}

- (void)testDocWriteNewDateWithParen {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"document.write((new Date()).toUTCString());" assembler:nil error:&err];
    TDEqualObjects(@"[document, ., write, (, (, new, Date, (, ), ), ., toUTCString, (, ), ), ;]document/./write/(/(/new/Date/(/)/)/./toUTCString/(/)/)/;^", [res description]);
}

- (void)testDocWriteDate {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"document.write(foo.toUTCString());" assembler:nil error:&err];
    TDEqualObjects(@"[document, ., write, (, foo, ., toUTCString, (, ), ), ;]document/./write/(/foo/./toUTCString/(/)/)/;^", [res description]);
}

- (void)testGmailUserscriptShort {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"window.fluid.dockBadge = ''; setTimeout(updateDockBadge, 1000); setTimeout(updateDockBadge, 3000); setInterval(updateDockBadge, 5000);" assembler:nil error:&err];
    TDEqualObjects(@"[window, ., fluid, ., dockBadge, =, '', ;, setTimeout, (, updateDockBadge, ,, 1000, ), ;, setTimeout, (, updateDockBadge, ,, 3000, ), ;, setInterval, (, updateDockBadge, ,, 5000, ), ;]window/./fluid/./dockBadge/=/''/;/setTimeout/(/updateDockBadge/,/1000/)/;/setTimeout/(/updateDockBadge/,/3000/)/;/setInterval/(/updateDockBadge/,/5000/)/;^", [res description]);
}

@end
