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

#if PEGKIT
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTypes.h>
#else
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTypes.h>
#endif
#import "NSString+ParseKitAdditions.h"

@interface PKTokenEOF : PKToken {}
+ (PKTokenEOF *)instance;
@end

@implementation PKTokenEOF

static PKTokenEOF *EOFToken = nil;

+ (PKTokenEOF *)instance {
    @synchronized(self) {
        if (!EOFToken) { 
            EOFToken = [[self alloc] initWithTokenType:PKTokenTypeEOF stringValue:@"«EOF»" floatValue:0.0];
        }
    }
    return EOFToken;
}


- (BOOL)isEOF {
    return YES;
}


- (NSString *)description {
    return [self stringValue];
}


- (NSString *)debugDescription {
    return [self description];
}

@end

@interface PKToken ()
- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase;

@property (nonatomic, readwrite) BOOL isNumber;
@property (nonatomic, readwrite) BOOL isQuotedString;
@property (nonatomic, readwrite) BOOL isSymbol;
@property (nonatomic, readwrite) BOOL isWord;
@property (nonatomic, readwrite) BOOL isWhitespace;
@property (nonatomic, readwrite) BOOL isComment;
@property (nonatomic, readwrite) BOOL isDelimitedString;
@property (nonatomic, readwrite) BOOL isURL;
@property (nonatomic, readwrite) BOOL isEmail;
#if PK_PLATFORM_TWITTER_STATE
@property (nonatomic, readwrite) BOOL isTwitter;
@property (nonatomic, readwrite) BOOL isHashtag;
#endif

@property (nonatomic, readwrite) PKFloat floatValue;
@property (nonatomic, readwrite, copy) NSString *stringValue;
@property (nonatomic, readwrite) PKTokenType tokenType;
@property (nonatomic, readwrite, copy) id value;

@property (nonatomic, readwrite) NSUInteger offset;
@property (nonatomic, readwrite) NSUInteger lineNumber;
@end

@implementation PKToken

+ (PKToken *)EOFToken {
    return [PKTokenEOF instance];
}


+ (PKToken *)tokenWithTokenType:(PKTokenType)t stringValue:(NSString *)s floatValue:(PKFloat)n {
    return [[[self alloc] initWithTokenType:t stringValue:s floatValue:n] autorelease];
}


// designated initializer
- (id)initWithTokenType:(PKTokenType)t stringValue:(NSString *)s floatValue:(PKFloat)n {
    //NSParameterAssert(s);
    self = [super init];
    if (self) {
        self.tokenType = t;
        self.stringValue = s;
        self.floatValue = n;
        self.offset = NSNotFound;
        self.lineNumber = NSNotFound;
        
        self.isNumber = (PKTokenTypeNumber == t);
        self.isQuotedString = (PKTokenTypeQuotedString == t);
        self.isSymbol = (PKTokenTypeSymbol == t);
        self.isWord = (PKTokenTypeWord == t);
        self.isWhitespace = (PKTokenTypeWhitespace == t);
        self.isComment = (PKTokenTypeComment == t);
        self.isDelimitedString = (PKTokenTypeDelimitedString == t);
        self.isURL = (PKTokenTypeURL == t);
        self.isEmail = (PKTokenTypeEmail == t);
#if PK_PLATFORM_TWITTER_STATE
        self.isTwitter = (PKTokenTypeTwitter == t);
        self.isHashtag = (PKTokenTypeHashtag == t);
#endif
    }
    return self;
}


- (void)dealloc {
    self.stringValue = nil;
    self.value = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    return [self retain]; // tokens are immutable
}


- (NSUInteger)hash {
    return [stringValue hash];
}


- (BOOL)isEqual:(id)obj {
    return [self isEqual:obj ignoringCase:NO];
}


- (BOOL)isEqualIgnoringCase:(id)obj {
    return [self isEqual:obj ignoringCase:YES];
}


- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase {
    if (![obj isMemberOfClass:[PKToken class]]) {
        return NO;
    }
    
    PKToken *tok = (PKToken *)obj;
    if (tokenType != tok->tokenType) {
        return NO;
    }
    
    if (isNumber) {
        return floatValue == tok->floatValue;
    } else {
        if (ignoringCase) {
            return (NSOrderedSame == [stringValue caseInsensitiveCompare:tok->stringValue]);
        } else {
            return [stringValue isEqualToString:tok->stringValue];
        }
    }
}


- (BOOL)isEOF {
    return NO;
}


- (id)value {
    if (!value) {
        id v = nil;
        if (isNumber) {
            v = [NSNumber numberWithDouble:floatValue];
        } else {
            v = stringValue;
        }
        self.value = v;
    }
    return value;
}


- (NSString *)quotedStringValue {
    return [stringValue stringByTrimmingQuotes];
}


- (NSString *)debugDescription {
    NSString *typeString = nil;
    if (self.isNumber) {
        typeString = @"Number";
    } else if (self.isQuotedString) {
        typeString = @"Quoted String";
    } else if (self.isSymbol) {
        typeString = @"Symbol";
    } else if (self.isWord) {
        typeString = @"Word";
    } else if (self.isWhitespace) {
        typeString = @"Whitespace";
    } else if (self.isComment) {
        typeString = @"Comment";
    } else if (self.isDelimitedString) {
        typeString = @"Delimited String";
    } else if (self.isURL) {
        typeString = @"URL";
    } else if (self.isEmail) {
        typeString = @"Email";
#if PK_PLATFORM_TWITTER_STATE
    } else if (self.isTwitter) {
        typeString = @"Twitter";
    } else if (self.isHashtag) {
        typeString = @"Hashtag";
#endif
    }
    return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, (unichar)0x00AB, self.value, (unichar)0x00BB];
}


- (NSString *)description {
    return stringValue;
}

@synthesize isNumber;
@synthesize isQuotedString;
@synthesize isSymbol;
@synthesize isWord;
@synthesize isWhitespace;
@synthesize isComment;
@synthesize isDelimitedString;
@synthesize isURL;
@synthesize isEmail;
#if PK_PLATFORM_TWITTER_STATE
@synthesize isTwitter;
@synthesize isHashtag;
#endif
@synthesize floatValue;
@synthesize stringValue;
@synthesize tokenType;
@synthesize tokenKind;
@synthesize value;
@synthesize offset;
@synthesize lineNumber;
@end
