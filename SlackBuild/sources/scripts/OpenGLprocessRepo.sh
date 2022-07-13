#!/bin/bash

# OpenGLprocessRepo.sh - Convert OpenGL Reference repo to manpages
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

# Usage: ./OpenGLprocessRepo.sh PATH_TO_REPOSITORY

# Check the presence of required commands
type -a echo     > /dev/null 2>&1 || { echo 2>&1 "'echo' is required but NOT installed. Aborting!"; exit 3; }
type -a sed      > /dev/null 2>&1 || { echo 2>&1 "'sed' is required but NOT installed. Aborting!"; exit 4; }
type -a xsltproc > /dev/null 2>&1 || { echo 2>&1 "'xsltproc' is required but NOT installed. Aborting!"; exit 5; }
type -a mv       > /dev/null 2>&1 || { echo 2>&1 "'mv' is required but NOT installed. Aborting!"; exit 6; }
type -a mkdir    > /dev/null 2>&1 || { echo 2>&1 "'mkdir' is required but NOT installed. Aborting!"; exit 7; }
type -a cd       > /dev/null 2>&1 || { echo 2>&1 "'cd' is required but NOT installed. Aborting!"; exit 8; }
type -a gzip     > /dev/null 2>&1 || { echo 2>&1 "'gzip' is required but NOT installed. Aborting!"; exit 9; }

# Check for required # of script arguments
if [ $# -ne 1 ]; then
    echo "Usage: ./processRepo PATH_TO_REPOSITORY"
    exit 1
fi

# XSLT processor related variables
xsltOptions="--nonet --xinclude"
xsltXLS="/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl"

# manpage related variables
# Following script arrays must be updated manually according to the state of the repo
man_source="pkged by Necib CAPAR(PhD.)"
man_manual=("{ OpenGL ES 1.1 }" "{ OpenGL ES 2.0 }" "{ OpenGL ES 3.2 }" "{ OpenGL ES 3.0 }" "{ OpenGL ES 3.1 }" "{ OpenGL 2.1 }" "{ OpenGL 4.5 }")
man_section=("3GLesEarliest" "3GLesSecond" "3GLesLatest" "3GLesThird" "3GLesFourth" "3GLearliest" "3GLlatest") # only 1st character must be a digit rest must be [a-zA-Z]
                                                                                                               # otherwise beginning with additional digits remainder of
													       # the section name will be dropped in manpages,
													       # also differentiation between manpages correponding to
													       # the same function on different APIs would be nearly
													       # impossible in 'whatis' database created by 'makewhatis'
													       # command

directories=( $(ls -1 "$1" | grep '^\(es\|gl\)[1-4]\.*[0-9]*$') )                                      # directories=("es1.1" "es2.0" "es3" "es3.0" "es3.1" "gl2.1" "gl4")

# Check for correctness of the argument for the script
if [ -z "${directories[*]}" ]; then
    echo "Invalid PATH_TO_REPOSITORY entry"
    exit 2
fi

# Function Definitions
process_directory_of_manpage_xmls(){
    for file in ${directories[$i]}/*
    do
	if [ "${file##*\.}" = "xml" ]; then
	    echo "${file%\.xml}.${man_section[$i]}"
  	    sed --in-place='.bak' "/3G/a\        <refmiscinfo class=\"source\">$man_source<\/refmiscinfo>;                              
  	                           /3G/a\        <refmiscinfo class=\"manual\">${man_manual[$i]}<\/refmiscinfo>;
  	                               s/3G/${man_section[$i]}/" $file                                         # add 'source' and 'manual' attributes to xml

	    xsltproc $xsltOptions -o "${file%\.xml}.${man_section[$i]}" $xsltXLS "$file"                       # convert xml to manpage
	    mv $file.bak $file                                                                                 # convert the edited xml to its original state
	    echo
	fi
    done

    sed -i "/so/s/${man_section[$i]}/3/;
	    /so/s/${man_section[$i]}$/${man_section[$i]}.gz/" ${directories[$i]}/*.${man_section[$i]}          # adjust the '.so' requests of additional '<refname>' entities

    gzip -9 --verbose ${directories[$i]}/*.${man_section[$i]}                                                  # compress all manpages with gzip
    mv --verbose ${directories[$i]}/*.${man_section[$i]}.gz ./man3                                             # move all manpages into related folder
}

# Process files related with each API individually
cd "$1"                                                         # enter the main repo directory (should be 'OpenGL-Refpages/' 
                                                                # if cloned 'https://github.com/KhronosGroup/OpenGL-Refpages.git'

mkdir --parents "$(pwd)/man3"                                   # create a folder to collect all finalized manpages in the main repo directory

echo 
echo "Beginning processing all OpenGL API directories"
echo 

for ((i=0; i < ${#directories[@]}; i++)); do                    # process all API directories
    process_directory_of_manpage_xmls 
done 

echo "Processing of all OpenGL API directories successfully finished"
echo 
