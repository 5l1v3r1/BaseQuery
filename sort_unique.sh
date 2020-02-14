#!/bin/bash

# Author Github:   https://github.com/g666gle
# Author Twitter:  https://twitter.com/g666g1e
# Date: 2/13/2019
# Usage: ./sort_unique.sh /full/path/to/file.txt
# Description:	This script takes in a file which is composed of file
#				paths, one per line. It will read each line and run the
#				"sort -u" command on that file.

#  Make sure we are in the BaseQuery directory
if [ "${PWD##*/}" == "BaseQuery" ];then
	#  Make sure the user passed in a command-line arg
	if [ $# -ge 1 ];then
		#  Make sure the argument is a file and it exists
		if [ -e "$1" ];then
			#  Loop over each line
			while read -r line; do
				#  Make sure the line is a path to a file that exists
				if [ -e "$line" ];then
					sort -u "$line"
				fi
			done < "$1"
		fi
	fi
fi