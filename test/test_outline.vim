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
