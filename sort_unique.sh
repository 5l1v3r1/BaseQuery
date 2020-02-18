#!/bin/bash

# Author Github:   https://github.com/g666gle
# Author Twitter:  https://twitter.com/g666g1e
# Date: 2/13/2020
# Usage: ./sort_unique.sh /full/path/to/file.txt
# Usage: ./sort_unique.sh --sortthisfile /full/path/to/file.txt
# Description:	This script takes in a file which is composed of file
#				paths, one per line. It will read each line and run the
#				"sort -u" command on that file.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

#  Make sure we are in the BaseQuery directory
if [ "${PWD##*/}" == "BaseQuery" ];then
	#  Make sure the user pass-ed in a command-line arg
	if [ $# -eq 1 ];then
		#  Make sure the argument is a file and it exists
		if [ -e "$1" ];then
			sort -u -o "$1" "$1"
			printf "${GREEN}[+]${NC} Sorting modified files and deleting duplicates...\n"
			printf "${GREEN}[+]${NC} This might take a while...\n"
			start=$SECONDS
			counter=0
			#  Loop over each line
			while read -r filepath; do
				counter=$((counter+1))
				#  Make sure the line is a path to a file that exists
				if [ -e "$filepath" ];then
					sort -u -o "$filepath" "$filepath"
					echo -ne "Total Number Files Sorted and De-Duplicated $counter Current File: $filepath \033[0K \r "
				fi
			done < "$1"
			stop=$SECONDS
			difference=$(( stop - start ))
			printf "\n${GREEN}[+]${NC} Completed in $difference seconds\n"
			#  Clear the file
			: > "$1"
		else
			printf "${RED}[!]${NC} ERROR $1 - File not found!\n"
		fi
	#  If the user provides the file that needs to be sorted
	elif [ $# -eq 2 ];then
		sort -u -o "$2" "$2"
		echo -ne "Sorted and De-Duplicated $2 \033[0K \r"
	else
		printf "${YELLOW}[!]${NC} Usage: ./sort_unique.sh /full/path/to/file.txt\n"
		printf "{YELLOW}[!]${NC} Usage: ./sort_unique.sh --sortthisfile /full/path/to/file.txt\n"
	fi

fi