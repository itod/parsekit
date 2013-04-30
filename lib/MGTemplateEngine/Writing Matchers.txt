MGTemplateEngine - Writing your own Matchers



Important considerations
------------------------

A matcher is an object which finds each marker or variable "tag" in a template, and breaks those tags into their component parts (marker or variable, any extra arguments, filter if specified, and any arguments to the filter).

It's obviously very important that your matcher is as flexible as possible, i.e. dealing with varying amounts of whitespace within tags, and so on. Your matcher should also be intelligent about dealing with cases where arguments are single- or double-quoted - possibly containing further escaped quote-marks. Here's a fictitious marker as an example:

{% cpu_load percentage "CPU load is \"roughly\" xxx.yy\%" | uppercase %}

This marker presumably gets the current CPU load, converts it to specified units (in this case a percentage), and then outputs the result according to a formatting string which uses "x"s for figures before the decimal point, and "y"s for figures after the decimal point.

The author of your templates may not have whitespace between the opening marker-delimiters ("{%" in this case) and the start of the tag - or they may have considerable whitespace. Similarly, whitespace between arguments may not be consistent; there might sometimes be a single space, and sometimes a run of spaces or tabs. Your matcher must handle this situation intelligently. A common way to do this is to use regular expressions, as the two included sample matchers do.

Furthermore, a policy of splitting arguments around whitespace will not work properly in the example above, since the formatting-string argument contains whitespace. Your matcher must be careful to take account of quoted strings (both single-quoted and double-quoted), and should notice when a quoted argument contains further escaped quote-marks, and not terminate the argument prematurely.

For these reasons, writing your own matcher is a reasonably complex business. Be certain that the standard matchers don't fit your needs before embarking on writing your own!



The MGTemplateMatcher protocol
------------------------------

The matcher protocol is very simple, and all methods are required:

- (id)initWithTemplateEngine:(MGTemplateEngine *)engine;
- (void)engineSettingsChanged;
- (NSDictionary *)firstMarkerWithinRange:(NSRange)range;

The first method is an initializer giving a reference to the MGTemplateEngine using the matcher. You should keep the engine as a weak reference, to avoid retain cycles.

The second method is called at least once before each template is processed, giving you a chance to cache any engine settings of interest, for performance reasons. This is a good place to cache the marker-delimiters, expression-delimiters, filter-delimiter, and perhaps the template string. See the default matchers for an example.

The third method is where the action happens. You'll be given a range within the template string, and are expected to return either nil for no match, or an NSDictionary containing information about the next match. You are strongly advised to carefully inspect the code of the default matchers to see how this works. You can see a list of all the keys which should be present in this dictionary (along with explanations) in the MGTemplateEngine.h file.

Once again, refer to the code for the default matchers for an example implementation of the protocol. If you create a useful new matcher, please contact me and I'll happily include it in the MGTemplateEngine distribution.
