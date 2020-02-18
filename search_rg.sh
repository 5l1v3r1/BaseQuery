#!/bin/bash

# Author Github:   https://github.com/g666gle
# Author Twitter:  https://twitter.com/g666g1e
# Date: 2/17/2020
# Usage: ./search_rg.sh test@example.com <optional filename>
# Usage: ./search_rg.sh test@ <optional filename>
# Usage: ./search_rg.sh @example.com <optional filename>
# Usage: ./search_rg.sh !PW:Mys3cretPassword <optional filename>
# Description:	search_rg.sh handles all of the logic for the searching algorithm. If a 
#				filename is provided the results will be put in a file in the OutputFiles
#				directory instead of written to stdout.


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'  # No Color

# Makes sure the user is in the BaseQuery dir
if [ "${PWD##*/}" == "BaseQuery" ];then
	# If directory is not empty
	if [ "$(ls -A ./data)" ]; then
		# Grab everything before the @ sign
		user_name=$(echo "$1" | cut -d @ -f 1 | awk '{print tolower($0)}')
		email=$(echo "$1" | cut -d : -f 1 | awk '{print tolower($0)}')
		check_for_at=${1:0:1}
		check_for_pwd=${1:0:4}

		#  Check if the user wants to search for a password
		if [ "$check_for_pwd" == "!PW:" ];then
			#  Cut off the '!PW:' and keep the password
			password=${1:4}
			read -p "Output to a file? [y/n] " out_to_file 
			# Checks input
			while [[ "$out_to_file" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Output to a file? [y/n] " out_to_file 
			done

			timestamp="Null"
			metadata="Null"

			read -p "Do you want the output to include a time-stamp? [y/n] " timestamp 
			# Checks input
			while [[ "$timestamp" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Do you want the output to include a time-stamp? [y/n] " timestamp 
			done

			read -p "Would you like the output to include metadata? [y/n] " metadata
			# Checks input
			while [[ "$metadata" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Would you like the output to include metadata? [y/n] " metadata 
			done

			read -p "Would you like your search to be case-sensitive? [y/n] " case_sensitive
			# Checks input
			while [[ "$case_sensitive" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Would you like your search to be case-sensitive? [y/n] " case_sensitive 
			done

			read -p "Would you like to match the exact string \"$password\"? [y/n] " match_exact
			# Checks input
			while [[ "$match_exact" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Would you like the output to include metadata? [y/n] " match_exact 
			done

			# Does the user want to output the results to a file
			if [[ "$out_to_file" == [Yy] ]];then
				# Make sure the outputfiles dir exists
				if ! [ -d ./OutputFiles ];then
					mkdir OutputFiles
				fi
				printf "${GREEN}[+]${NC} Outputting all results to ${GREEN}$(pwd)/OutputFiles/PWD_%s_output.txt${NC}\n" "$password"
				printf "${GREEN}[+]${NC} Please wait this could take a few minutes!\n"

			fi

			
			printf "${GREEN}[+]${NC} Starting search!\n"

			start=$SECONDS
			# check if the user wants the output to a file
			if [[ "$out_to_file" == [Yy] ]];then 
				#  check to see if the user wants to see metadata
				if [[ "$metadata" == [Yy] ]];then
					# The user wants timestamps
					if [[ "$timestamp" == [Yy] ]];then
						# add a time stamp
						printf "\n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\n\n" >>  ./OutputFiles/"PWD_$password"_output.txt
						printf "The results below were generated at:\n$(date)\n\n" >>  ./OutputFiles/"PWD_$password"_output.txt
						#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
						find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
							#  If we have a compressed directory
							if [[ "$file" =~ \.tar\.zst$ ]];then
								#  check to make sure you dont decompress the working directory
								if [ "$file" != "data/" ];then
									# Grabs the name of the file from the path
									name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
									# decompress the .tar.zst files
									tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
									#  Match the exact case but it can be a substring 
									if [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
										rg -u --color never --heading --line-number --stats ":$password" ./data/"$name"  >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case AND the exact string
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
										rg -u --color never --heading --line-number --stats ":$password"$ ./data/"$name"  >> ./OutputFiles/"PWD_$password"_output.txt
									#  DONT match the exact case BUT match the exact string
									elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
										rg -u --ignore-case --color never --heading --line-number --stats ":$password"$ ./data/"$name"  >> ./OutputFiles/"PWD_$password"_output.txt
									#  DONT match the exact case AND DONT match the exact string
									elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
										rg -u --ignore-case --color never --heading --line-number --stats ":$password" ./data/"$name"  >> ./OutputFiles/"PWD_$password"_output.txt
									fi

									# Instead of recompressing the directory we will jsut delete the
									# uncompressed version and keep the compressed version
									rm -rf ./data/"$name"
								fi
							#  We have an uncompressed directory
							else
								# Search the directory for the desired string
								#  DONT match the exact case AND DONT match the exact string
								if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
									rg -u --ignore-case --color never --heading --line-number --stats ":$password" "$file"  >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case AND the exact string
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
									rg -u --color never --heading --line-number --stats ":$password"$ "$file"  >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case but it can be a substring 
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
									rg -u --color never --heading --line-number --stats ":$password" "$file"  >> ./OutputFiles/"PWD_$password"_output.txt
								#  DONT match the exact case BUT match the exact string
								elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
									rg -u --ignore-case --color never --heading --line-number --stats ":$password"$ "$file"  >> ./OutputFiles/"PWD_$password"_output.txt
								fi
							fi	
						done
						printf "\n" >> ./OutputFiles/"PWD_$password"_output.txt
					# The user doesn't want timestamps
					else
						#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
						find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
							#  If we have a compressed directory
							if [[ "$file" =~ \.tar\.zst$ ]];then
								#  check to make sure you dont decompress the working directory
								if [ "$file" != "data/" ];then
									# Grabs the name of the file from the path
									name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
									# decompress the .tar.zst files
									tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
									# Search the directory for the desired string
									#  DONT match the exact case AND DONT match the exact string
									if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
										rg -u --ignore-case --color never --heading --line-number --stats ":$password" ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case AND the exact string
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
										rg -u --color never --heading --line-number --stats ":$password"$ ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case but it can be a substring 
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
										rg -u --color never --heading --line-number --stats ":$password" ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  DONT match the exact case BUT match the exact string
									elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
										rg -u --ignore-case --color never --heading --line-number --stats ":$password"$ ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									fi

									# Instead of recompressing the directory we will jsut delete the
									# uncompressed version and keep the compressed version
									rm -rf ./data/"$name"
								fi
							#  We have an uncompressed directory
							else
								#  DONT match the exact case AND DONT match the exact string
								if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
									rg -u --ignore-case --color never --heading --line-number --stats ":$password" "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case AND the exact string
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
									rg -u --color never --heading --line-number --stats ":$password"$ "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case but it can be a substring 
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
									rg -u --color never --heading --line-number --stats ":$password" "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  DONT match the exact case BUT match the exact string
								elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
									rg -u --ignore-case --color never --heading --line-number --stats ":$password"$ "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								fi
							fi	
						done
						printf "\n" >> ./OutputFiles/"PWD_$password"_output.txt

					fi # timestamp

				else
					# The user wants a time stamp but no metadata
					if [[ "$timestamp" == [Yy] ]];then
						# add a time stamp
						printf "\n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\n\n" >>  ./OutputFiles/"PWD_$password"_output.txt
						printf "The results below were generated at:\n$(date)\n\n" >>  ./OutputFiles/"PWD_$password"_output.txt
						#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
						find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
							#  If we have a compressed directory
							if [[ "$file" =~ \.tar\.zst$ ]];then
								#  check to make sure you dont decompress the working directory
								if [ "$file" != "data/" ];then
									# Grabs the name of the file from the path
									name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
									# decompress the .tar.zst files
									tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
									# Search the directory for the desired string

									#  DONT match the exact case AND DONT match the exact string
									if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
										rg -u -iN --no-filename --no-heading ":$password" ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case AND the exact string
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
										rg -u -N --no-filename --no-heading ":$password"$ ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case but it can be a substring 
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
										rg -u -N --no-filename --no-heading ":$password" ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  DONT match the exact case BUT match the exact string
									elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
										rg -u -iN --no-filename --no-heading ":$password"$ ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									fi
									# Instead of recompressing the directory we will jsut delete the
									# uncompressed version and keep the compressed version
									rm -rf ./data/"$name"
								fi
							#  We have an uncompressed directory
							else
								#  DONT match the exact case AND DONT match the exact string
								if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
									rg -u -iN --no-filename --no-heading ":$password" "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case AND the exact string
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
									rg -u -N --no-filename --no-heading ":$password"$ "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case but it can be a substring 
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
									rg -u -N --no-filename --no-heading ":$password" "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  DONT match the exact case BUT match the exact string
								elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
									rg -u -iN --no-filename --no-heading ":$password"$ "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								fi
							fi	
						done
						printf "\n" >> ./OutputFiles/"PWD_$password"_output.txt
					# No timestamp and no meta data
					else
						#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
						find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
							#  If we have a compressed directory
							if [[ "$file" =~ \.tar\.zst$ ]];then
								#  check to make sure you dont decompress the working directory
								if [ "$file" != "data/" ];then
									# Grabs the name of the file from the path
									name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
									# decompress the .tar.zst files
									tar --use-compress-program=zstd -xf ./data/"$name".tar.zst

									#  DONT match the exact case AND DONT match the exact string
									if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
										rg -u -iN --no-filename --no-heading ":$password" ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case AND the exact string
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
										rg -u -N --no-filename --no-heading ":$password"$ ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  Match the exact case but it can be a substring 
									elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
										rg -u -N --no-filename --no-heading ":$password" ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									#  DONT match the exact case BUT match the exact string
									elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
										rg -u -iN --no-filename --no-heading ":$password"$ ./data/"$name" >> ./OutputFiles/"PWD_$password"_output.txt
									fi	
									# Instead of recompressing the directory we will jsut delete the
									# uncompressed version and keep the compressed version
									rm -rf ./data/"$name"
								fi
							#  We have an uncompressed directory
							else
								#  DONT match the exact case AND DONT match the exact string
								if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
									rg -u -iN --no-filename --no-heading ":$password" "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case AND the exact string
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
									rg -u -N --no-filename --no-heading ":$password"$ "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  Match the exact case but it can be a substring 
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
									rg -u -N --no-filename --no-heading ":$password" "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								#  DONT match the exact case BUT match the exact string
								elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
									rg -u -iN --no-filename --no-heading ":$password"$ "$file" >> ./OutputFiles/"PWD_$password"_output.txt
								fi
							fi	
						done
						printf "\n" >> ./OutputFiles/"PWD_$password"_output.txt

					fi #timestamp
				fi # metadata

			else # Send the output to the console
				#  check to see if the user wants to see metadata
				if [[ "$metadata" == [Yy] ]];then
					#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
					find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
						#  If we have a compressed directory
						if [[ "$file" =~ \.tar\.zst$ ]];then
							#  check to make sure you dont decompress the working directory
							if [ "$file" != "data/" ];then
								# Grabs the name of the file from the path
								name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
								# decompress the .tar.zst files
								tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
								#  DONT match the exact case AND DONT match the exact string
								if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
									rg -u -i ":$password" ./data/"$name"
								#  Match the exact case AND the exact string
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
									rg -u ":$password"$ ./data/"$name"
								#  Match the exact case but it can be a substring 
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
									rg -u ":$password" ./data/"$name"
								#  DONT match the exact case BUT match the exact string
								elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
									rg -u -i ":$password"$ ./data/"$name"
								fi
								# Instead of recompressing the directory we will jsut delete the
								# uncompressed version and keep the compressed version
								rm -rf ./data/"$name"
							fi
						#  We have an uncompressed directory
						else
							#  DONT match the exact case AND DONT match the exact string
							if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
								rg -u -i ":$password" "$file"
							#  Match the exact case AND the exact string
							elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
								rg -u ":$password"$ "$file"
							#  Match the exact case but it can be a substring 
							elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
								rg -u ":$password" "$file"
							#  DONT match the exact case BUT match the exact string
							elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
								rg -u -i ":$password"$ "$file"
							fi
						fi	
					done
					
				# No metadata
				else
					#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
					find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
						#  If we have a compressed directory
						if [[ "$file" =~ \.tar\.zst$ ]];then
							#  check to make sure you dont decompress the working directory
							if [ "$file" != "data/" ];then
								# Grabs the name of the file from the path
								name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
								# decompress the .tar.zst files
								tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	

								#  DONT match the exact case AND DONT match the exact string
								if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
									rg -u -iN --no-filename --no-heading ":$password" ./data/"$name" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
								#  Match the exact case AND the exact string
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
									rg -u -N --no-filename --no-heading ":$password"$ ./data/"$name" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
								#  Match the exact case but it can be a substring 
								elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
									rg -u -N --no-filename --no-heading ":$password" ./data/"$name" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
								#  DONT match the exact case BUT match the exact string
								elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
									rg -u -iN --no-filename --no-heading ":$password"$ ./data/"$name" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
								fi
								# Instead of recompressing the directory we will jsut delete the
								# uncompressed version and keep the compressed version
								rm -rf ./data/"$name"
							fi
						#  We have an uncompressed directory
						else
							#  DONT match the exact case AND DONT match the exact string
							if [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Nn] ]];then
								rg -u -iN --no-filename --no-heading ":$password" "$file" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
							#  Match the exact case AND the exact string
							elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Yy] ]];then
								rg -u -N --no-filename --no-heading ":$password"$ "$file" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
							#  Match the exact case but it can be a substring 
							elif [[ "$case_sensitive"  == [Yy]  && "$match_exact" == [Nn] ]];then
								rg -u -N --no-filename --no-heading ":$password" "$file" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
							#  DONT match the exact case BUT match the exact string
							elif [[ "$case_sensitive"  == [Nn]  && "$match_exact" == [Yy] ]];then
								rg -u -iN --no-filename --no-heading ":$password"$ "$file" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
							fi
						fi	
					done
					
				fi #metadata
			fi # out to file

			# Report metrics to user
			stop=$SECONDS
			diff=$(( stop - start ))
			#  reading the number of uncompressed bytes in the data folder
			echo
			size_of_db_in_bytes=$(du -sb "./data"/ | cut -f 1)
			#  Multiplying the bytes to get GB (Note: I divide by 1 because 'bc' is annoying and wont round if you dont)
			size_of_db_in_gb=$(echo "scale=3; ($size_of_db_in_bytes * 0.000000001)"/1 | bc)
			printf "${YELLOW}[!]${NC} Searched through your ${GREEN}$size_of_db_in_gb GB ${NC}BaseQuery database in $diff seconds!\n"
			exit 0		
		fi	# Check for !PW

		# Above Checks for Passwords
##########################################################################################################################################
		# Below check to see if the user entered in a domain ex) @google.com
		if [ "$check_for_at" == "@" ];then

			read -p "Output to a file? [y/n] " out_to_file 
			# Checks input
			while [[ "$out_to_file" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Output to a file? [y/n] " out_to_file 
			done

			read -p "Search using low-disk-space mode? [y/n] " low_disk_space_mode 
			# Checks input
			while [[ "$low_disk_space_mode" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Search using low-disk-space mode? [y/n] " low_disk_space_mode 
			done

			timestamp="Null"
			metadata="Null"

			read -p "Do you want to include a time-stamp? [y/n] " timestamp 
			# Checks input
			while [[ "$timestamp" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Do you want to include a time-stamp? [y/n] " timestamp 
			done

			read -p "Would you like the output to include metadata? [y/n] " metadata
			# Checks input
			while [[ "$metadata" != [YyNn] ]];do
				printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
				read -p "Would you like the output to include metadata? [y/n] " metadata 
			done

			# Does the user want to output the results to a file
			if [[ "$out_to_file" == [Yy] ]];then
				# Make sure the outputfiles dir exists
				if ! [ -d ./OutputFiles ];then
					mkdir OutputFiles
				fi
				printf "${GREEN}[+]${NC} Outputting all results to ${GREEN}$(pwd)/OutputFiles/$1_output.txt${NC}\n"
				printf "${GREEN}[+]${NC} Please wait this could take a few minutes!\n"
			fi


			if [[ "$low_disk_space_mode" == [Nn] ]];then
				# Decompress all files
				printf "${GREEN}[+]${NC} Decompressing files\n"
				./decompress.sh

				printf "${GREEN}[+]${NC} Starting search!\n"

				start=$SECONDS
				# check if the user wants the output to a file
				if [[ "$out_to_file" == [Yy] ]];then 
					#  check to see if the user wants to see metadata
					if [[ "$metadata" == [Yy] ]];then
						# The user wants timestamps
						if [[ "$timestamp" == [Yy] ]];then
							# add a time stamp
							printf "\n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\n\n" >>  ./OutputFiles/"$1"_output.txt
							printf "The results below were generated at:\n$(date)\n\n" >>  ./OutputFiles/"$1"_output.txt
							rg -u --ignore-case --color never --heading --line-number --stats "$1" ./data/  >> ./OutputFiles/"$1"_output.txt
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						# The user doesn't want timestamps
						else
							rg -u --ignore-case --color never --heading --line-number --stats "$1" ./data/ >> ./OutputFiles/"$1"_output.txt
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						fi

					else
						# The user wants a time stamp but no metadata
						if [[ "$timestamp" == [Yy] ]];then
							# add a time stamp
							printf "\n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\n\n" >>  ./OutputFiles/"$1"_output.txt
							printf "The results below were generated at:\n$(date)\n\n" >>  ./OutputFiles/"$1"_output.txt
							rg -u -iN --no-filename --no-heading "$1" ./data/ >> ./OutputFiles/"$1"_output.txt
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						# No timestamp and no meta data
						else
							rg -u -iN --no-filename --no-heading "$1" ./data/ >> ./OutputFiles/"$1"_output.txt
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						fi

					fi 

				else # Send the output to the console
					#  check to see if the user wants to see metadata
					if [[ "$metadata" == [Yy] ]];then
						rg -u -i "$1" ./data/
					# No metadata
					else
						rg -u -iN --no-filename --no-heading "$1" ./data/ | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
					fi 
				fi

				# Report metrics to the user
				stop=$SECONDS
				diff=$(( stop - start ))
				#  reading the number of uncompressed bytes in the data folder
				echo
				size_of_db_in_bytes=$(du -sb "./data"/ | cut -f 1)
				#  Multiplying the bytes to get GB (Note: I divide by 1 because 'bc' is annoying and wont round if you dont)
				size_of_db_in_gb=$(echo "scale=3; ($size_of_db_in_bytes * 0.000000001)"/1 | bc)
				printf "${YELLOW}[!]${NC} Searched through your ${GREEN}$size_of_db_in_gb GB ${NC}BaseQuery database in $diff seconds!\n"
				exit 0
			fi #  Low disk space = No

			if [[ "$low_disk_space_mode" == [Yy] ]];then
				start=$SECONDS
				# check if the user wants the output to a file
				if [[ "$out_to_file" == [Yy] ]];then 
					#  check to see if the user wants to see metadata
					if [[ "$metadata" == [Yy] ]];then
						# The user wants timestamps
						if [[ "$timestamp" == [Yy] ]];then
							# add a time stamp
							printf "\n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\n\n" >>  ./OutputFiles/"$1"_output.txt
							printf "The results below were generated at:\n$(date)\n\n" >>  ./OutputFiles/"$1"_output.txt

							#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
							find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
								#  If we have a compressed directory
								if [[ "$file" =~ \.tar\.zst$ ]];then
									#  check to make sure you dont decompress the working directory
									if [ "$file" != "data/" ];then
										# Grabs the name of the file from the path
										name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
										# decompress the .tar.zst files
										tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
										# Search the directory for the desired string
										rg -u --ignore-case --color never --heading --line-number --stats "$1" ./data/"$name"  >> ./OutputFiles/"$1"_output.txt
										# Instead of recompressing the directory we will jsut delete the
										# uncompressed version and keep the compressed version
										rm -rf ./data/"$name"
									fi
								#  We have an uncompressed directory
								else
									# Search the directory for the desired string
									rg -u --ignore-case --color never --heading --line-number --stats "$1" "$file"  >> ./OutputFiles/"$1"_output.txt
								fi	
							done
							#  Create seperation
							printf "\n" >> ./OutputFiles/"$1"_output.txt
							
						# The user doesn't want timestamps
						else
							#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
							find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
								#  If we have a compressed directory
								if [[ "$file" =~ \.tar\.zst$ ]];then
									#  check to make sure you dont decompress the working directory
									if [ "$file" != "data/" ];then
										# Grabs the name of the file from the path
										name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
										# decompress the .tar.zst files
										tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
										# Search the directory for the desired string
										rg -u --ignore-case --color never --heading --line-number --stats "$1" ./data/"$name" >> ./OutputFiles/"$1"_output.txt
										# Instead of recompressing the directory we will jsut delete the
										# uncompressed version and keep the compressed version
										rm -rf ./data/"$name"
									fi
								#  We have an uncompressed directory
								else
									# Search the directory for the desired string
									rg -u --ignore-case --color never --heading --line-number --stats "$1" "$file" >> ./OutputFiles/"$1"_output.txt
								fi	
							done
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						fi

					else
						# The user wants a time stamp but no metadata
						if [[ "$timestamp" == [Yy] ]];then
							# add a time stamp
							printf "\n/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\n\n" >>  ./OutputFiles/"$1"_output.txt
							printf "The results below were generated at:\n$(date)\n\n" >>  ./OutputFiles/"$1"_output.txt

							#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
							find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
								#  If we have a compressed directory
								if [[ "$file" =~ \.tar\.zst$ ]];then
									#  check to make sure you dont decompress the working directory
									if [ "$file" != "data/" ];then
										# Grabs the name of the file from the path
										name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
										# decompress the .tar.zst files
										tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
										# Search the directory for the desired string
										rg -u -iN --no-filename --no-heading "$1" ./data/"$name" >> ./OutputFiles/"$1"_output.txt
										# Instead of recompressing the directory we will jsut delete the
										# uncompressed version and keep the compressed version
										rm -rf ./data/"$name"
									fi
								#  We have an uncompressed directory
								else
									# Search the directory for the desired string
									rg -u -iN --no-filename --no-heading "$1" "$file" >> ./OutputFiles/"$1"_output.txt
								fi	
							done
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						# No timestamp and no meta data
						else
							#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
							find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
								#  If we have a compressed directory
								if [[ "$file" =~ \.tar\.zst$ ]];then
									#  check to make sure you dont decompress the working directory
									if [ "$file" != "data/" ];then
										# Grabs the name of the file from the path
										name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
										# decompress the .tar.zst files
										tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
										# Search the directory for the desired string
										rg -u -iN --no-filename --no-heading "$1" ./data/"$name" >> ./OutputFiles/"$1"_output.txt
										# Instead of recompressing the directory we will jsut delete the
										# uncompressed version and keep the compressed version
										rm -rf ./data/"$name"
									fi
								#  We have an uncompressed directory
								else
									# Search the directory for the desired string
									rg -u -iN --no-filename --no-heading "$1" "$file" >> ./OutputFiles/"$1"_output.txt
								fi	
							done
							printf "\n" >> ./OutputFiles/"$1"_output.txt
						fi

					fi 

				else # Send the output to the console
					#  check to see if the user wants to see metadata
					if [[ "$metadata" == [Yy] ]];then
						#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
						find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
							#  If we have a compressed directory
							if [[ "$file" =~ \.tar\.zst$ ]];then
								#  check to make sure you dont decompress the working directory
								if [ "$file" != "data/" ];then
									# Grabs the name of the file from the path
									name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
									# decompress the .tar.zst files
									tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
									# Search the directory for the desired string
									rg -u -i "$1" ./data/"$name"
									# Instead of recompressing the directory we will jsut delete the
									# uncompressed version and keep the compressed version
									rm -rf ./data/"$name"
								fi
							#  We have an uncompressed directory
							else
								# Search the directory for the desired string
								rg -u -i "$1" "$file"
							fi	
						done
					# No metadata
					else
						#  Iterate through all the directories and files that end in "*.tar.zst" in the data/ dir
						find data/ -maxdepth 1 -name "*.tar.zst" -or -type d | tail -n +2 | sort | while read -r file;do
							#  If we have a compressed directory
							if [[ "$file" =~ \.tar\.zst$ ]];then
								#  check to make sure you dont decompress the working directory
								if [ "$file" != "data/" ];then
									# Grabs the name of the file from the path
									name="$(echo "$file" | cut -f 2- -d "/" | cut -f 1 -d '.')"
									# decompress the .tar.zst files
									tar --use-compress-program=zstd -xf ./data/"$name".tar.zst	
									# Search the directory for the desired string
									rg -u -iN --no-filename --no-heading "$1" ./data/"$name" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
									# Instead of recompressing the directory we will jsut delete the
									# uncompressed version and keep the compressed version
									rm -rf ./data/"$name"
								fi
							#  We have an uncompressed directory
							else
								# Search the directory for the desired string
								rg -u -iN --no-filename --no-heading "$1" "$file" | sed -e ''/:/s//"$(printf '\033[0;31m:')"/'' -e ''/$/s//"$(printf '\033[0m')"/''
							fi	
						done
					fi # metadata = y
				fi # out to file
				stop=$SECONDS
				diff=$(( stop - start ))
				#  reading the number of uncompressed bytes in the data folder
				echo
				size_of_db_in_bytes=$(du -sb "./data"/ | cut -f 1)
				#  Multiplying the bytes to get GB (Note: I divide by 1 because 'bc' is annoying and wont round if you dont)
				size_of_db_in_gb=$(echo "scale=3; ($size_of_db_in_bytes * 0.000000001)"/1 | bc)
				printf "${YELLOW}[!]${NC} Searched through your ${GREEN}$size_of_db_in_gb GB ${NC}BaseQuery database in $diff seconds!\n"
				exit 0
			fi #  Low disk space = Yes
		fi # user did not start with a '@'
	else
		printf "${RED}ERROR:${NC} ./data directory is empty please import files first!\n"
		exit 0
	fi # data dir not empty

	#####################################################################################
	# The above code deals with querying every file for a specific domain and password	#
	#        The below code deals with querying a specific username or file	            #
	#####################################################################################

	# Deals with all the cases of having a file vs stdout
	out_to_file="N"
	#  Check to see if the user is running a file or just commandline input
	if [ $# -ge 2 ];then
		out_to_file="YF" # Yes implicit from entering a file
	else  # The user is not running a file so ask them if they want to output to a file
		read -p "Output to a file? [y/n] " out_to_file 
		# Checks input
		while [[ "$out_to_file" != [YyNn] ]];do
			printf "${YELLOW}[!]${NC} Please enter either \"y\" or \"n\"!\n"
			read -p "Output to a file? [y/n] " out_to_file 
		done
		# Informing the user
		printf "${GREEN}[+]${NC} Starting search!\n"
		if [[ "$out_to_file" == [Yy] ]];then
			# Make the dir if it doesn't exist
			if ! [ -d ./OutputFiles ];then
				mkdir OutputFiles
			fi
			printf "${GREEN}[+]${NC} Outputting all results to ${GREEN}./OutputFiles/$1_output.txt${NC}\n"
		fi
	fi

	#  Check to make sure the user name is at least 4 chars and the email has a @
	if [[ ${#user_name} -ge 4 ]] && [[ "$email" == *"@"* ]];then	
		# Grab each individual character
		first_char=${user_name:0:1}  # ${variable name: starting position : how many letters}
		second_char=${user_name:1:1}
		third_char=${user_name:2:1}
		fourth_char=${user_name:3:1}
		
		#  Check to see if the folder is compressed
		if [ -e ./data/"$first_char".tar.zst ];then
			#  Decompress the data
			./decompress.sh -f "$first_char".tar.zst > /dev/null
		fi

		#  Check the first directory
		if [ -d ./data/"$first_char" ];then
			#  Check the second directory
			if [ -d  ./data/"$first_char"/"$second_char" ];then
				#  Check the third directory
				if [ -d ./data/"$first_char"/"$second_char"/"$third_char" ];then
					if [[ "$out_to_file" == [Nn] ]];then
						printf "${GREEN}Email Address: $email${NC}\n"
					fi
					#  Check to see if the file exists
					if [ -e ./data/"$first_char"/"$second_char"/"$third_char"/"$fourth_char".txt ];then
						#  Open the file and search for the email address then only keep the passwords, iterate through the passwords and echo then
						rg -u -iN --no-filename --no-heading --color never "^$email" ./data/"$first_char"/"$second_char"/"$third_char"/"$fourth_char".txt | while read -r Line;do
							user_name="$(echo "$Line" | cut -f 1 -d ':')"
							Password="$(echo "$Line" | cut -f 2- -d ':')"
							# check if the user wants the output to a file
							if [[ "$out_to_file" == [Yy] ]];then 
								echo  "$Line" >> ./OutputFiles/"$1"_output.txt
							elif [ "$out_to_file" == "YF" ];then
								echo  "$Line" >> ./OutputFiles/"$2"_output.txt
							else # Send the output to the console
								printf "$user_name${RED}:$Password${NC}\n"
							fi
						done
						
						#  Check to see if the email is in the NOT VALID file
						if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
							rg -u -iN --no-filename --no-heading --color never "^$email" ./data/NOTVALID/FAILED_TEST.txt | while read -r Line;do
								user_name="$(echo "$Line" | cut -f 1 -d ':')"
								Password="$(echo "$Line" | cut -f 2- -d ':')"
								# check if the user wants the output to a file
								if [[ "$out_to_file" == [Yy] ]];then 
									echo  "$Line" >> ./OutputFiles/"$1"_output.txt
								elif [ "$out_to_file" == "YF" ];then
									echo  "$Line" >> ./OutputFiles/"$2"_output.txt
								else # Send the output to the console
									printf "$user_name${RED}:$Password${NC}\n"
								fi
							done	
						fi
					else
						#  The file does not exists
						#  Check to make sure the directory exists and the file exists for 0UTLIERS
						if [[ -d "./data/$first_char/$second_char/$third_char/0UTLIERS" && -e "./data/$first_char/$second_char/$third_char/0UTLIERS/0utliers.txt" ]];then
							rg -u -iN --no-filename --no-heading --color never "^$email" ./data/"$first_char"/"$second_char"/"$third_char"/0UTLIERS/0utliers.txt | while read -r Line;do
								user_name="$(echo "$Line" | cut -f 1 -d ':')"
								Password="$(echo "$Line" | cut -f 2- -d ':')"
								# check if the user wants the output to a file
								if [[ "$out_to_file" == [Yy] ]];then 
									echo  "$Line" >> ./OutputFiles/"$1"_output.txt
								elif [ "$out_to_file" == "YF" ];then
									echo  "$Line" >> ./OutputFiles/"$2"_output.txt
								else # Send the output to the console
									printf "$user_name${RED}:$Password${NC}\n"
								fi
							done	
						fi

						#  Check to see if the email is in the NOT VALID file
						if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
							rg -u -iN --no-filename --no-heading --color never "^$email" ./data/NOTVALID/FAILED_TEST.txt | while read -r Line;do
								user_name="$(echo "$Line" | cut -f 1 -d ':')"
								Password="$(echo "$Line" | cut -f 2- -d ':')"
								# check if the user wants the output to a file
								if [[ "$out_to_file" == [Yy] ]];then 
									echo  "$Line" >> ./OutputFiles/"$1"_output.txt
								elif [ "$out_to_file" == "YF" ];then
									echo  "$Line" >> ./OutputFiles/"$2"_output.txt
								else # Send the output to the console
									printf "$user_name${RED}:$Password${NC}\n"
								fi
							done	
						fi					
					fi
				else
					if [[ "$out_to_file" == [Nn] ]];then
						printf "${GREEN}Email Address: ""$email""${NC}\n"
					fi
					#  The third letter directory does not exists
					if [[ -d "./data/$first_char/$second_char/0UTLIERS" && -e "./data/$first_char/$second_char/0UTLIERS/0utliers.txt" ]];then
						rg -u -iN --no-filename --no-heading --color never "^$email" ./data/"$first_char"/"$second_char"/0UTLIERS/0utliers.txt | while read -r Line;do
							user_name="$(echo "$Line" | cut -f 1 -d ':')"
							Password="$(echo "$Line" | cut -f 2- -d ':')"
							# check if the user wants the output to a file
							if [[ "$out_to_file" == [Yy] ]];then 
								echo  "$Line" >> ./OutputFiles/"$1"_output.txt
							elif [ "$out_to_file" == "YF" ];then
								echo  "$Line" >> ./OutputFiles/"$2"_output.txt
							else # Send the output to the console
								printf "$user_name${RED}:$Password${NC}\n"
							fi
						done	
					fi

					#  Check to see if the email is in the NOT VALID file
					if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
						rg -u -iN --no-filename --no-heading --color never "^$email" ./data/NOTVALID/FAILED_TEST.txt | while read -r Line;do
							user_name="$(echo "$Line" | cut -f 1 -d ':')"
							Password="$(echo "$Line" | cut -f 2- -d ':')"
							# check if the user wants the output to a file
							if [[ "$out_to_file" == [Yy] ]];then 
								echo  "$Line" >> ./OutputFiles/"$1"_output.txt
							elif [ "$out_to_file" == "YF" ];then
								echo  "$Line" >> ./OutputFiles/"$2"_output.txt
							else # Send the output to the console
								printf "$user_name${RED}:$Password${NC}\n"
							fi
						done	
					fi
				fi
			else
				if [[ "$out_to_file" == [Nn] ]];then
					printf "${GREEN}Email Address: ""$email""${NC}\n"
				fi
				#  The second letter directory does not exists
				if [[ -d "./data/$first_char/0UTLIERS" && -e "./data/$first_char/0UTLIERS/0utliers.txt" ]];then
					rg -u -iN --no-filename --no-heading --color never "^$email" ./data/"$first_char"/0UTLIERS/0utliers.txt | while read -r Line;do
						user_name="$(echo "$Line" | cut -f 1 -d ':')"
						Password="$(echo "$Line" | cut -f 2- -d ':')"
						# check if the user wants the output to a file
						if [[ "$out_to_file" == [Yy] ]];then 
							echo  "$Line" >> ./OutputFiles/"$1"_output.txt
						elif [ "$out_to_file" == "YF" ];then
							echo  "$Line" >> ./OutputFiles/"$2"_output.txt
						else # Send the output to the console
							printf "$user_name${RED}:$Password${NC}\n"
						fi
					done	
				fi

				#  Check to see if the email is in the NOT VALID file
				if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
					rg -u -iN --no-filename --no-heading --color never "^$email" ./data/NOTVALID/FAILED_TEST.txt | while read -r Line;do
						user_name="$(echo "$Line" | cut -f 1 -d ':')"
						Password="$(echo "$Line" | cut -f 2- -d ':')"
						# check if the user wants the output to a file
						if [[ "$out_to_file" == [Yy] ]];then 
							echo  "$Line" >> ./OutputFiles/"$1"_output.txt
						elif [ "$out_to_file" == "YF" ];then
							echo  "$Line" >> ./OutputFiles/"$2"_output.txt
						else # Send the output to the console
							printf "$user_name${RED}:$Password${NC}\n"
						fi
					done	
				fi
			fi
		else
			if [[ "$out_to_file" == [Nn] ]];then
				printf "${GREEN}Email Address: ""$email""${NC}\n"
			fi
			#  The first letter directory does not exists
			if [[ -d ./data/0UTLIERS && -e ./data/0UTLIERS/0utliers.txt ]];then
				rg -u -iN --no-filename --no-heading --color never "^$email" ./data/0UTLIERS/0utliers.txt | while read -r Line;do
					user_name="$(echo "$Line" | cut -f 1 -d ':')"
					Password="$(echo "$Line" | cut -f 2- -d ':')"
					# check if the user wants the output to a file
					if [[ "$out_to_file" == [Yy] ]];then 
						echo  "$Line" >> ./OutputFiles/"$1"_output.txt
					elif [ "$out_to_file" == "YF" ];then
						echo  "$Line" >> ./OutputFiles/"$2"_output.txt
					else # Send the output to the console
						printf "$user_name${RED}:$Password${NC}\n"
					fi
				done	
			fi

			#  Check to see if the email is in the NOT VALID file
			if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
				rg -u -iN --no-filename --no-heading --color never "^$email" ./data/NOTVALID/FAILED_TEST.txt | while read -r Line;do
					user_name="$(echo "$Line" | cut -f 1 -d ':')"
					Password="$(echo "$Line" | cut -f 2- -d ':')"
					# check if the user wants the output to a file
					if [[ "$out_to_file" == [Yy] ]];then 
						echo  "$Line" >> ./OutputFiles/"$1"_output.txt
					elif [ "$out_to_file" == "YF" ];then
						echo  "$Line" >> ./OutputFiles/"$2"_output.txt
					else # Send the output to the console
						printf "$user_name${RED}:$Password${NC}\n"
					fi
				done	
			fi
		fi
	else  # If not a valid address
		first_char=${user_name:0:1}  # {variable name: starting position : how many letters}

		#  Check to see if the folder is compressed
		if [ -e ./data/"$first_char".tar.zst ];then
			./decompress.sh -f "$first_char".tar.zst > /dev/null
		fi
		#  Uncompresses NOTVALID
		if [ -e ./data/NOTVALID.tar.zst ];then
			./decompress.sh -f NOTVALID.tar.zst > /dev/null
		fi
		# Supreses output
		if [[ "$out_to_file" == [Nn] ]];then
			printf "${GREEN}Email Address: ""$email""${NC}\n"
		fi

		# Checks if the email has an @ 
		if [[ $email == *"@"* ]];then
			#  The username is either not >= 4 or the email doesn't contain an @
			#  Check to see if the email is in the NOT VALID file
			if [[ -d ./data/NOTVALID && -e ./data/NOTVALID/FAILED_TEST.txt ]];then
				rg -u -iN --no-filename --no-heading --color never "^$email" ./data/NOTVALID/FAILED_TEST.txt | while read -r Line;do
					user_name="$(echo "$Line" | cut -f 1 -d ':')"
					Password="$(echo "$Line" | cut -f 2- -d ':')"
					# check if the user wants the output to a file
					if [[ "$out_to_file" == [Yy] ]];then 
						echo  "$Line" >> ./OutputFiles/"$1"_output.txt
					elif [ "$out_to_file" == "YF" ];then
						echo  "$Line" >> ./OutputFiles/"$2"_output.txt
					else # Send the output to the console
						printf "$user_name${RED}:$Password${NC}\n"
					fi
				done	
			fi
		else
			printf "${YELLOW}[!]${NC} Please enter one email address or a file with one email address per line\n"
		fi
	fi # end of valid email check

else
	printf "${RED}ERROR: Please change directories to the BaseQuery root directory${NC}\n"
fi
