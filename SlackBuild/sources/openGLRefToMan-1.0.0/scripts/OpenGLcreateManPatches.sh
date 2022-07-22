# !/bin/bash

# OpenGLcreateManPatches.sh - creates patch files for corrected man pages
# Copyright © 2021 Necib ÇAPAR <necipcapar@gmail.com>

# This file is part of openGLRefToMan

# openGLRefToMan is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# openGLRefToMan is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Usage: ./OpenGLcreateManPatches.sh ORIGINAL_FILE_PATH CORRECTED_FILE_PATH... PATCH_FILE_PATH"
#
#                                CORRECTED_FILE_PATH can be a single directory without any sub-directories storing corrected man files (use 'directory_path'
#                                                                                                                                                  OR           
#                                                                                                                                           'directory_path/'
#
#                                CORRECTED_FILE_PATH can be a single directories with sub-directories each storing corrected man files (use 'directory_path/*' )

# Check the presence of required commands
type -a echo     > /dev/null 2>&1 || { echo 2>&1 "'echo' is required but NOT installed. Aborting!"; exit 5; }
type -a diff     > /dev/null 2>&1 || { echo 2>&1 "'diff' is required but NOT installed. Aborting!"; exit 6; }
type -a basename > /dev/null 2>&1 || { echo 2>&1 "'basename' is required but NOT installed. Aborting!"; exit 7; }
type -a shift    > /dev/null 2>&1 || { echo 2>&1 "'shift' is required but NOT installed. Aborting!"; exit 8; }
type -a gzip     > /dev/null 2>&1 || { echo 2>&1 "'gzip' is required but NOT installed. Aborting!"; exit 9; }

# Check for required # of script arguments
if [ $# -lt 3 ]; then
    echo "Usage: ./OpenGLcreateManPatches.sh ORIGINAL_FILE_PATH CORRECTED_FILE_PATH... PATCH_FILE_PATH"
    exit 1
fi

# Check type of the arguments
arg_num=$#
index=0
while (( $# > 0 )); do

    if [ $# -eq $arg_num ]; then                                                                        # at the 1st argument of the script
	if [ -d "$1" ]; then                                                                            # 1st argument is an existing directory
	    original_file_path="$1"
	else 
	    echo "Usage: ./OpenGLcreateManPatches.sh ORIGINAL_FILE_PATH CORRECTED_FILE_PATH... PATCH_FILE_PATH"
	    echo '                                   ^'
	    echo "                                   Must be an existing path to a directory of man files"
	    exit 2
	fi
    elif [ $# -eq 1 ]; then                                                                             # at the last argument
	if [ -d "$1" ]; then                                                                            # last argument is an existing directory
	    patch_file_path="$1"
	else 
	    echo "Usage: ./OpenGLcreateManPatches.sh ORIGINAL_FILE_PATH CORRECTED_FILE_PATH... PATCH_FILE_PATH"
	    echo '                                                                             ^'
	    echo "                                                                             Must be an existing path to a directory of created patch files"
	    exit 4
	fi
    else                                                                                                # at the argument that is NOT the 1st and the last
	if [ -d "$1" ]; then                                                                            # argument that is NOT the 1st and the last is an existing directory
	    corrected_file_path[$index]="$1"
	    (( index++ ))
	else 
		echo "Usage: ./OpenGLcreateManPatches.sh ORIGINAL_FILE_PATH CORRECTED_FILE_PATH... PATCH_FILE_PATH"
		echo '                                                      ^'
		echo "                                                      Must be an existing path to a directory of corrected man files"
		echo "                                                      $1   is NOT a directory"
		exit 3
	fi
    fi

    shift
done

echo
echo "Beginning the creation of manpage patches"
echo
echo "    Original  Files' Path: $original_file_path"
echo "    Corrected Files' Path: ${corrected_file_path[*]}"
echo "    Patch     Files' Path: $patch_file_path"
echo

# Function Definitions
create_patches_for_a_directory_of_man_files() {
    original_man_files=( $(basename --multiple "$1"/*) )
    corrected_man_files=( $(basename --multiple "$2"/*) )
    diff_count=0

    local i=
    local j=

    for (( i=0; i < ${#original_man_files[*]}; i++ )); do
	for (( j=0; j < ${#corrected_man_files[*]}; j++ )); do
	    if [ "${original_man_files[$i]##*\.}" != "gz" ]; then                                                 # if current man file is NOT gzipped
		if [ "${original_man_files[$i]}_cr" = "${corrected_man_files[$j]}" ]; then
		    diff --new-file --text --unified "$1/${original_man_files[$i]}" "$2/${corrected_man_files[$j]}" >| "$3/${original_man_files[$i]}.diff"
		    (( diff_count++ ))
		    break
		fi
	    else 
		if [ "${original_man_files[$i]%%\.gz}_cr" = "${corrected_man_files[$j]}" ]; then                  # if current man file is gzipped
		    gzip --decompress "$1/${original_man_files[$i]}"                                              # decompress it
		    diff --new-file --text --unified "$1/${original_man_files[$i]%%\.gz}" "$2/${corrected_man_files[$j]}" >| "$3/${original_man_files[$i]%%\.gz}.diff"
		    gzip -9 "$1/${original_man_files[$i]%%\.gz}"                                                  # recompress it
		    (( diff_count++ ))
		    break
		fi
	    fi
	done
    done
    echo "Total Number of '.diff' files created for patching files in '$2': $diff_count"
}

# Process man files
for file_path in ${corrected_file_path[*]}; do
    create_patches_for_a_directory_of_man_files "$original_file_path" "$file_path" "$patch_file_path"
done

echo "The creation of manpage patches successfully finished"
echo 
