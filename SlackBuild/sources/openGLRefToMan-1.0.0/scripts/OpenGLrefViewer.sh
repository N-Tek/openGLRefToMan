#!/bin/bash

# OpenGLrefViewer.sh - Used for viewing converted manpages of OpenGL references repo
# Copyright © 2021 Necib ÇAPAR <necipcapar@gmail.com>

# This file is part of openGLReftoMan

# openGLReftoMan is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# openGLReftoMan is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Usage: ./OpenGLrefViewer.sh PATH_TO_LEAF_MAN_FOLDER

# Checking for required commands
type -a echo  > /dev/null 2>&1 || { echo 2>&1 "'echo' is required but NOT installed. Aborting!"; exit 2; }
type -a read  > /dev/null 2>&1 || { echo 2>&1 "'read' is required but NOT installed. Aborting!"; exit 3; }
type -a man   > /dev/null 2>&1 || { echo 2>&1 "'man' is required but NOT installed. Aborting!"; exit 4; }
type -a shift > /dev/null 2>&1 || { echo 2>&1 "'shift' is required but NOT installed. Aborting!"; exit 5; }

# Check for required # of script arguments
if [ $# -ne 1  -a  $# -ne 2 ]; then
    echo "Usage: ./OpenGLrefViewer.sh [MANPAGE_NUMBER] PATH_TO_LEAF_MAN_FOLDER"
    exit 1
fi

# Check for correctness of the arguments for the script
if [ $# -eq 1 ]; then
    manpage_number=0
else                                                                                # Check the 1st argument of script while having 2 arguments
    is_uint_case() { case $1 in ''|*[!0-9]*) return 1;; esac }

    if is_uint_case "$1"; then                                                            # 1st argument of script is an integer while having 2 arguments
	manpage_number="$1"
	shift
    else                                                                                  # 1st argument of script is NOT an integer while having 2 arguments
	echo "Usage: ./OpenGLrefViewer.sh [MANPAGE_NUMBER] PATH_TO_LEAF_MAN_FOLDER"
	echo '                             ^'
	echo "                             Must be an integer >0"
	exit 2
    fi
fi

# Check 1st argument while having 1 argument and 2nd argument while having 2 arguments
directories=( $(ls -1 "$(dirname "$1")" | grep '^\(es\|gl\)[1-4]\.*[0-9]*$') )               # should be  directories=("es1.1" "es2.0" "es3" "es3.0" "es3.1" "gl2.1" "gl4")
if [ ! -d "$1" -o -z "${directories[*]}"  ]; then
    echo "Invalid PATH_TO_REPOSITORY entry"
    exit 3
fi

total_file_count=$(ls -1 "$1" | wc -l)

# Check the value of 1st argument while having 2 arguments
if (( $manpage_number >= $total_file_count )); then
	echo "Usage: ./OpenGLrefViewer.sh [MANPAGE_NUMBER] PATH_TO_LEAF_MAN_FOLDER"
	echo '                             ^'
	echo "                             Must be <$total_file_count"
	exit 4
fi

# View files in PATH_TO_LEAF_MAN_FOLDER
current_file_count=1
for i in "$1"/*
do
    if (( $current_file_count < $manpage_number )); then
	(( current_file_count++ ))
	continue
    fi

    read -n 1 -p "[$current_file_count of $total_file_count] Will view '${i##*/}' manpage >>> Q or q to quit <<< "
    case "$REPLY"
	in
	'') man ./$i ;;
	[qQ]) echo ; break ;;
    esac
    (( current_file_count++ ))
    echo
done
