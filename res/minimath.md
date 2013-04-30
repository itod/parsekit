Hey there, it looks like you're trying to parse text input in Objective-C. You've come to the right place.

ParseKit is a parser generator implemented in Objective-C, which converts grammars into parsers intended for use in Cocoa applications running on iOS or Mac OS X.

With ParseKit, you can define your language with a high-level, easy-to-use, BNF-style grammar, and ParseKit will generate source code for a parser for your language.

Specifically, parsers produced by ParseKit are **recursive descent**, **deterministic**, **packrat**, **LL(k)** (this is, *infinite-lookahead*) parsers written in Objective-C. That's a mouthful, but what it means in practice is that ParseKit offers you a great deal of flexibility and expressive power when designing your grammars, but also produces parsers which exhibit good (linear) performance characteristics at runtime. Also, the Objective-C code produced by ParseKit is clean, readable, and easy to debug or tweak by hand.


The design of ParseKit has been heavily influenced by [ANTLR](http://antlr.org) and a [book by Stephen J Metsker](http://www.amazon.com/Building-Parsers-Java-Steven-Metsker/dp/0201719622).

In this tutorial, I'll show how to use ParseKit to implement a small "MiniMath" expression language in an iOS application.

### Desginging the Grammar

First, let's design a ParseKit grammar for our "MiniMath" language. "MiniMath" should allow expressions like:

    1            // bare numbers
    2 + 2 + 42   // addition (including repetition)
    2 * (2 + 4)  // multiplication and sub-expressions

OK, now that we know what the expected input looks like, let's build the grammar. Every ParseKit grammar has to start with a rule called `@start`. Since MiniMath is an expression language, let's define our `@start` rule as an expression.

    @start = expr;

But how do we define `expr`?

    expr =  ???  // TODO

Rather than designing our grammar from the top down, let's hold that thought, and work from the bottom up instead.

Working from the bottom, we'll start with a rule called `atom`. And since MiniMath deals with numbers, we'll define `atom` as a `Number`.

    atom = Number;

Notice how the rules we define ourselves (like `expr` and `atom`) start with lowercase letters. There are also built-in terminal rules like `Number`, `Word`, `QuotedString` and more. The built-in rules always start with uppercase letters, while the rules we define ourselves must start with lowercase letters.

The built-in `Number` rule matches a series of digits as you would expect. By default, it also matches optional floating-point and exponential parts of a number (this behavior is easily configurable).

Now that we have defined an `atom` rule, let's define a primary expression.

    primary = atom | '(' expr ')';

A `primary` expression is either an atom or a parenthesized sub expression. The parentheses here can be used to alter operator precedence.

Notice how we are using recursion to call our own `expr` rule. There is no problem with that (although in ParseKit grammars, you must always avoid [left recursion](http://en.wikipedia.org/wiki/Left_recursion)). 

Now let's move on to multiplication and addition. As usual, we want multiplication to bind more tightly than addition. Since we are working from the bottom up, we can make multiplication bind more tightly by defining it first.

Let's define multiplication as a primary expression times a primary expression.

    multExpr = primary '*' primary;

But we want to allow repetition in our multiplication expressions, like `2 * 8 * 0`, so we'll change our `multExpr` rule by wrapping the operator and the right-hand side operand in an optional repetition using `*`.

    multExpr = primary ('*' primary)*;

Our addition rule will look very similar:

    addExpr = multExpr ('+' multExpr)*;

Since our addition rule is defined in terms of multiplication operands, this will force multiplication to bind more tightly than addition. 

Now we can define our `expr` rule as an addition expression:

    @start = expr;
    expr = addExpr;

Finally, let's change our grammar to discard unnecessary tokens. The post-fix `!` operator can be used to discard a token which is not needed to compute a result. In the case of MiniMath, we'll want to discard any token that is not a number (all of the literal strings in our grammar).

Here's the complete grammar:

    @start = expr;
    expr = addExpr;
    addExpr = multExpr ('+'! multExpr)*;
    multExpr = primary ('*'! primary)*;
    primary = atom | '('! expr ')'!;
    atom = Number;
    
### Adding Actions to the Grammar

OK, so we designed a grammar for our MiniMath language that can be fed to ParseKit to produce Objective-C source code for our parser.
 
But we don't just want to parse input, we also want to compute a result. The easiest way to do this is to use **grammar actions**. Grammar actions are small pieces of Objective-C source code embedded directly in a ParseKit grammar.

We'll start by adding an Action to the `atom` rule:
 
    atom = Number 
    {
        PKToken *tok = [self.assembly pop]; // pop the Number token
        NSAssert(tok.isNumber, @"a number token just matched in `atom`");
        
        NSNumber *n = @(tok.floatValue);
        [self.assembly push:n];  // push an NSNumber object
    };
    
As you can see, actions are blocks of Objective-C code enclosed in curly braces and placed after any rule reference.  In any action, there is an `assembly` object available which serves as a **stack**. The `assembly`'s stack contains the most recently parsed tokens (instances of `PKToken`), and also serves as a place to store your work as you compute the result.

Actions are executed immediately after their preceeding rule matches. So tokens which have recently been matched are available at the top of the `assembly`'s stack.

In this case, we are popping a number token off the stack, converting it to a float value, and pushing an `NSNumber` back onto the stack for later use.

ParseKit includes some handy macros that can make this code more concise. Here's the `atom` rule and action rewritten using those macros:

    atom = Number { 
        // pop a token off the stack and push it back as a float value 
        PUSH_FLOAT(POP_FLOAT()); 
    };

This shortened action is exactly equivalent to the more verbose version above.
    
Now let's add an action to perform multiplication in the `multExpr` rule:

    multExpr = primary ('*'! primary { 
        NSNumber *rhs = [self.assembly pop];
        NSNumber *lhs = [self.assembly pop];
        NSNumber *n = @([lhs floatValue] * [rhs floatValue]);
        [self.assembly push:n];
    })*;

This action executes immediately after the multiply operator (`*`) and right-hand side `primary` operand have been matched. Since the `*` operator has been discarded,  we can be assured that the top 2 objects on the stack are NSNumbers placed by our `atom` rule action.  

Again, we can use ParseKit's handy built-in macros to simplify our Objective-C action code. Here's the same action simplified:

    multExpr = primary ('*'! primary { 
        PUSH_FLOAT(POP_FLOAT() * POP_FLOAT());
    })*;

Finally, we'll need a similar action for our addition expression rule. Here's the complete grammar including actions:

    @start = expr;
    expr = addExpr;
    addExpr = multExpr ('+'! multExpr {
        PUSH_FLOAT(POP_FLOAT() + POP_FLOAT());
    })*;
    multExpr = primary ('*'! primary { 
        PUSH_FLOAT(POP_FLOAT() * POP_FLOAT());
    })*;
    primary = atom | '('! expr ')'!;
    atom = Number { 
        PUSH_FLOAT(POP_FLOAT()); 
    };
    

### Interlude: Checkout the Example Project (with ParseKit Dependency)

OK, time to [checkout the ParseKit MiniMath Example](https://github.com/itod/ParseKitMiniMathExample/zipball/master) project. This project includes [ParseKit](https://github.com/itod/parsekit) as an external dependency.

### Generating Parser Source Code

Now that our MiniMath grammar is complete, we can use ParseKit to generate Objective-C source code for our parser.

Open the MiniMath Xcode project, then select and run the **ParserGenApp** target.

**ParserGenApp** is actually a target in the embedded ParseKit sub-project, and is the way you convert your ParseKit grammars into Objective-C source code.

Paste the MiniMath grammar into the large text area at the bottom of the ParserGenApp window, and select the options shown below.

![ParserGenApp](http://parsekit.com/github/parsergen.png)

Click the **Generate** button and notice that a [MiniMathParser.h](https://github.com/itod/ParseKitMiniMathExample/blob/master/MiniMath/MiniMathParser.h) [MiniMathParser.m](https://github.com/itod/ParseKitMiniMathExample/blob/master/MiniMath/MiniMathParser.m) file have been created, and appear on your Desktop. You'll need to drag this source code into your app's Xcode project.

![Produced Files](http://parsekit.com/github/files.png)

### Run the MiniMath Example iOS App

Now switch to the **MiniMath** target. This target is an example iOS app with an **input** textfield, **calc** button and a **result** textfield:

![MiniMathApp](http://parsekit.com/github/app_empty.png)

Here's the impelementation of the `calc:` Action attached to the **calc** button:

	- (IBAction)calc:(id)sender {
	    NSString *input = [_inputField text];
    
	    MiniMathParser *parser = [[MiniMathParser alloc] init];
    
	    NSError *err = nil;
	    PKAssembly *result = [parser parseString:input assembler:self error:&err];

	    if (!result) {
	        if (err) NSLog(@"%@", err);
	        return;
	    }
    
	    // print the entire assembly in the result output field
	    [_outputField setText:[result description]];
	}


And here's the app after computing a result:

![MiniMathApp](http://parsekit.com/github/app.png)
