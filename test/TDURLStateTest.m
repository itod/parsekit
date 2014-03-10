//
//  TDURLStateTest.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/26/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDURLStateTest.h"

@implementation TDURLStateTest

- (void)setUp {
    t = [[PKTokenizer alloc] init];
    URLState = t.URLState;
}


- (void)tearDown {
    [t release];
}


- (void)testSingleW {
    s = @"w";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isWord);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlah {
    s = @"http://foo.com/blah_blah";
    t.string = s;
        
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testDunningDashKruger {
    s = @"http://en.wikipedia.org/wiki/Dunning–Kruger_effect";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahSlash {
    s = @"http://foo.com/blah_blah/";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSomethingLikeFooComBlahBlahSlash {
    s = @"(Something like http://foo.com/blah_blah)";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"Something");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"like");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @")");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahWiki {
    s = @"http://foo.com/blah_blah_(wikipedia)";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahDotHtml {
    s = @"http://foo.com/blah_blah.html";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahWikiDotHtml {
    s = @"http://foo.com/blah_blah_(wikipedia).html";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSomethingLikeFooComBlahBlahWiki {
    s = @"(Something like http://foo.com/blah_blah_(wikipedia))";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"(");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"Something");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"like");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah_(wikipedia)");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @")");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahDot {
    s = @"http://foo.com/blah_blah.";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahComma {
    s = @"http://foo.com/blah_blah,";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @",");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFooComBlahBlahSlashDot {
    s = @"http://foo.com/blah_blah/.";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah/");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtFooComBlahBlahGt {
    s = @"<http://foo.com/blah_blah>";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testLtFooComBlahBlahSlashGt {
    s = @"<http://foo.com/blah_blah/>";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_blah/");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testExampleComArgDot {
    s = @"http://www.example.com/wpstyle/?p=364.";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://www.example.com/wpstyle/?p=364");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testStarDF {
    s = @"http://✪df.ws/123";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testRadarSlashSlash {
    s = @"rdar://1234";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testRadarSlash {
    s = @"rdar:/1234";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUserIdPasswordPort {
    s = @"http://userid:password@example.com:8080";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUserId {
    s = @"http://userid@example.com";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUserIdPort {
    s = @"http://userid@example.com:8080";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUserIdPassword {
    s = @"http://userid:password@example.com";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testExampleComPort {
    s = @"http://example.com:8080";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testYojimbo {
    s = @"x-yojimbo-item://6303E4C1-xxxx-45A6-AB9D-3A908F59AE0E";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testMessage {
    s = @"message://%3c330e7f8409726r6a4ba78dkf1fd71420c1bf6ff@mail.gmail.com%3e";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testArrow {
    s = @"http://➡.ws/䨹";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testWWWArrow {
    s = @"www.➡.ws/䨹";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFakeWWW {
    s = @"wwwp://➡.ws/䨹";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFakeWW {
    s = @"wwp://google.com/䨹";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testFakeW {
    s = @"wp://google.com/䨹";
    t.string = s;
    
    tok = [t nextToken];
    
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testTagExampleComTag {
    s = @"<tag>http://example.com</tag>";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"tag");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (PKFloat)0.0);    
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://example.com");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"<");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @"/");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"tag");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @">");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testJustAnExampleComLinkDot {
    s = @"Just a www.example.com link.";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"Just");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"a");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"www.example.com");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"link");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isSymbol);
    TDEqualObjects(tok.stringValue, @".");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testMoreThanOneParens {
    s = @"http://foo.com/more_(than)_one_(parens)";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testMoreThanOneParensFoo {
    s = @"http://foo.com/more_(than)_one_(parens) foo";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/more_(than)_one_(parens)");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testParensHashCite {
    s = @"http://foo.com/blah_(wikipedia)#cite-1";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testParensHashCiteFoo {
    s = @"http://foo.com/blah_(wikipedia)#cite-1 foo";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/blah_(wikipedia)#cite-1");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUnicodeInParens {
    s = @"http://foo.com/unicode_(✪)_in_parens";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testUnicodeInParensFoo {
    s = @"http://foo.com/unicode_(✪)_in_parens foo";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/unicode_(✪)_in_parens");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSomethingAfterParens {
    s = @"http://foo.com/(something)?after=parens";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(s, tok.stringValue);
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}


- (void)testSomethingAfterParensFoo {
    s = @"http://foo.com/(something)?after=parens foo";
    t.string = s;
    
    tok = [t nextToken];
    TDTrue(tok.isURL);
    TDEqualObjects(tok.stringValue, @"http://foo.com/(something)?after=parens");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDTrue(tok.isWord);
    TDEqualObjects(tok.stringValue, @"foo");
    TDEquals(tok.floatValue, (PKFloat)0.0);
    
    tok = [t nextToken];
    TDEqualObjects([PKToken EOFToken], tok);
}

@end
