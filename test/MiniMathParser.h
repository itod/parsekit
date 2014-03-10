#import <PEGKit/PEGParser.h>

enum {
    MINIMATH_TOKEN_KIND_PLUS = 14,
    MINIMATH_TOKEN_KIND_STAR,
    MINIMATH_TOKEN_KIND_CARET,
};

@interface MiniMathParser : PEGParser

@end

