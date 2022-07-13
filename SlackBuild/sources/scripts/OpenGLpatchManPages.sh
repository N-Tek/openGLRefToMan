#!/bin/bash

# OpenGLpatchManPages.sh - patches manpages created by using OpenGL repo
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

# Usage: ./OpenGLpatchManPages.sh OLD_FILE_PATH PATCH_FILE_PATH...

# Check the presence of required commands
type -a echo     > /dev/null 2>&1 || { echo 2>&1 "'echo' is required but NOT installed. Aborting!"; exit 4; }
type -a patch    > /dev/null 2>&1 || { echo 2>&1 "'patch' is required but NOT installed. Aborting!"; exit 5; }
type -a basename > /dev/null 2>&1 || { echo 2>&1 "'basename' is required but NOT installed. Aborting!"; exit 6; }
type -a mkdir    > /dev/null 2>&1 || { echo 2>&1 "'mkdir' is required but NOT installed. Aborting!"; exit 7; }
type -a gzip     > /dev/null 2>&1 || { echo 2>&1 "'gzip' is required but NOT installed. Aborting!"; exit 8; }

# Check for required # of script arguments
if [ $# -lt 2 ]; then
    echo "Usage: ./OpenGLpatchManPages.sh OLD_FILE_PATH PATCH_FILE_PATH"
    exit 1
fi

if [ -d "$1" ]; then
    old_file_path="$1"
else 
    echo "Usage: ./OpenGLpatchManPages.sh OLD_FILE_PATH PATCH_FILE_PATH..."
    echo '                                ^'
    echo "                                Must be an existing path to a directory of original manpages"
    exit 2
fi

if [ -d "$2" ]; then
    patch_file_path="$2"
else 
    echo "Usage: ./OpenGLpatchManPages.sh OLD_FILE_PATH PATCH_FILE_PATH..."
    echo '                                              ^'
    echo "                                              Must be an existing path to a directory of patch files"
    exit 3
fi

# Function Definitions
patch_man_files() {
    original_man_files=( $(basename --multiple "$1"/*) )
    patch_files=( $(basename --multiple "$2"/*) )
    patch_count=0

    local i=
    local j=

    mkdir --parents "$1/../patched"                                      # create a directory for copying pathched manpages for further inspection
    for (( i=0; i < ${#original_man_files[*]}; i++ )); do
	for (( j=0; j < ${#patch_files[*]}; j++ )); do
	    if [ "${original_man_files[$i]##*\.}" != "gz" ]; then                                             # if current man file is NOT gzipped
		if [ "${original_man_files[$i]}.diff" = "${patch_files[$j]}" ]; then                          # and has a patch file with a suffix of '.diff'
		    patch --backup --unified "$1/${original_man_files[$i]}" "$2/${patch_files[$j]}"           # patch it
		    cp --archive "$1/${original_man_files[$i]}" "$1/../patched" 
		    (( patch_count++ ))
		    break
		fi
	    else                                                                                              # if current man file in gzipped
		if [ "${original_man_files[$i]%%\.gz}.diff" = "${patch_files[$j]}" ]; then                    # and has a patch file with a suffix of '.diff'
		    gzip --decompress "$1/${original_man_files[$i]}"                                              # decompress it
		    patch --backup --unified "$1/${original_man_files[$i]%%\.gz}" "$2/${patch_files[$j]}"         # patch it
		    gzip -9 "$1/${original_man_files[$i]%%\.gz}"                                                  # recompress it
		    cp --archive "$1/${original_man_files[$i]}" "$1/../patched" 
		    (( patch_count++ ))
		    break
		fi
	    fi
	done
    done
    echo "Total Number of patched manpages: $patch_count"
}

# Patch manpages
echo "Beginning patching original manpages"

mkdir --parents "${1%/}/../orig"                       # create a directory for storing backup files of patching process
patch_man_files "${1%/}" "${2%/}"
mv "${1%/}"/*orig "${1%/}"/../orig                     # move patching backup files into the related directory

echo "Patching of original manpages successfully finished"
