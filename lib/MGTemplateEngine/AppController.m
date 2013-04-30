//
//  AppController.m
//  MGTemplateEngine
//
//  Created by Matt Gemmell on 19/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import "AppController.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"


@implementation AppController


- (void)awakeFromNib
{
	// Set up template engine with your chosen matcher.
	MGTemplateEngine *engine = [MGTemplateEngine templateEngine];
	[engine setDelegate:self];
	[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
	
	// Set up any needed global variables.
	// Global variables persist for the life of the engine, even when processing multiple templates.
	[engine setObject:@"Hi there!" forKey:@"hello"];
	
	// Get path to template.
	NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"sample_template" ofType:@"txt"];
	
	// Set up some variables for this specific template.
	NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys: 
							   [NSArray arrayWithObjects:
								@"matt", @"iain", @"neil", @"chris", @"steve", nil], @"guys", 
							   [NSDictionary dictionaryWithObjectsAndKeys:@"baz", @"bar", nil], @"foo", 
							   nil];
	
	// Process the template and display the results.
	NSString *result = [engine processTemplateInFileAtPath:templatePath withVariables:variables];
	NSLog(@"Processed template:\r%@", result);
	
	[NSApp terminate:self];
}


// ****************************************************************
// 
// Methods below are all optional MGTemplateEngineDelegate methods.
// 
// ****************************************************************


- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo
{
	//NSLog(@"Started block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo
{
	//NSLog(@"Ended block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine
{
	//NSLog(@"Finished processing template.");
}


- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
{
	NSLog(@"Template error: %@", error);
}


@end
