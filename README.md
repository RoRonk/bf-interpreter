Brainfuck Interpreter
=====================

A simple Brainfuck interpreter written in Assembly (x86-64). This project implements an interpreter for Brainfuck code, which executes Brainfuck programs by parsing and processing the Brainfuck commands.

Features
--------

*   Supports standard Brainfuck commands: `>`, `<`, `+`, `-`, `.`, `,`, `[`, `]`.
*   Memory handling and execution of Brainfuck programs.
*   Written in Assembly (GNU syntax) for a deeper understanding of low-level operations.

How to Build and Run
--------------------

1.  **Clone the repository**:

    ```bash
    git clone https://github.com/RoRonk/bf-interpreter.git
    cd bf-interpreter
    ```

2.  **Build the project**: Use the following command to compile the program:

    ```bash
    gcc -no-pie -o bf_interpreter brainfuck.s
    ```

3.  **Run the program**: After compiling, you can run the Brainfuck interpreter with:

    ```bash
    ./bf_interpreter
    ```
Usage
-----

When ran, add the Brainfuck code you want to execute. The program will output the result based on the Brainfuck commands.

### Example

1.  Compile the program:

    ```bash
    gcc -no-pie -o bf_interpreter brainfuck.s
    ```

2.  Run the program using some input:

    ```bash
    ./bf_interpreter "+[----->+++<]>++.---.++++++."
    ```
    
3.  The output will be:

    ```plaintext
    Hello
    ```
