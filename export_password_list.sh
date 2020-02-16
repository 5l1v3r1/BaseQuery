#!/bin/bash

# Author Github:   https://github.com/g666gle
# Author Twitter:  https://twitter.com/g666g1e
# Date: 2/13/2020
# Usage: ./export_password_list.sh
# Usage: ./export_password_list.sh /full/path/to/dir/
# Description:	This script will go through the ./data directory, go through each file
#				iterate through each line. Grab the password and append it to one large 
#				password list. Then will sort and delete duplicates. 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

data_dir="./data/"
if [ $# -ge 1 ];then
	data_dir ="$1"
fi

#  Check to make sure BaseQuery is the cwd
if [ "${PWD##*/}" == "BaseQuery" ];then
	PasswordList="./OutputFiles/BQPasswordListExport__$(date +'%m_%d_%Y__%H_%M_%S').lst"
	printf "${GREEN}[+]${NC} Exporting all passwords to $PasswordList\n"
	printf "${YELLOW}[!]${NC} This might take a while...\n"
	#  Goes through the data/ lists all the 
	start=$SECONDS
	echo "$(rg -iN --no-filename --no-heading ':' $data_dir)" | cut -d ':' -f2 >> "$PasswordList"
	sort -u -o "$PasswordList" "$PasswordList"
	stop=$SECONDS
	difference=$(( stop - start ))
	printf "${GREEN}[+]${NC} The export took $difference seconds!\n"
else
	printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
fi