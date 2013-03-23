//
//  TDRegexMatcher.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/2/12.
//
//

#import "TDRegexMatcher.h"
#import "TDRegexAssembler.h"
#import <ParseKit/ParseKit.h>

@interface PKParserFactory ()
@property (nonatomic, assign) BOOL wantsCharacters;
@end

@interface TDRegexMatcher ()
- (PKAssembly *)bestMatchFor:(NSString *)inputStr;

@property (nonatomic, retain) PKParser *parser;
@end

@implementation TDRegexMatcher {
    PKParser *parser;
}

+ (TDRegexAssembler *)regexAssembler {
    static TDRegexAssembler *sAss = nil;
    if (!sAss) {
        sAss = [[TDRegexAssembler alloc] init];
    }
    return sAss;
}


+ (PKParser *)regexParser {
    static PKParser *sRegexParser = nil;
    if (!sRegexParser) {
        
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"regex" ofType:@"grammar"];
        NSString *g = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        NSError *err = nil;
        PKParserFactory *factory = [PKParserFactory factory];
        factory.wantsCharacters = YES;
        sRegexParser = [[factory parserFromGrammar:g assembler:[self regexAssembler] error:&err] retain];
        if (err) {
            NSLog(@"%@", err);
            sRegexParser = nil;
        }
    }
 
    return sRegexParser;
}


+ (TDRegexMatcher *)matcherWithRegex:(NSString *)regex {
    TDRegexMatcher *m = [[[TDRegexMatcher alloc] initWithRegex:regex] autorelease];
    return m;
}


- (id)initWithRegex:(NSString *)regex {
    self = [super init];
    if (self) {
        PKAssembly *a = [PKCharacterAssembly assemblyWithString:regex];
        a = [[[self class] regexParser] completeMatchFor:a];
        PKParser *p = [a pop];
        
        self.parser = p;
    }
    return self;
}


- (void)dealloc {
    self.parser = nil;
    [super dealloc];
}


- (BOOL)matches:(NSString *)inputStr {
    PKAssembly *a = [self bestMatchFor:inputStr];
    return ![a isStackEmpty];
}


- (PKAssembly *)bestMatchFor:(NSString *)inputStr {
    PKAssembly *a = [PKCharacterAssembly assemblyWithString:inputStr];
    a = [self.parser bestMatchFor:a];
    return a;
}

@synthesize parser;
@end
