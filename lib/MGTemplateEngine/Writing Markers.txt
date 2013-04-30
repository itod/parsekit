MGTemplateEngine - Writing your own Markers



Markers are the most important elements in MGTemplateEngine: they provide all the language constructs like if-statements and loops, and supply the ability to insert dynamically-generated content and so on. Markers can be either standalone, or can create "blocks" (i.e. nested contexts, with a beginning and an end, like for-loops or if-else-/if). There are several rules involved in creating block-type markers, and you are advised to carefully read this documentation and inspect the default markers included with MGTemplateEngine.

Markers must conform to the MGTemplateMaker protocol, as follows:

- (id)initWithTemplateEngine:(MGTemplateEngine *)engine;

This is an initializer, passing a reference to the MGTemplateEngine instance. You should keep this as a weak reference only, to avoid retain cycles.

- (NSArray *)markers;

This method should return an array of markers (each unique across all markers) which this object handles.

- (NSArray *)endMarkersForMarker:(NSString *)marker;

This method will be called if one of your markers starts a block. It should provide an array of the possible corresponding end-markers for the specified marker, i.e. the other markers (which must also be specified in the array returned from the -markers method) which, when encountered during a block started by the specified marker, may possibly end that black or context.

For example, if a block was started by an "if" marker, the markers which might possibly end that block are "else" and "/if". For a block started by a "for" marker, you would return the "/for" marker as a possible/expected ending-marker for that block.

- (NSObject *)markerEncountered:(NSString *)marker withArguments:(NSArray *)args inRange:(NSRange)markerRange blockStarted:(BOOL *)blockStarted blockEnded:(BOOL *)blockEnded outputEnabled:(BOOL *)outputEnabled nextRange:(NSRange *)nextRange currentBlockInfo:(NSDictionary *)blockInfo newVariables:(NSDictionary **)newVariables;

This intimidating-looking method is the core of a marker. Again, you are advised to inspect the default markers for sample implementations, and to carefully read the MGTemplateMarker.h file which details all of these arguments and how they work. In summary:

	marker:			name of the marker encountered by the template engine

	args:			arguments to the marker, in order

	markerRange:		the range of the marker encountered in the engine's templateString

	blockStarted:		pointer to BOOL. Set it to YES if the marker just started a block.

 	blockEnded:		pointer to BOOL. Set it to YES if the marker just ended a block.
				Note: you should never set both blockStarted and blockEnded in the same call.
				This is considered an error, and no block will be started.

	outputEnabled:		pointer to BOOL, indicating whether the engine is currently outputting. Can be changed to switch output on/off.

	nextRange:		the next range in the engine's templateString which will be searched. Can be modified if necessary.

	currentBlockInfo:	information about the current block, if the block was started by this handler; otherwise nil.
				Note: if supplied, will include a dictionary of variables set for the current block.

	newVariables:		variables to set in the template context. If blockStarted is YES, these will be scoped only within the new block.
				Note: if currentBlockInfo was specified, variables set in the return dictionary will override/update any variables of 
				the same name in currentBlockInfo's variables. This is for ease of updating loop-counters or such.

The return value is a value to insert into the template output, or nil if nothing is to be inserted (which is a valid and common situation; for example, a "for" marker does not of itself provide any output).

Important Notes:

1. If your marker is a block-type marker (i.e. if it has a beginning and an end marker, rather than just a single standalone marker), you should be aware that templates may nest those blocks. For example, an "if" marker can be followed by further "if" markers before reaching its own "else" or "/if" marker. This is a useful feature, and is familiar to developers as nested contexts/scopes. Your block markers must be aware of the consequences of this, namely:

1.1. You cannot assume that, for example, the first "/if" marker encountered ends the first "if" encountered - the "/if" may belong to a nested "if". For this reason, you should keep a stack of open blocks of your marker, taking note of the markerRange which started the block, and use the blockInfo dictionary (which contains the range of the marker which started the current block) to check which actual block the current marker corresponds to. The standard markers show how to do this quite simply.

1.2. You must also be aware that templates may incorrectly nest markers, for example forgetting to explicitly end a block. In these situations, you may receive a call to your end-marker but with no blockInfo dictionary. In this case, you're expected to behave sensibly - commonly by simply setting blockEnded to YES, which will cause the templateEngine to inform the delegate of the error condition and continue, having implicitly closed the offending block.

2. If you are starting a block, any newVariables you specify are scoped to that block. This is extremely useful if you want a variable to refer to a parent instance of your block marker, as is the case with the "for" marker (it provides a "parentLoop" variable, if there's another for-loop around the current one). See the default markers for how this works.

3. Needless to say, specifying an invalid nextRange will result in termination of processing the current template. Take care when modifying the nextRange. Note that modifying the nextRange is the means by which you can implement loops in your markers.

4. Obviously, modifying outputEnabled is not guaranteed to enable output, if a parent construct has already disabled it. MGTemplateEngine parses all markers in a template, regardless of whether it is currently outputting, to ensure proper nesting. Thus, even if your marker is inside a branch of an "if" statement which is false and is thus not output, your marker will still be called. You can similarly use the outputEnabled parameter to implement conditional output and branching.



Please submit any API enhancement requests to me by email, and if you create a useful new marker please contact me so I can include it with the MGTemplateEngine distribution.
