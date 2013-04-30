MGTemplateEngine - Writing your own Filters



Filters are simple objects which take an NSObject and transform it in some way, commonly returning an NSString which will be directly added to the output from the template. Filters must conform to the MGTemplateFilter protocol, as follows:

- (NSArray *)filters;
- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value;

The first method returns an NSArray of the filters which your object provides. Each filter is an NSString which must not contain any whitespace. Duplicates are obviously not allowed (each filter must be globally unique, not just unique within your own filter object). If a filter already exists with a certain name, your version will be ignored.

The second method is where the action happens. You'll be passed the name of the filter which was invoked (which will always be one of the names you returned from the -filters method), an array of arguments which were specified for the filter, and the current value of the marker or variable which had the filter applied.

You should assume that whatever you return will be output directly in the results of processing the template (via [NSString stringWithFormat:@"%@", returnValue]).

You can look at the standard filters included with MGTemplateEngine to see some simple examples. If you create a useful new filter, please contact me and I'll include it in the MGTemplateEngine distribution.
