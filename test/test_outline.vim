vim9script

# Copied and adjusted from Vim distribution

import "./common.vim"
const WaitForAssert = common.WaitForAssert

def Generate_testfile(lines: list<string>, src_name: string)
   writefile(lines, src_name)
enddef

def Cleanup_testfile(src_name: string)
   delete(src_name)
enddef

# Tests start here
def g:Test_python()

  const python_file = 'python_testfile.py'
  const python_code =<< trim END
"""
This module handles various types of data processing tasks.
It contains classes that implement similar method names.
"""

# Import necessary modules
import math

# This is a utility constant
PI = math.pi

class DataProcessor:
    """ Handles basic data processing."""

    def __init__(self, data):
        """
        Initializes the processor with data.
        """
        self.data = data  # Store the input data

    def process(self):
        """
        Processes the data by summing the elements.
        """
        # Simple summing operation
        return sum(self.data)


class StringProcessor:
    """ Processes string-based data.
    """

    def __init__(self, text):
        """
        Initializes with a string of text.
        """
        self.text = text

    def process(self):
        """
        Processes the string by reversing it.
        """
        # Reverse the text
        return self.text[::-1]
    def bar():
      pass


class AdvancedProcessor(DataProcessor):
    """
    An advanced processor that overrides the base `process` method.
    """

    def process(self):
        """
        Processes the data using a more complex formula.
        """
        # Compute the square of the sum
        total = super().process()  # Call base method
        return total ** 2
    def foo():
      pass

# Standalone function
def process():
    """
    This is a standalone process function, not a method.
    """
    # Just a demo print
    print("Standalone processing...")

class Dog:
    def speak(self):
        return "Woof!"

class Cat:
    def speak(self):
        return "Meow!"
END

  Generate_testfile(python_code, python_file)
  exe $"edit {python_file}"
  WaitForAssert(() => assert_equal('python', &filetype))

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')

  var expected_outline =<< END
python_testfile.py
------------------

class DataProcessor:
    def process(self):
class StringProcessor:
    def process(self):
    def bar():
class AdvancedProcessor(DataProcessor):
    def process(self):
    def foo():
def process():
class Dog:
    def speak(self):
class Cat:
    def speak(self):
END

  assert_equal(expected_outline, actual_outline)

  # test jump
  normal! gg
  search('process')
  search('process')
  execute "normal \<cr>"

  # GoToDefinition()
  var expected_buffer = "python_testfile.py"
  var actual_buffer = bufname()
  assert_equal(expected_buffer, actual_buffer)

  var expected_curpos = [0, 39, 1, 0]
  var actual_curpos = getpos('.')
  assert_equal(expected_curpos, actual_curpos)

  # Jump back
  OutlineGoToOutline
  expected_buffer = "Outline!"
  actual_buffer = bufname()
  assert_equal(expected_buffer, actual_buffer)

  expected_curpos = [0, 7, 5, 0]
  actual_curpos = getpos('.')
  assert_equal(expected_curpos, actual_curpos)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  # Close from the main buffer
  exe "OutlineToggle"
  WaitForAssert(() => assert_equal(2, winnr('$')))
  wincmd p
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))
  assert_true(empty(v:errors))

  # Check that the filetype is preserved
  assert_equal('python', &filetype)

  :%bw!
  Cleanup_testfile(python_file)
enddef

def g:Test_LaTeX()

  const latex_file = 'latex_testfile.tex'
  const latex_code =<< trim END
% This is a sample LaTeX document
\documentclass{article}

% Packages
\usepackage{amsmath}  % for math
\usepackage{graphicx} % for figures

% Title
\title{An Example LaTeX Document}
\author{Jane Doe}
\date{\today}

\begin{document}

\maketitle

% Introduction
\section{Introduction}
This document provides a basic example of a LaTeX file. We include sections,
math, lists, and comments.

% Main Content
\section{Main Content}

\subsection{Mathematical Expressions}
Here is a simple equation:
\[
E = mc^2
\]

We can also write inline math such as $a^2 + b^2 = c^2$.

\subsection{Lists}

\subsubsection{Itemized List}
\begin{itemize}
  \item Apples
  \item Bananas
  \item Cherries
\end{itemize}

\subsubsection{Enumerated List}
\begin{enumerate}
  \item First item
  \item Second item
  \item Third item
\end{enumerate}

\subsection{Figures}
Here we include a placeholder for a figure:

\begin{figure}[h]
  \centering
  % \includegraphics[width=0.5\textwidth]{example.png}
  \caption{An example figure (image not included).}
  \label{fig:example}
\end{figure}

\section{Conclusion}
This is a basic structure of a LaTeX document. You can expand it by adding
tables, references, and custom formatting as needed.

% End of document
\end{document}
END

  var expected_outline =<< END
latex_testfile.tex
------------------

Introduction
Main Content
  Mathematical Expressions
  Lists
    Itemized List
    Enumerated List
  Figures
Conclusion
END

  Generate_testfile(latex_code, latex_file)
  exe $"edit {latex_file}"
  WaitForAssert(() => assert_equal('tex', &filetype))

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')
  assert_equal(expected_outline, actual_outline)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(latex_file)
enddef

def g:Test_markdown()

  const markdown_file = 'markdown_testfile.md'
  const markdown_code =<< trim END
# Project Title

Welcome to this sample Markdown document. This is an example to show different
heading levels.

## Introduction

This section introduces the topic.

Markdown supports:

- Plain text
- _Italic_, **bold**, and **_bold italic_**
- `inline code`

## Installation

### Requirements

- Python 3.11
- Git
- Make

### Steps

1. Clone the repository
2. Install dependencies
3. Run `make install`

## Usage

### Command Line

```bash
python main.py --input data.csv
```
END

const expected_outline =<< END
markdown_testfile.md
--------------------

Project Title
  Introduction
  Installation
    Requirements
    Steps
  Usage
    Command Line
END

  Generate_testfile(markdown_code, markdown_file)
  exe $"edit {markdown_file}"
  WaitForAssert(() => assert_equal('markdown', &filetype))

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')
  assert_equal(expected_outline, actual_outline)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(markdown_file)
enddef

def g:Test_vim()

  const vim_file = 'vim_testfile.vim'
  const vim_code =<< trim END
vim9script

# Define a global variable
var counter = 0

# Define a function to increment and display the counter
def IncrementCounter()
  counter += 1
  echo 'Counter is now: ' .. counter
enddef

# Define a command that calls the function
command Increment call IncrementCounter()

# Define a mapping in normal mode to call the command
nnoremap <leader>i :Increment<cr>

# Print a message when the script is sourced
echo 'Vim9 script loaded. Press <leader>i to increment the counter.'
END

const expected_outline =<< END
vim_testfile.vim
----------------

def IncrementCounter()
command Increment call IncrementCounter()
nnoremap <leader>i :Increment<cr>
END

  Generate_testfile(vim_code, vim_file)
  exe $"edit {vim_file}"
  WaitForAssert(() => assert_equal('vim', &filetype))

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')
  assert_equal(expected_outline, actual_outline)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(vim_file)
enddef


def g:Test_java()

  const java_file = 'java_testfile.java'
  const java_code =<< trim END
// File: SampleOutlineTest.java

package com.example.parser;

// Import section
import java.util.List;
import java.util.ArrayList;

/**
 * This is a sample Java file for testing a parser that builds
 * an outline (structure) of Java files.
 */
public class SampleOutlineTest {

    // ==========================
    // == Fields ==
    // ==========================

    private String name; // Instance variable
    protected int count = 0;
    public static final double VERSION = 1.0;

    // ==========================
    // == Constructors ==
    // ==========================

    /**
     * Default constructor
     */
    public SampleOutlineTest() {
        this.name = "default";
    }

    /**
     * Overloaded constructor
     * @param name The name to initialize with
     */
    public SampleOutlineTest(String name) {
        this.name = name;
    }

    // ==========================
    // == Methods ==
    // ==========================

    /**
     * Gets the name.
     * @return The name
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the name.
     * @param name The new name
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * Increments the count
     */
    public void increment() {
        count++;
    }

    /**
     * Main method for testing
     */
    public static void main(String[] args) {
        SampleOutlineTest test = new SampleOutlineTest("ParserTest");
        test.increment();
        System.out.println("Name: " + test.getName());
    }

    // ==========================
    // == Nested Class ==
    // ==========================

    /**
     * A nested static class
     */
    public static class Helper {

        private List<String> logs = new ArrayList<>();

        /**
         * Logs a message
         * @param message The message to log
         */
        public void log(String message) {
            logs.add(message);
        }

        /**
         * Prints all logs
         */
        public void printLogs() {
            for (String log : logs) {
                System.out.println(log);
            }
        }
    }
}
END

  Generate_testfile(java_code, java_file)
  exe $"edit {java_file}"
  WaitForAssert(() => assert_equal('java', &filetype))

const expected_outline =<< END
java_testfile.java
------------------

public class SampleOutlineTest {
    private String name; // Instance variable
    protected int count = 0;
    public static final double VERSION = 1.0;
    public SampleOutlineTest() {
    public SampleOutlineTest(String name) {
    public String getName() {
    public void setName(String name) {
    public void increment() {
    public static void main(String[] args) {
    public static class Helper {
        private List<String> logs = new ArrayList<>();
        public void log(String message) {
        public void printLogs() {
END

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')
  assert_equal(expected_outline, actual_outline)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(java_file)
enddef

def g:Test_go()

  const go_file = 'go_testfile.go'
  const go_code =<< trim END
// File: sample_outline_test.go

package main

import (
	"fmt"
	"strings"
)

// ==========================
// == Constants and Globals ==
// ==========================

// VERSION is the current version of the parser test
const VERSION = "1.0"

// globalCount is a global variable
var globalCount int = 0

// ==========================
// == Structs and Methods ==
// ==========================

// SampleOutlineTest is a struct used for testing
type SampleOutlineTest struct {
	Name  string
	Count int
}

// NewSampleOutlineTest is a constructor-like function
func NewSampleOutlineTest(name string) *SampleOutlineTest {
	return &SampleOutlineTest{
		Name:  name,
		Count: 0,
	}
}

// Increment increases the internal counter
func (s *SampleOutlineTest) Increment() {
	s.Count++
}

// GetName returns the name
func (s *SampleOutlineTest) GetName() string {
	return s.Name
}

// SetName sets the name
func (s *SampleOutlineTest) SetName(name string) {
	s.Name = name
}

// ==========================
// == Interface ==
// ==========================

// Logger is a simple interface for logging messages
type Logger interface {
	Log(message string)
	PrintLogs()
}

// ==========================
// == Struct Implementing Interface ==
// ==========================

// Helper implements the Logger interface
type Helper struct {
	Logs []string
}

// Log adds a message to the log
func (h *Helper) Log(message string) {
	h.Logs = append(h.Logs, message)
}

// PrintLogs prints all logs
func (h *Helper) PrintLogs() {
	for _, log := range h.Logs {
		fmt.Println(log)
	}
}

// ==========================
// == Main Function ==
// ==========================

func main() {
	test := NewSampleOutlineTest("ParserTest")
	test.Increment()
	fmt.Println("Name:", test.GetName())

	helper := &Helper{}
	helper.Log("Initialized helper")
	helper.Log("Running main function")
	helper.PrintLogs()

	// Nested function example
	printUpper := func(input string) {
		fmt.Println(strings.ToUpper(input))
	}
	printUpper("done")
}
END

  Generate_testfile(go_code, go_file)
  exe $"edit {go_file}"
  WaitForAssert(() => assert_equal('go', &filetype))

const expected_outline =<< END
go_testfile.go
--------------

type SampleOutlineTest struct {
func NewSampleOutlineTest(name string) *SampleOutlineTest {
func (s *SampleOutlineTest) Increment() {
func (s *SampleOutlineTest) GetName() string {
func (s *SampleOutlineTest) SetName(name string) {
type Logger interface {
type Helper struct {
func (h *Helper) Log(message string) {
func (h *Helper) PrintLogs() {
func main() {
END

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')
  assert_equal(expected_outline, actual_outline)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(go_file)
enddef

def g:Test_odin()

  const odin_file = 'odin_testfile.odin'
  const odin_code =<< trim END
// File: sample_outline_test.odin

package main

import "core:fmt"

// ==========================
// == Constants and Globals ==
// ==========================

VERSION: string : "1.0" // Global constant
global_count: int = 0   // Global variable

// ==========================
// == Enum Declaration ==
// ==========================

LogLevel :: enum {
    Info,
    Warning,
    Error,
}

// ==========================
// == Struct and Methods ==
// ==========================

SampleOutlineTest :: struct {
    name: string,
    count: int,
}

// Constructor-like function
new_sample_outline_test :: proc(name: string) -> SampleOutlineTest {
    return SampleOutlineTest{
        name = name,
        count = 0,
    };
}

// Method-like procedure using receiver
increment :: proc(s: ^SampleOutlineTest) {
    s.count += 1;
}

get_name :: proc(s: SampleOutlineTest) -> string {
    return s.name;
}

set_name :: proc(s: ^SampleOutlineTest, name: string) {
    s.name = name;
}

// ==========================
// == Interface Equivalent ==
// ==========================

// Odin doesn't have traditional interfaces, but we can simulate behavior via procedures

Logger :: struct {
    log      : proc(message: string),
    print_all: proc(),
}

// ==========================
// == Struct with Callbacks ==
// ==========================

Helper :: struct {
    logs: []string,
}

log_message :: proc(h: ^Helper, message: string) {
    h.logs = append(h.logs, message);
}

print_logs :: proc(h: Helper) {
    for log in h.logs {
        fmt.println(log);
    }
}

// ==========================
// == Main Procedure ==
// ==========================

main :: proc() {
    test := new_sample_outline_test("ParserTest");
    increment(&test);
    fmt.println("Name: ", get_name(test));

    helper := Helper{logs = {}};
    log_message(&helper, "Helper initialized");
    log_message(&helper, "Main running");
    print_logs(helper);

    // Nested procedure (closure-style)
    print_upper := proc(input: string) {
        fmt.println(to_upper(input));
    };

    print_upper("done");
}
END
  Generate_testfile(odin_code, odin_file)
  exe $"edit {odin_file}"
  WaitForAssert(() => assert_equal('odin', &filetype))

const expected_outline =<< END
odin_testfile.odin
------------------

LogLevel :: enum {
SampleOutlineTest :: struct {
increment :: proc(s: ^SampleOutlineTest) {
Logger :: struct {
Helper :: struct {
main :: proc() {
END

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')
  assert_equal(expected_outline, actual_outline)

  # Close Outline
  exe "OutlineToggle"
  assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(odin_file)
enddef
