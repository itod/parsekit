#import <PEGKit/PEGParser.h>

enum {
    GREEDYFAILURE_TOKEN_KIND_LCURLY = 14,
    GREEDYFAILURE_TOKEN_KIND_RCURLY,
    GREEDYFAILURE_TOKEN_KIND_COLON,
};

@interface GreedyFailureParser : PEGParser

@end

