#!/bin/bash

# Copied and adapted from Vim LSP plugin
# All you have to do is to change the list TESTS_LIST="['test_outline.vim']"
# and rename the various 'outline' around.
#
# To see what is happening, do as it follows:
#   1. Change the command to call Vim in this script to not use interactive
#      mode,
#   2. comment the line at in runner.vim qall! to avoid closing everything
#      immediately
#   3. In the test-cases, secure that you don't :%bw! at the end

GITHUB=1

# No arguments passed, then no exit
if [ "$#" -eq 0 ]; then
  GITHUB=0
fi

VIM_PRG=${VIM_PRG:=$(which vim)}
if [ -z "$VIM_PRG" ]; then
  echo "ERROR: vim (\$VIM_PRG) is not found in PATH"
  if [ "$GITHUB" -eq 1 ]; then
	exit 1
  fi
fi

# Setup dummy VIMRC file
# OBS: You can also run the following lines in the test file because it is
# source before running the tests anyway. See Vim9-conversion-aid
VIMRC="VIMRC"

echo "vim9script" > "$VIMRC"
echo "">> "$VIMRC"
echo "set runtimepath+=.." >> "$VIMRC"
echo "syntax on" >> "$VIMRC"
echo "set nocompatible" >> "$VIMRC"
echo "g:outline_patterns = {text: [(_, val) => val =~ '<KEEP-ME!>']}" >> "$VIMRC"
echo "g:outline_sanitizers = {text: [{'KEEP': 'KISS'}]}" >> "$VIMRC"

# Display vimrc content
echo "----- vimrc content ---------"
cat $VIMRC
echo ""
# Construct the VIM_CMD with correct variable substitution and quoting
#
# -E: Ex mode (no fully interactive UI) - Remove to see something
# s: suppress all warnings and such
# -i: don't use or save and viminfo file
# --not-a-term: non-interactive
#
# VIM_CMD="$VIM_PRG --clean -Es -u $VIMRC -i NONE --not-a-term"
#
# Use the following for checking what is going on
VIM_CMD="$VIM_PRG --clean -u $VIMRC -i NONE --not-a-term"

# Add test files here: OBS! <space> after ','
TESTS_LIST="['test_outline.vim']"

# All the tests are executed in the same Vim instance
eval $VIM_CMD " -c \"vim9cmd g:TestFiles = $TESTS_LIST\" -S runner.vim"

# Check that Vim started and that the runner did its job
if [ $? -eq 0 ]; then
    echo "Vim executed successfully.\n"
else
    echo "Vim execution failed with exit code $?.\n"
		exit 1
fi

# Check the test results
cat results.txt
echo "-------------------------------"
if grep -qw FAIL results.txt; then
	echo "ERROR: Some test(s) failed."
	echo
	if [ "$GITHUB" -eq 1 ]; then
		rm "$VIMRC"
		rm results.txt
		exit 3
	fi
else
	echo "SUCCESS: All the tests  passed."
	echo
	rm "$VIMRC"
	rm results.txt
	exit 0
fi

# kill %- > /dev/null
# vim: shiftwidth=2 softtabstop=2 noexpandtab
