##Deprecation Notice

I've forked ParseKit into a new faster/cleaner/smaller library called [PEGKit](https://github.com/itod/pegkit).

**ParseKit should be considered deprecated, and PEGKit should be used for all new development.**

ParseKit was originally a very **dynamic** library with poor performance. Over time, I added **static** source code generation features (inspired by [ANTLR](http://www.antlr.org/)) with much better performance.

My new PEKit library eschews all of the dynamic aspects of the original ParseKit library and retains only the new, fast, static code-generation aspects. 

**PEGKit's grammar syntax is very similar to ParseKit.** The differences in PEGKit's grammar syntax are:

1. There is no longer an explicit (redundant) `@start` rule. The first rule defined in your grammar is implicitly recognized as your **start** rule. This simplifies your grammar slightly.
1. **Tokenizer Directives** are removed. Instead, use a `@before` block on your *start* rule to configure your tokenizer behavior with Objective-C code. [An example](https://github.com/itod/pegkit/blob/master/res/crockford.grammar).

The highly dynamic nature of the original ParseKit library may still be usefull in some rare circumstances, but you almost certainly want to use PEGKit for all new development.

## ParseKit

ParseKit is a Mac OS X Framework written by Todd Ditchendorf in Objective-C and released under the Apache 2 Open Source License. ParseKit is suitable for use on iOS or Mac OS X. ParseKit is an Objective-C is heavily influced by [ANTLR](http://www.antlr.org/) by Terence Parr and ["Building Parsers with Java"](http://www.amazon.com/Building-Parsers-Java-Steven-Metsker/dp/0201719622) by Steven John Metsker. Also, ParseKit depends on [MGTemplateEngine](http://mattgemmell.com/2008/05/20/mgtemplateengine-templates-with-cocoa) by Matt Gemmell for its templating features.

The ParseKit Framework offers 3 basic services of general interest to Cocoa developers:

1.  **[String Tokenization](http://parsekit.com/tokenization.html)** via the Objective-C PKTokenizer and PKToken classes.
2.  **High-Level Language Parsing via Objective-C** - An Objective-C parser-building API (the PKParser class and sublcasses).
3.  **[Objective-C Parser Generation via Grammars](http://itod.github.io/ParseKitMiniMathExample/)** - Generate an Objective-C source code for parser for your custom language using a BNF-style grammar syntax (similar to yacc or ANTLR). While parsing, the parser will provide callbacks to your Objective-C code.

More about ParseKit can be found on [ParseKit.com](http://parsekit.com/)