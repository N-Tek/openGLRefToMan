# !/bin/bash

# CreateSlackBuildSourceTarball.sh - creates patch files for corrected man pages
# Copyright © 2022 Necib ÇAPAR <necipcapar@gmail.com>

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

# Usage: ./CreateSlackBuildSourceTarball.sh [-h|--help|VERSION]
#
#                          VERSION is the semantic version of the openGLRefToMan application
#
#                          -h | --h: Display this help and exit
#
#                          Creates a SlackBuild source tarball for openGLRefToMan package

CWD=$(pwd)
PRGNAM=openGLRefToMan		# replace with name of program
VERSION=${VERSION:-1.0.0}	# replace with version of program

# # Check the presence of required commands
type -a echo     > /dev/null 2>&1 || { echo 2>&1 "'echo' is required but NOT installed. Aborting!"; exit 5; }
type -a pwd      > /dev/null 2>&1 || { echo 2>&1 "'pwd' is required but NOT installed. Aborting!"; exit 6; }

# Check for # of script arguments
if [ $# -gt 1  -o  "$1" = '-h'  -o  "$1" = '--help' ]; then
    echo "Usage: ./CreateSlackBuildSourceTarball.sh [-h|--h|VERSION]"
    echo
    echo "                 VERSION is the semantic version of the openGLRefToMan application"
    echo
    echo "                 -h | --h: Display this help and exit"
    echo
    echo "                 Creates a SlackBuild source tarball for openGLRefToMan package"
    exit 1
fi

# # Check the script argument if present
if [ $# -eq 1 ]; then 
    VERSION=$1
    if [[ ! $VERSION =~ ^[0-9].[0-9].[0-9]$ ]]; then
	echo "Incorrect $PRGNAM version"
	echo "Aborting SlackBuild source tarball creation"
	exit 2
    fi
fi

# Download source files into source directory
set -e
mkdir $PRGNAM-$VERSION
cd $PRGNAM-$VERSION

# get official OpenGL-Reference sources
echo "Getting official OpenGL-Reference source"
openGLRef_website=${source_website:-'https://github.com/KhronosGroup/OpenGL-Refpages/archive/refs/heads/main.zip'}
LANG=us wget --execute robots=off --no-parent --no-host-directories --no-verbose \
	     --no-check-certificate $openGLRef_website
echo "Download completed"

echo "Extracting .zip archieve"
unzip -qq main.zip
echo "Extraction completed"

echo "Removing official OpenGL-Reference source .zip archieve"
rm main.zip
echo "Removal completed"

echo
echo "Getting corrected_manpages and scripts"
# get corrected_manpages/ and scripts/ directory from the maintainer's repo
slackBuild_scr_website=${scr_website:-'https://github.com/N-Tek/openGLRefToMan/archive/refs/heads/master.zip'}
LANG=us wget --execute robots=off --no-parent --no-host-directories --no-verbose \
	     --no-check-certificate $slackBuild_scr_website
echo "Download completed"

echo "Extracting .zip archieve"
unzip -qq master.zip *corrected_manpages* *scripts*
echo "Extraction completed"
mv openGLRefToMan-master/SlackBuild/sources/{corrected_manpages,scripts} .
echo "Removing .zip archieve"
rm --force --recursive master.zip openGLRefToMan-master
echo "Removal completed"

cd ..
echo
echo "Creating SlackBuild source tarball"
tar czf $PRGNAM-$VERSION.tar.gz $PRGNAM-$VERSION
echo "Creation completed"
rm --force --recursive $PRGNAM-$VERSION 
