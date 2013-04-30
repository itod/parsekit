MGTemplateEngine
By Matt Legend Gemmell
http://mattgemmell.com/ 



What is it?
-----------

MGTemplateEngine is a native Cocoa system for generating text output based on templates and data. It's a close cousin of systems like Smarty, FreeMarker, Django's template language, and other such systems.

The default syntax for markers (functions or language-constructs) is:

	{% for 1 to 5 %} foo {% /for %}

and the default syntax for variables/expressions is:

	{{ foo.bar | uppercase }}

The pipe-character indicates a filter is being applied; i.e. the value of "foo.bar" will then be fed to the "uppercase" filter before being displayed. You can apply filters to markers as well as variables.

The marker, variable and filter delimiters are completely customizable, so you're not stuck with the defaults if you prefer different syntax.



Features
--------

MGTemplateEngine offers the following features:

* Native Cocoa implementation. It doesn't use the Scripting Bridge or any external runtimes/frameworks, and as such the core engine itself has no requirements other than Mac OS X Leopard.

* Very customizable. It's very easy to define new markers (like functions or language-constructs) and new filters (data-formatting capabilities). You can also freely change the syntax of the markers and expressions to suit your own tastes, or to mimic your favorite other templating system.

* Delegate system to keep you informed. MGTemplateEngine can optionally inform a delegate object of significant events during processing of a template, including beginning/ending blocks, or encountering errors.

* Global and template-specific variables. You can define a set of variables which exist for the lifetime of the engine, and also specify variables which only apply to a certain template.

* Access variables using familiar Key-Value Coding (KVC) key-paths, with enhancements. For example, if you had an NSDictionary containing an NSArray for the key "foo", and that array contained 5 NSDictionaries, each of which had an NSString for the key "bar", you could access the value of the fifth dictionary's "bar" object using this syntax:

	foo.4.bar (remembering that array indices are zero-based!)



Requirements
------------

MGTemplateEngine requires Mac OS X 10.5 (Leopard) or later.



License
-------

Please see the included Source Code License file for the license this code is released under. Summary: it's an attribution license. Credit me, and you can freely use, modify and redistribute in source or binary forms as you see fit. Closed-source/commercial use is absolutely fine.



Extensibility
-------------

MGTemplateEngine offers 3 main types of extensibility, as detailed below. You should also read the included documents specific to each API for more details.

1. Markers. You can create new markers, which provide new tags for use in templates. Markers can be standalone or can be complex blocks (like if-else-/if), can iterate/loop, enable or disable output, set new variables within their scope, and much more.

2. Filters. Filters modify data for display purposes, for example the built-in "date_format" filter which formats an NSDate as a string using a specified formatting definition. You can easily write new filters to format/transform your data in new ways.

3. Matchers. A matcher is a very important object which performs a conceptually simple task: it finds the next marker or expression in a template, and splits it into its components (such as the marker name or variable, extra arguments, and any filter specified). MGTemplateEngine ships with two matchers which you can choose between, or implement your own:

* RegexKitLIte. This matcher uses RegexKitLite, which is a thin wrapper on libicucore.dylib, included with Mac OS X 10.5 and later. This matcher does not require any additional frameworks or libraries to be included in your application, though you must of course link against libicucore. The sample project does this.

* RegexKit. This matcher uses RegexKit, which is a framework wrapping the PCRE regular-expressions library. This matcher requires RegexKit to be included in your application.

You can freely write your own matcher if you don't want to link against libicucore, or don't want to include RegexKit in your application. For example, you could write a matcher which uses NSScanner, or one which uses OgreKit instead.



Standard language features
--------------------------

All language features are implemented as plug-in markers, so you can freely inspect and modify how they work. At time of writing, MGTemplateEngine supports the following constructs:

* for x to y : A standard for-loop beginning at x and incrementing a loop-variable each time through the loop until y is reached. You can also append "reversed" to the command to go from the second value down to the first.

* for p in q : Creates a new variable p which has each of the values in the collection q successively. You can also append "reversed" to the command to go from last to first (only works for ordered collections which supply a reverseObjectEnumerator, i.e. NSArray and its subclasses).

Note: both "for" constructs provide several useful variables during the body of the loop, including currentLoop.currentIndex, currentLoop.startIndex and so on, including currentLoop.parentLoop if appropriate.

* if x / if x == y - else - /if: A standard if-/if or if-else-/if conditional construct. The arguments to the if-statement are processed either as boolean truth-values or numerical comparisons, and can be:

	* x
	* x == y 
	* x = y (same as ==)
	* x and y
	* x && y (same as and)
	* x or y
	* x || y (same as or)
	* x < y, x > y, x <= y, x >= y
	* x % y  (returns false if x/y has no remainder, otherwise true)

* now : creates an NSDate object for the current date and time.

* literal : begins a block of literal text, within which no markers/expressions will be interpreted, and will instead be echoed directly to the output. Ends with a /literal marker.

* comment : with no arguments, begins a block comment which ends upon encountering /comment. With 1 or more arguments, this is treated as a self-contained comment.

* section : begins a named block of the template. When combined with the delegate methods for being informed of blocks beginning and ending, this is useful for being notified of the position and length of certain named blocks in a template, perhaps for extraction and further processing.

* load : takes a space-separated list of classnames, and will attempt to load them as markers/filters as appropriate. The classes will only be instantiated if they exist, and if they implement either the MGTemplateMarker or MGTemplateFilter protocol as appropriate, and if they haven't already been loaded.

* cycle : takes a space-separate list of arguments (can be quoted if they contain whitespace), which will be alternated between each time the cycle marker is visited. This is useful within a loop for outputting the next in a set of values each time, for example for alternating row colors or such.

* set : takes two arguments, the first being a variable-name and the second being a value to set that variable to. Note: remember that variables are scoped within the current block by default, so if you want a variable to survive outwith the current block you should set it to an initial value in the template-variables or global variables before beginning to process the template.



Standard data filters
---------------------

There are a few standard filters currently included with MGTemplateEngine, and you can easily add your own. The standard ones are:

* uppercase, lowercase, capitalized : Returns a string representation of the value, case-transformed as appropriate.

* date_format : takes a string with formatting characters to format an NSDate object (for example, obtained via the "now" marker). The formatting system used is NSDateFormatter in 10.4+ mode, i.e. as detailed here:
http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns

* color_format : takes a string representing the format to convert the given NSColor object to. The only currently support value is "hex", which provides a web-suitable 6-digit RRGGBB hexadecimal representation of the color (if it could be converted to RGB, and black otherwise).



Feature Requests and Bug Reports
--------------------------------

Please submit any feature requests or bug reports to me via email; you can find my address on the About page of my site, here: http://mattgemmell.com/about 

I hope you enjoy using MGTemplateEngine!

Cheers,
-Matt Legend Gemmell

http://mattgemmell.com/ 
