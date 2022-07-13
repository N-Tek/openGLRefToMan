#!/bin/bash

# viewer.sh - Displays all manpages in a directory
# Copyright © 2022 Necib ÇAPAR <necipcapar@gmail.com>

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

count=$(ls -1 $(dirname "$1") | wc -l)
current=1
for i
do
    read -n 1 -p "[$current of $count] Will view '$i' manpage >>> Q or q to quit <<< "
    case "$REPLY"
	in
	'') man ./$i;;
	[qQ]) echo ; break;;
    esac
    (( current++ ))
    echo
done
