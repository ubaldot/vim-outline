vim9script

# Copied and adjusted from Vim distribution

import "./common.vim"
const WaitForAssert = common.WaitForAssert

# Python
const python_file = 'python_testfile.py'
const python_code =<< END
class Dog:
    def speak(self):
        return "Woof!"

class Cat:
    def speak(self):
        return "Meow!"
END


def Generate_testfile(lines: list<string>, src_name: string)
   writefile(lines, src_name)
enddef

def Cleanup_testfile(src_name: string)
   delete(src_name)
enddef

# Tests start here
def g:Test_Python()
  Generate_testfile(python_code, python_file)
  exe $"edit {python_file}"
  WaitForAssert(() => assert_equal('python', &filetype))

  OutlineToggle
  WaitForAssert(() => assert_equal(2, winnr('$')))
  const actual_outline = getline(1, '$')

  var expected_outline =<< END
python_testfile.py
------------------

class Dog:
    def speak(self):
class Cat:
    def speak(self):
END

  assert_equal(expected_outline, actual_outline)

  # test jump
  search('speak')
  search('speak')
  execute "normal \<cr>"

  var expected_buffer = "python_testfile.py"
  var actual_buffer = bufname()
  assert_equal(expected_buffer, actual_buffer)

  var expected_curpos = [0, 6, 1, 0]
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
