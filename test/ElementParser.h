#import <ParseKit/PKSParser.h>

enum {
    ELEMENT_TOKEN_KIND_LBRACKET = 14,
    ELEMENT_TOKEN_KIND_RBRACKET,
    ELEMENT_TOKEN_KIND_COMMA,
};

@interface ElementParser : PKSParser

@end

