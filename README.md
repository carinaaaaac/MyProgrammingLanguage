# Custom Object-Oriented Language Compiler & Interpreter

##  Overview
This project is a custom compiler front-end and interpreter for an original, statically-typed, object-oriented programming language. It is built entirely in **C++** using **Lex/Flex** for lexical analysis and **YACC/Bison** for syntax parsing. 

The system performs rigorous semantic analysis (type checking, scope resolution) and executes code dynamically by building and evaluating an Abstract Syntax Tree (AST) for the program's main execution block.

##  Key Features
* **Primitive Data Types:** Full support for `int`, `float`, `string`, and `bool`.
* **Object-Oriented Programming:** * Class definitions (restricted to the global scope).
  * Object instantiation and initialization.
  * Syntax for accessing class fields and invoking methods.
* **Control Flow Statements:** Supports `if` conditions, `while` loops, assignment operations (`:=`), and function calls.
* **Built-in Functions:** Includes a native `Print(expr)` function for output.
* **Strict Scoping Rules:** * Global scope for class and function definitions.
  * Function/Method scope for local variables.
  * Dedicated `main` block execution (without local variable/function definitions inside).

##  System Architecture

### 1. Lexical & Syntax Analysis (Flex & Bison)
The code is tokenized and parsed according to a custom grammar. The parser enforces syntactic rules, ensuring that variables are not declared inside statement blocks and classes remain in the global scope.

### 2. Symbol Table Management
A hierarchical Symbol Table system tracks identifiers across nested scopes:
* **Global Scope:** Contains classes, global functions, and variables.
* **Class Scope:** Contains methods and fields specific to an object.
* **Function Scope:** Contains parameters and local variables.
* The system automatically generates a comprehensive `tables.txt` file detailing the contents of every scope (names, types, values, and parameters) after parsing.

### 3. Semantic Analysis
The compiler enforces strict rules to guarantee code safety, providing detailed error messages (including line numbers) when violations occur:
* **Definition Checks:** Ensures all variables, functions, and classes are defined before use and prevents redeclaration within the same scope.
* **Class Member Validation:** Verifies that accessed fields and methods actually exist within the specified class instance.
* **Strict Type Checking:** Validates that operands in expressions share the same type (no implicit casting allowed) and that assignment types match.
* **Function Signatures:** Checks that arguments passed to a function/method perfectly match its defined parameters.

### 4. AST Construction & Evaluation (Interpreter)
Instead of generating machine code, the project evaluates the code on the fly:
* **Abstract Syntax Tree (AST):** Constructed for expressions, assignments (`:=`), and `Print()` statements. 
* **Dynamic Evaluation:** The `ASTNode` class features an evaluation method that traverses the tree, resolves variable values from the Symbol Table, applies operators, and returns a universal wrapper object containing the result.
* **Main Block Execution:** The program actively interprets and evaluates the AST nodes corresponding to the statements in the `main` block.

##  Technologies Used
* **C++** (Core logic, AST representation, Symbol Table objects)
* **Flex** (Lexical Analyzer)
* **Bison / YACC** (Parser Generator)

##  How to Build and Run

This project includes a convenient shell script (`compile.sh`) that automates the generation of the lexer/parser, compiles the C++ source code, and runs the interpreter.

1. Ensure the script has execution permissions:
   ```bash
   chmod +x compile.sh

2. To verify the compiler's behavior against various valid and invalid code samples (checking syntax, semantic analysis, and AST evaluation), run the testing script:
   ```bash
   chmod +x runtests.sh
    ./runtests.sh
