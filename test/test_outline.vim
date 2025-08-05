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
def g:Test_Python()

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

  messages clear
  echom assert_equal(expected_outline, actual_outline)

  # test jump
  normal! gg
  search('process')
  search('process')
  execute "normal \<cr>"

  # GoToDefinition()
  var expected_buffer = "python_testfile.py"
  var actual_buffer = bufname()
  echom assert_equal(expected_buffer, actual_buffer)

  var expected_curpos = [0, 39, 1, 0]
  var actual_curpos = getpos('.')
  echom assert_equal(expected_curpos, actual_curpos)

  # Jump back
  OutlineGoToOutline
  expected_buffer = "Outline!"
  actual_buffer = bufname()
  echom assert_equal(expected_buffer, actual_buffer)

  expected_curpos = [0, 7, 5, 0]
  actual_curpos = getpos('.')
  echom assert_equal(expected_curpos, actual_curpos)

  # Close Outline
  exe "OutlineToggle"
  echom assert_equal(1, winnr('$'))

  :%bw!
  Cleanup_testfile(python_file)
enddef
