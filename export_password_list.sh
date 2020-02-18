#!/bin/bash

# Author Github:   https://github.com/g666gle
# Author Twitter:  https://twitter.com/g666g1e
# Date: 2/13/2020
# Usage: ./export_password_list.sh /path/to/Outputfile-name.lst
# Usage: ./export_password_list.sh /path/to/Outputfile-name.lst /full/path/to/dir/
# Description:	This script will go through the ./data directory, go through each file
#				iterate through each line. Grab the password and append it to one large 
#				password list. Then will sort and delete duplicates. 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

data_dir="./data/"
OutputFile="NULL"

#  The user must pass in an output file path
if [ $# -ge 1 ];then
	OutputFile="$1"
else
	echo "ERROR: Usage error export_password_list.sh"
	exit 1
fi

#  Check to see if the user gives a specific data dir
if [ $# -eq 2 ];then
	data_dir="$2"
fi

#  Check to make sure BaseQuery is the cwd
if [ "${PWD##*/}" == "BaseQuery" ];then
	#  Goes through the data/ lists all the 
	start=$SECONDS
	# Searches the uncompressed dir and outputs results 
	rg -uiN --no-filename --no-heading ":" "$data_dir" | cut -d ":" -f2 >> "$OutputFile"
	sort -u -o "$OutputFile" "$OutputFile"
	stop=$SECONDS
	difference=$(( stop - start ))
	#  Print progress to user
	echo -ne "Finished searching: $data_dir It took: $(( stop - start )) seconds \033[0K \r "
else
	printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
fi