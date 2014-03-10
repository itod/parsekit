
//
//  CSSParserTest.m
//  CSS
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "CSSParserTest.h"
#import "PKParserFactory.h"
#import "PKSParserGenVisitor.h"
#import "PKRootNode.h"
#import "CSSParser.h"

@interface CSSParserTest ()
@property (nonatomic, retain) PKParserFactory *factory;
@property (nonatomic, retain) PKRootNode *root;
@property (nonatomic, retain) PKSParserGenVisitor *visitor;
@property (nonatomic, retain) CSSParser *parser;
@end

@implementation CSSParserTest

- (void)setUp {
    self.factory = [PKParserFactory factory];
    _factory.collectTokenKinds = YES;

    NSError *err = nil;
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"css" ofType:@"grammar"];
    NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&err];
    
    err = nil;
    self.root = (id)[_factory ASTFromGrammar:g error:&err];
    _root.grammarName = @"CSS";
    
    self.visitor = [[[PKSParserGenVisitor alloc] init] autorelease];
    _visitor.assemblerSettingBehavior = PKParserFactoryAssemblerSettingBehaviorTerminals;
    [_root visit:_visitor];
    
    self.parser = [[[CSSParser alloc] init] autorelease];

#if TD_EMIT
    path = [[NSString stringWithFormat:@"%s/test/CSSParser.h", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.interfaceOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }

    path = [[NSString stringWithFormat:@"%s/test/CSSParser.m", getenv("PWD")] stringByExpandingTildeInPath];
    err = nil;
    if (![_visitor.implementationOutputString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&err]) {
        NSLog(@"%@", err);
    }
#endif
}

- (void)tearDown {
    self.factory = nil;
}

- (void)testVarFooColorRed {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo {color:red;}" assembler:nil error:&err];
    TDEqualObjects(@"[foo, {, color, :, red, ;, }]foo/{/color/:/red/;/}^", [res description]);
}

- (void)testVarFooColorRedImportant {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@"foo {color:red !important;}" assembler:nil error:&err];
    TDEqualObjects(@"[foo, {, color, :, red, !, important, ;, }]foo/{/color/:/red/!/important/;/}^", [res description]);
}

- (void)testFluidappComStylesheet {
    NSError *err = nil;
    PKAssembly *res = [_parser parseString:@" html, body { margin:0; padding:0; } body { background:url(/images/top_bg.png) 0 0 repeat-x; } a:link, a:visited { color:rgb(15, 72, 123); } a:hover { text-decoration:none; } #wrapper { position:relative; left:0; top:0; width:880px; margin:0 auto; font:13px/1.6 'Lucida Grande', LucidaGrande, Helvetica, sans-serif; color:#444; } #logo { position:absolute; left:0; top:0; } #tagline { position:absolute; left:133px; top:82px; color:#333; } #menu { position:absolute; right:20px; top:0; width:370px; height:58px; background:url(/images/menu_bg.png) 0 0 no-repeat; } #menu .link { position:absolute; top:0; height:50px; text-indent:-9999px; font-size:0; } #menu a:link, #menu a:visited { display:block; height:50px; } #home { left:17px; width:59px; } #home:hover { background:url(/images/home_button_hover.png) 0 8px no-repeat; } #homePage #home { background:url(/images/home_button.png) 0 8px no-repeat; } #blog { left:98px; width:51px; } #blog:hover { background:url(/images/blog_button_hover.png) 0 8px no-repeat; } #blogPage #blog { background:url(/images/blog_button.png) 0 8px no-repeat; } #dev { left:171px; width:98px; } #dev:hover { background:url(/images/dev_button_hover.png) 0 8px no-repeat; } #devPage #dev { background:url(/images/dev_button.png) 0 8px no-repeat; } #about { left:291px; width:62px; } #about:hover { background:url(/images/about_button_hover.png) 0 8px no-repeat; } #aboutPage #about { background:url(/images/about_button.png) 0 8px no-repeat; } #top-content { padding-top:170px; padding-right:230px; } #fluidSidebar { position:absolute; right:-10px; top:150px; width:220px; text-align:center; } #size, #version { font-size:9px; } #version { padding-top:5px; } #dload { width:160px; height:35px; margin-left:29px; background:url(/images/dload_button.png) no-repeat center center; text-align:left; text-indent:-9999px; font-size:0; } #dload:hover { background-image:url(/images/dload_button_hover.png); } #dload a:link, #dload a:visited { display:block; height:35px; } #links { margin:24px 0; line-height:2.0; } #links a:link, #links a:visited { font-size:11px; } #iusethisLabel { margin-left:30px; } #ad { margin:28px 0 20px 20px; } #screencast { float:right; margin:-12px 0 -16px 20px; } #dock { margin:33px 20px 30px 0; text-align:left; } #dock img { border:1px solid silver; padding:20px; } #dock a:link, #dock a:visited { color:gray; } #thanksPage #bottom-content { margin-top:360px; } #details { margin:30px 0 40px; font-size:9px; text-align:center; clear:both; } #lbCaption { text-shadow:0 0 0 transparent; } #preloader div { background-repeat:no-repeat; background-position:-1000px -1000px; } #preload_home_button { background-image:url(/images/home_button.png); } #preload_blog_button { background-image:url(/images/blog_button.png); } #preload_dev_button { background-image:url(/images/dev_button.png); } #preload_about_button { background-image:url(/images/about_button.png); } #preload_home_button_hover { background-image:url(/images/home_button_hover.png); } #preload_blog_button_hover { background-image:url(/images/blog_button_hover.png); } #preload_dev_button_hover { background-image:url(/images/dev_button_hover.png); } #preload_about_button_hover { background-image:url(/images/about_button_hover.png); } #preload_dload_button_hover { background-image:url(/images/dload_button_hover.png); }" assembler:nil error:&err];
    
    //NSLog(@"%@", res);
    
    TDEqualObjects(@"[html, ,, body, {, margin, :, 0, ;, padding, :, 0, ;, }, body, {, background, :, url(/images/top_bg.png), 0, 0, repeat-x, ;, }, a, :, link, ,, a, :, visited, {, color, :, rgb, (, 15, ,, 72, ,, 123, ), ;, }, a, :, hover, {, text-decoration, :, none, ;, }, #wrapper, {, position, :, relative, ;, left, :, 0, ;, top, :, 0, ;, width, :, 880, px, ;, margin, :, 0, auto, ;, font, :, 13, px, /, 1.6, 'Lucida Grande', ,, LucidaGrande, ,, Helvetica, ,, sans-serif, ;, color, :, #444, ;, }, #logo, {, position, :, absolute, ;, left, :, 0, ;, top, :, 0, ;, }, #tagline, {, position, :, absolute, ;, left, :, 133, px, ;, top, :, 82, px, ;, color, :, #333, ;, }, #menu, {, position, :, absolute, ;, right, :, 20, px, ;, top, :, 0, ;, width, :, 370, px, ;, height, :, 58, px, ;, background, :, url(/images/menu_bg.png), 0, 0, no-repeat, ;, }, #menu, .link, {, position, :, absolute, ;, top, :, 0, ;, height, :, 50, px, ;, text-indent, :, -9999px, ;, font-size, :, 0, ;, }, #menu, a, :, link, ,, #menu, a, :, visited, {, display, :, block, ;, height, :, 50, px, ;, }, #home, {, left, :, 17, px, ;, width, :, 59, px, ;, }, #home, :, hover, {, background, :, url(/images/home_button_hover.png), 0, 8, px, no-repeat, ;, }, #homePage, #home, {, background, :, url(/images/home_button.png), 0, 8, px, no-repeat, ;, }, #blog, {, left, :, 98, px, ;, width, :, 51, px, ;, }, #blog, :, hover, {, background, :, url(/images/blog_button_hover.png), 0, 8, px, no-repeat, ;, }, #blogPage, #blog, {, background, :, url(/images/blog_button.png), 0, 8, px, no-repeat, ;, }, #dev, {, left, :, 171, px, ;, width, :, 98, px, ;, }, #dev, :, hover, {, background, :, url(/images/dev_button_hover.png), 0, 8, px, no-repeat, ;, }, #devPage, #dev, {, background, :, url(/images/dev_button.png), 0, 8, px, no-repeat, ;, }, #about, {, left, :, 291, px, ;, width, :, 62, px, ;, }, #about, :, hover, {, background, :, url(/images/about_button_hover.png), 0, 8, px, no-repeat, ;, }, #aboutPage, #about, {, background, :, url(/images/about_button.png), 0, 8, px, no-repeat, ;, }, #top-content, {, padding-top, :, 170, px, ;, padding-right, :, 230, px, ;, }, #fluidSidebar, {, position, :, absolute, ;, right, :, -10px, ;, top, :, 150, px, ;, width, :, 220, px, ;, text-align, :, center, ;, }, #size, ,, #version, {, font-size, :, 9, px, ;, }, #version, {, padding-top, :, 5, px, ;, }, #dload, {, width, :, 160, px, ;, height, :, 35, px, ;, margin-left, :, 29, px, ;, background, :, url(/images/dload_button.png), no-repeat, center, center, ;, text-align, :, left, ;, text-indent, :, -9999px, ;, font-size, :, 0, ;, }, #dload, :, hover, {, background-image, :, url(/images/dload_button_hover.png), ;, }, #dload, a, :, link, ,, #dload, a, :, visited, {, display, :, block, ;, height, :, 35, px, ;, }, #links, {, margin, :, 24, px, 0, ;, line-height, :, 2.0, ;, }, #links, a, :, link, ,, #links, a, :, visited, {, font-size, :, 11, px, ;, }, #iusethisLabel, {, margin-left, :, 30, px, ;, }, #ad, {, margin, :, 28, px, 0, 20, px, 20, px, ;, }, #screencast, {, float, :, right, ;, margin, :, -12px, 0, -16px, 20, px, ;, }, #dock, {, margin, :, 33, px, 20, px, 30, px, 0, ;, text-align, :, left, ;, }, #dock, img, {, border, :, 1, px, solid, silver, ;, padding, :, 20, px, ;, }, #dock, a, :, link, ,, #dock, a, :, visited, {, color, :, gray, ;, }, #thanksPage, #bottom-content, {, margin-top, :, 360, px, ;, }, #details, {, margin, :, 30, px, 0, 40, px, ;, font-size, :, 9, px, ;, text-align, :, center, ;, clear, :, both, ;, }, #lbCaption, {, text-shadow, :, 0, 0, 0, transparent, ;, }, #preloader, div, {, background-repeat, :, no-repeat, ;, background-position, :, -1000px, -1000px, ;, }, #preload_home_button, {, background-image, :, url(/images/home_button.png), ;, }, #preload_blog_button, {, background-image, :, url(/images/blog_button.png), ;, }, #preload_dev_button, {, background-image, :, url(/images/dev_button.png), ;, }, #preload_about_button, {, background-image, :, url(/images/about_button.png), ;, }, #preload_home_button_hover, {, background-image, :, url(/images/home_button_hover.png), ;, }, #preload_blog_button_hover, {, background-image, :, url(/images/blog_button_hover.png), ;, }, #preload_dev_button_hover, {, background-image, :, url(/images/dev_button_hover.png), ;, }, #preload_about_button_hover, {, background-image, :, url(/images/about_button_hover.png), ;, }, #preload_dload_button_hover, {, background-image, :, url(/images/dload_button_hover.png), ;, }]html/,/body/{/margin/:/0/;/padding/:/0/;/}/body/{/background/:/url(/images/top_bg.png)/0/0/repeat-x/;/}/a/:/link/,/a/:/visited/{/color/:/rgb/(/15/,/72/,/123/)/;/}/a/:/hover/{/text-decoration/:/none/;/}/#wrapper/{/position/:/relative/;/left/:/0/;/top/:/0/;/width/:/880/px/;/margin/:/0/auto/;/font/:/13/px///1.6/'Lucida Grande'/,/LucidaGrande/,/Helvetica/,/sans-serif/;/color/:/#444/;/}/#logo/{/position/:/absolute/;/left/:/0/;/top/:/0/;/}/#tagline/{/position/:/absolute/;/left/:/133/px/;/top/:/82/px/;/color/:/#333/;/}/#menu/{/position/:/absolute/;/right/:/20/px/;/top/:/0/;/width/:/370/px/;/height/:/58/px/;/background/:/url(/images/menu_bg.png)/0/0/no-repeat/;/}/#menu/.link/{/position/:/absolute/;/top/:/0/;/height/:/50/px/;/text-indent/:/-9999px/;/font-size/:/0/;/}/#menu/a/:/link/,/#menu/a/:/visited/{/display/:/block/;/height/:/50/px/;/}/#home/{/left/:/17/px/;/width/:/59/px/;/}/#home/:/hover/{/background/:/url(/images/home_button_hover.png)/0/8/px/no-repeat/;/}/#homePage/#home/{/background/:/url(/images/home_button.png)/0/8/px/no-repeat/;/}/#blog/{/left/:/98/px/;/width/:/51/px/;/}/#blog/:/hover/{/background/:/url(/images/blog_button_hover.png)/0/8/px/no-repeat/;/}/#blogPage/#blog/{/background/:/url(/images/blog_button.png)/0/8/px/no-repeat/;/}/#dev/{/left/:/171/px/;/width/:/98/px/;/}/#dev/:/hover/{/background/:/url(/images/dev_button_hover.png)/0/8/px/no-repeat/;/}/#devPage/#dev/{/background/:/url(/images/dev_button.png)/0/8/px/no-repeat/;/}/#about/{/left/:/291/px/;/width/:/62/px/;/}/#about/:/hover/{/background/:/url(/images/about_button_hover.png)/0/8/px/no-repeat/;/}/#aboutPage/#about/{/background/:/url(/images/about_button.png)/0/8/px/no-repeat/;/}/#top-content/{/padding-top/:/170/px/;/padding-right/:/230/px/;/}/#fluidSidebar/{/position/:/absolute/;/right/:/-10px/;/top/:/150/px/;/width/:/220/px/;/text-align/:/center/;/}/#size/,/#version/{/font-size/:/9/px/;/}/#version/{/padding-top/:/5/px/;/}/#dload/{/width/:/160/px/;/height/:/35/px/;/margin-left/:/29/px/;/background/:/url(/images/dload_button.png)/no-repeat/center/center/;/text-align/:/left/;/text-indent/:/-9999px/;/font-size/:/0/;/}/#dload/:/hover/{/background-image/:/url(/images/dload_button_hover.png)/;/}/#dload/a/:/link/,/#dload/a/:/visited/{/display/:/block/;/height/:/35/px/;/}/#links/{/margin/:/24/px/0/;/line-height/:/2.0/;/}/#links/a/:/link/,/#links/a/:/visited/{/font-size/:/11/px/;/}/#iusethisLabel/{/margin-left/:/30/px/;/}/#ad/{/margin/:/28/px/0/20/px/20/px/;/}/#screencast/{/float/:/right/;/margin/:/-12px/0/-16px/20/px/;/}/#dock/{/margin/:/33/px/20/px/30/px/0/;/text-align/:/left/;/}/#dock/img/{/border/:/1/px/solid/silver/;/padding/:/20/px/;/}/#dock/a/:/link/,/#dock/a/:/visited/{/color/:/gray/;/}/#thanksPage/#bottom-content/{/margin-top/:/360/px/;/}/#details/{/margin/:/30/px/0/40/px/;/font-size/:/9/px/;/text-align/:/center/;/clear/:/both/;/}/#lbCaption/{/text-shadow/:/0/0/0/transparent/;/}/#preloader/div/{/background-repeat/:/no-repeat/;/background-position/:/-1000px/-1000px/;/}/#preload_home_button/{/background-image/:/url(/images/home_button.png)/;/}/#preload_blog_button/{/background-image/:/url(/images/blog_button.png)/;/}/#preload_dev_button/{/background-image/:/url(/images/dev_button.png)/;/}/#preload_about_button/{/background-image/:/url(/images/about_button.png)/;/}/#preload_home_button_hover/{/background-image/:/url(/images/home_button_hover.png)/;/}/#preload_blog_button_hover/{/background-image/:/url(/images/blog_button_hover.png)/;/}/#preload_dev_button_hover/{/background-image/:/url(/images/dev_button_hover.png)/;/}/#preload_about_button_hover/{/background-image/:/url(/images/about_button_hover.png)/;/}/#preload_dload_button_hover/{/background-image/:/url(/images/dload_button_hover.png)/;/}^", [res description]);
}

@end
