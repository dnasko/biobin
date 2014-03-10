Notes from VTC Course "C Programming 2007"
==========================================

Control Flow
------------
+ Statements and Blocks
+ If Else
+ Else If
+ Switch
+ While Loop
+ For Loop
+ Do While Loop
+ Break and Continue
+ Goto and Labels

### Statements and Blocks
+ An expression with a ";" is a statement
+ Braces {} group statements into a Compound Statement or Block.
+ Braces surround the statemnets of a function definition.
+ Braces surround multilpe statements of loop contructs too.

> main()
> {                         /* No ; here */
>    printf("Hello world\n");
> }                         /* No ; here either */

Here's another example:

> main()
> {
>    while (MyFile != EOF)
>    {
>        printf("Another Record!\n");
>    }
> }

### If-Else

> if (test-expression)
>    TRUE-Statement;
> else
>    FALSE-Statement;

Or with blocks, it would look like this:

> if (test-expression)
> {
>      TRUE-Statement;
>      TRUE-Statement;
> }
> else
> {
>      FALSE-Statement;
>      FALSE-Statement;
> }

### Else-If

This is simple . . .

> if (test-expression)
>    TRUE-Statement;
> else if (test-expression)
>    Statement;
> else if (test-expression)
>    Statement;
> else if (test-expression)
>    Statement;
> else
>    Statement;

You'll find that for a few options, this works fine. When things get a bit bigger or more complicated you'll want to use a switch construct.

### Switch

Easily the most powerful control structure in C.

> switch(expression)  /* HAS TO BE AN INT VALUE */
> {
>     case constant-expression:Statement;
>     case constant-expression:Statement;
>     default: Statement;
> }

### While

> while (expression)
> {
>     Statement;
>     Statement;
>     Statement;
> }


Functions and Program Structure
-------------------------------
+ Basics of functions
+ Functions returning non-integers
+ External variables
+ Scope rules
+ Header files
+ Static variables
+ Register variables
+ Block structure
+ Initialization
+ Recursion
+ The C preprocessor

### Basics of functions
+ Functions break up a program into logical units of work.
+ Allows a dvelopment team to work separtely.
+ Allows independent testing of functionality.
+ All combined together at a link time.

> main () {
>    func1();
>    func2();
>    func3();
> }
> func1 () {
>    return printf("I am function 1\n");
> }

