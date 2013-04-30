//
//  RegexKitTemplateMatcher.m
//
//  Created by Matt Gemmell on 12/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import "RegexKitTemplateMatcher.h"

@implementation RegexKitTemplateMatcher


+ (RegexKitTemplateMatcher *)matcherWithTemplateEngine:(MGTemplateEngine *)theEngine
{
	return [[[RegexKitTemplateMatcher alloc] initWithTemplateEngine:theEngine] autorelease];
}


- (id)initWithTemplateEngine:(MGTemplateEngine *)theEngine
{
	if (self = [super init]) {
		self.engine = theEngine; // weak ref
	}
	
	return self;
}


- (void)dealloc
{
	self.engine = nil;
	self.templateString = nil;
	self.markerStart = nil;
	self.markerEnd = nil;
	self.exprStart = nil;
	self.exprEnd = nil;
	self.filterDelimiter = nil;
	self.regex = nil;
	
	[super dealloc];
}


- (void)engineSettingsChanged
{
	// This method is a good place to cache settings from the engine.
	self.markerStart = engine.markerStartDelimiter;
	self.markerEnd = engine.markerEndDelimiter;
	self.exprStart = engine.expressionStartDelimiter;
	self.exprEnd = engine.expressionEndDelimiter;
	self.filterDelimiter = engine.filterDelimiter;
	self.templateString = engine.templateContents;
	
	RKCompileOption options = RKCompileMultiline;
	// Note: the \Q ... \E syntax makes PCRE treat everything inside it as literals.
	// This help us in the case where the marker/filter delimiters have special meaning 
	// in regular expressions; notably the "$" character in the default marker start-delimiter.
	NSString *basePattern = @"(\\Q%@\\E)(?:\\s+)?(.*?)(?:(?:\\s+)?\\Q%@\\E(?:\\s+)?(.*?))?(?:\\s+)?\\Q%@\\E";
	NSString *mrkrPattern = [NSString stringWithFormat:basePattern, self.markerStart, self.filterDelimiter, self.markerEnd];
	NSString *exprPattern = [NSString stringWithFormat:basePattern, self.exprStart, self.filterDelimiter, self.exprEnd];
	NSString *regexPattern = [NSString stringWithFormat:@"(?:%@|%@)", mrkrPattern, exprPattern];
	
	self.regex = [RKRegex regexWithRegexString:regexPattern options:options];
}


- (NSDictionary *)firstMarkerWithinRange:(NSRange)range
{
	NSRange matchRange = [self.templateString rangeOfRegex:self.regex inRange:range capture:0];
	NSMutableDictionary *markerInfo = nil;
	if (matchRange.location != NSNotFound) {
		markerInfo = [NSMutableDictionary dictionary];
		[markerInfo setObject:[NSValue valueWithRange:matchRange] forKey:MARKER_RANGE_KEY];
		
		// Found a match. Obtain marker string.
		NSString *matchString = [self.templateString substringWithRange:matchRange];
		NSRange localRange = NSMakeRange(0, [matchString length]);
		//NSLog(@"mtch: \"%@\"", matchString);
		
		// Find type of match
		NSString *matchType = nil;
		NSRange mrkrSubRange = [matchString rangeOfRegex:regex inRange:localRange capture:1];
		BOOL isMarker = (mrkrSubRange.location != NSNotFound); // only matches if match has marker-delimiters
		int offset = 0;
		if (isMarker) {
			matchType = MARKER_TYPE_MARKER;
		} else  {
			matchType = MARKER_TYPE_EXPRESSION;
			offset = 3;
		}
		[markerInfo setObject:matchType forKey:MARKER_TYPE_KEY];
		
		// Split marker string into marker-name and arguments.
		NSRange markerRange = [matchString rangeOfRegex:regex inRange:localRange capture:2 + offset];
		
		if (markerRange.location != NSNotFound) {
			NSString *markerString = [matchString substringWithRange:markerRange];
			NSArray *markerComponents = [self argumentsFromString:markerString];
			if (markerComponents) {
				[markerInfo setObject:[markerComponents objectAtIndex:0] forKey:MARKER_NAME_KEY];
				int count = [markerComponents count];
				if (count > 1) {
					[markerInfo setObject:[markerComponents subarrayWithRange:NSMakeRange(1, count - 1)] 
								   forKey:MARKER_ARGUMENTS_KEY];
				}
			}
			
			// Check for filter.
			NSRange filterRange = [matchString rangeOfRegex:regex inRange:localRange capture:3 + offset];
			if (filterRange.location != NSNotFound) {
				// Found a filter. Obtain filter string.
				NSString *filterString = [matchString substringWithRange:filterRange];
				
				// Convert first : plus any immediately-following whitespace into a space.
				localRange = NSMakeRange(0, [filterString length]);
				NSString *space = @" ";
				filterString = [filterString stringByMatching:@":(?:\\s+)?" inRange:localRange 
													  replace:1 withReferenceString:space];
				
				// Split into filter-name and arguments.
				NSArray *filterComponents = [self argumentsFromString:filterString];
				if (filterComponents) {
					[markerInfo setObject:[filterComponents objectAtIndex:0] forKey:MARKER_FILTER_KEY];
					int count = [filterComponents count];
					if (count > 1) {
						[markerInfo setObject:[filterComponents subarrayWithRange:NSMakeRange(1, count - 1)] 
									   forKey:MARKER_FILTER_ARGUMENTS_KEY];
					}
				}
			}
		}
	}
	
	return markerInfo;
}


- (NSArray *)argumentsFromString:(NSString *)argString
{
	// Extract arguments from argString, taking care not to break single- or double-quoted arguments,
	// including those containing \-escaped quotes.
	// Note: the (?J) prefix is a PCRE flag meaning "allow duplicate capture-names".
	NSString *argsPattern = @"(?J)(?:\"(?<arg>.*?)(?<!\\\\)\"|'(?<arg>.*?)(?<!\\\\)'|(?<arg>\\S+))";
	RKEnumerator *matches = [argString matchEnumeratorWithRegex:argsPattern];
	NSMutableArray *args = [NSMutableArray array];
	while ([matches nextRanges] != NULL) {
		NSRange captureRange = [matches currentRangeForCaptureName:@"arg"];
		if (captureRange.location != NSNotFound) {
			[args addObject:[argString substringWithRange:captureRange]];
		}
	}
	return args;
}


@synthesize engine;
@synthesize markerStart;
@synthesize markerEnd;
@synthesize exprStart;
@synthesize exprEnd;
@synthesize filterDelimiter;
@synthesize templateString;
@synthesize regex;


@end
