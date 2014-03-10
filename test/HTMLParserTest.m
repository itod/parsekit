
//
//  HTMLParserTest.m
//  HTML
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "HTMLParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "HTMLParser.h"

@interface HTMLParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) HTMLParser *parser;
@end

@implementation HTMLParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"html" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"HTML";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorTerminals;
    [_root visit:_visitor];
    
    self.parser = [[[HTMLParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/HTMLParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/HTMLParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testExamplePlist {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:@"html"];
    NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:input assembler:nil error:&err];
    TDEqualObjects(@"[<?xml version=\"1.1\"?>, <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">, <!-- foo -->, <, plist, version, =, \"1.0\", >, <, dict, >, <, key, >, CFBundleDevelopmentRegion, <, /, key, >, <, string, >, English, <, /, string, >, <, key, >, CFBundleExecutable, <, /, key, >, <, string, >, $, {, EXECUTABLE_NAME, }, <, /, string, >, <!-- foo -->, <, key, >, CFBundleName, <, /, key, >, <, string, >, $, {, PRODUCT_NAME, }, <, /, string, >, <, key, >, CFBundleIconFile, <, /, key, >, <, string, >, <, /, string, >, <, key, >, CFBundleIdentifier, <, /, key, >, <, string, >, com, ., parsekit, ., ParseKit, <, /, string, >, <, key, >, CFBundleInfoDictionaryVersion, <, /, key, >, <, string, >, 6.0, <, /, string, >, <, key, >, CFBundlePackageType, <, /, key, >, <, string, >, FMWK, <, /, string, >, <, key, >, CFBundleSignature, <, /, key, >, <, string, >, ?, ?, ?, ?, <, /, string, >, <, key, >, CFBundleVersion, <, /, key, >, <, string, >, 1.4, <, /, string, >, <, key, >, NSPrincipalClass, <, /, key, >, <, string, >, <, /, string, >, <, /, dict, >, <, /, plist, >]<?xml version=\"1.1\"?>/<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">/<!-- foo -->/</plist/version/=/\"1.0\"/>/</dict/>/</key/>/CFBundleDevelopmentRegion/<///key/>/</string/>/English/<///string/>/</key/>/CFBundleExecutable/<///key/>/</string/>/$/{/EXECUTABLE_NAME/}/<///string/>/<!-- foo -->/</key/>/CFBundleName/<///key/>/</string/>/$/{/PRODUCT_NAME/}/<///string/>/</key/>/CFBundleIconFile/<///key/>/</string/>/<///string/>/</key/>/CFBundleIdentifier/<///key/>/</string/>/com/./parsekit/./ParseKit/<///string/>/</key/>/CFBundleInfoDictionaryVersion/<///key/>/</string/>/6.0/<///string/>/</key/>/CFBundlePackageType/<///key/>/</string/>/FMWK/<///string/>/</key/>/CFBundleSignature/<///key/>/</string/>/?/?/?/?/<///string/>/</key/>/CFBundleVersion/<///key/>/</string/>/1.4/<///string/>/</key/>/NSPrincipalClass/<///key/>/</string/>/<///string/>/<///dict/>/<///plist/>^", [res description]);
}

- (void)testPHi {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"<p>hi" assembler:nil error:&err];
    TDEqualObjects(@"[<, p, >, hi]</p/>/hi^", [res description]);
}

- (void)testPHiP {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"<p>hi</p>" assembler:nil error:&err];
    TDEqualObjects(@"[<, p, >, hi, <, /, p, >]</p/>/hi/<///p/>^", [res description]);
}

- (void)testDoctypePHiP {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'><p>hi</p>" assembler:nil error:&err];
    TDEqualObjects(@"[<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>, <, p, >, hi, <, /, p, >]<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>/</p/>/hi/<///p/>^", [res description]);
}

- (void)testFluidappcom1 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"<div id='home' class='link'><a href='/'>Home</a></div>" assembler:nil error:&err];
    TDEqualObjects(@"[<, div, id, =, 'home', class, =, 'link', >, <, a, href, =, '/', >, Home, <, /, a, >, <, /, div, >]</div/id/=/'home'/class/=/'link'/>/</a/href/=/'/'/>/Home/<///a/>/<///div/>^", [res description]);
}

- (void)testFluidappcom2 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"<!-- <img id='fluidScreen' src='images/fluid_screen.png'/> --><div id='screencast'><center><iframe src='http://player.vimeo.com/video/22820843?title=0&amp;byline=0&amp;portrait=0' width='400' height='300' frameborder='0'></iframe></center></div>" assembler:nil error:&err];
    TDEqualObjects(@"[<!-- <img id='fluidScreen' src='images/fluid_screen.png'/> -->, <, div, id, =, 'screencast', >, <, center, >, <, iframe, src, =, 'http://player.vimeo.com/video/22820843?title=0&amp;byline=0&amp;portrait=0', width, =, '400', height, =, '300', frameborder, =, '0', >, <, /, iframe, >, <, /, center, >, <, /, div, >]<!-- <img id='fluidScreen' src='images/fluid_screen.png'/> -->/</div/id/=/'screencast'/>/</center/>/</iframe/src/=/'http://player.vimeo.com/video/22820843?title=0&amp;byline=0&amp;portrait=0'/width/=/'400'/height/=/'300'/frameborder/=/'0'/>/<///iframe/>/<///center/>/<///div/>^", [res description]);
}

- (void)testFluidappcom3 {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"<div><a href='mailto:recover@fluidapp.com?subject=Recover%20Fluid%20License&amp;body=Please%20send%20me%20a%20copy%20of%20my%20Fluid%20license.%20The%20name%20I%20used%20to%20purchase%20Fluid%20is%20NAME_HERE%20and%20the%20email%20is%20EMAIL_HERE.%20Thanks!' rel='nofollow'>Lost License?</a></div>" assembler:nil error:&err];
    TDEqualObjects(@"[<, div, >, <, a, href, =, 'mailto:recover@fluidapp.com?subject=Recover%20Fluid%20License&amp;body=Please%20send%20me%20a%20copy%20of%20my%20Fluid%20license.%20The%20name%20I%20used%20to%20purchase%20Fluid%20is%20NAME_HERE%20and%20the%20email%20is%20EMAIL_HERE.%20Thanks!', rel, =, 'nofollow', >, Lost, License, ?, <, /, a, >, <, /, div, >]</div/>/</a/href/=/'mailto:recover@fluidapp.com?subject=Recover%20Fluid%20License&amp;body=Please%20send%20me%20a%20copy%20of%20my%20Fluid%20license.%20The%20name%20I%20used%20to%20purchase%20Fluid%20is%20NAME_HERE%20and%20the%20email%20is%20EMAIL_HERE.%20Thanks!'/rel/=/'nofollow'/>/Lost/License/?/<///a/>/<///div/>^", [res description]);
}

@end
