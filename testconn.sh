#!/bin/bash

FILE_PATH="`dirname \"$0\"`"
FILE_NAME="servers.txt"
SERVERS="${FILE_PATH}/${FILE_NAME}"

numServer=$1
i=1
timeoutSeconds=3

# if the server number is not there, show the list of configured servers
if [ -z "$numServer" ]; then
	while read line; do
		# skip empty rows
		if [ -z "$line" ]; then
			continue
		fi
		
		if ! $(echo $line | grep --quiet '\[HEAD\]'); then
			counter=$i
			if [ ${#counter} -eq 1 ]; then
				counter=" $counter"
			fi
			
			i=$[i + 1]
		fi	
	done < ${SERVERS}
	
	clear
	
	printf "\t| %-9s | %-50s | %-7s |\n" "ID SERVER" "SERVER" "STATUS"
	
	for i in $(seq 1 $counter); do
		$0 $i
	done
	
	echo
	exit 0
fi

# server connection
found=0
while read line; do
	# skip empty rows
	if [ -z "$line" ]; then
		continue
	fi
	
	# skip heading rows
	if $(echo $line | grep --quiet '\[HEAD\]'); then
		continue
	fi
	
	# server found: break the cycle
	if [ $i -eq $numServer ]; then
		found=$i
		break
	fi
	
	i=$[i + 1]
done < ${SERVERS}

# check if is a valid id
if [ $found -eq 0 ]; then
	echo "Invalid server id $numServer"
	exit 1
fi

# valid id: use the last row of the cycle
if $(echo $line | grep --quiet '\[NOPASS\]'); then
	# no pass command
	printf "\t| %-9s | %-50s | \033[1;36m%-7s\033[0m |\n" $numServer $(echo $line | sed -r 's/\[NOPASS\]//g') "SKIPPED"
	
	#ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[NOPASS\]//g')
elif $(echo $line | grep --quiet '\[PASSGPG.*\]'); then
	# unix pass command
	pass=$(echo "$line" | grep -o '\[.*\]\+' | sed -r 's/\[PASSGPG=//g' | sed -r 's/\]//g')
	pass=$(pass $pass)
	
	if timeout ${timeoutSeconds}s sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[PASSGPG=.*\]//g') "cd"; then
		result="OK"
		color="32"
	else
		result="KO"
		color="31"
	fi
	
	printf "\t| %-9s | %-50s | \033[1;%-2sm%-7s\033[0m |\n" $numServer $(echo $line | sed -r 's/\[PASSGPG=.*\]//g') $color $result
elif $(echo $line | grep --quiet '\[PASS.*\]'); then
	# specified pass command
	pass=$(echo "$line" | grep -o '\[.*\]\+' | sed -r 's/\[PASS=//g' | sed -r 's/\]//g')
	
	if timeout ${timeoutSeconds}s sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[PASS=.*\]//g') "cd"; then
		result="OK"
		color="32"
	else
		result="KO"
		color="31"
	fi
	
	printf "\t| %-9s | %-50s | \033[1;%-2sm%-7s\033[0m |\n" $numServer $(echo "$line" |sed 's/\[PASS=.*\]//g') $color $result
else
	if timeout ${timeoutSeconds}s sshpass -e ssh -o StrictHostKeyChecking=no $line "cd"; then
		result="OK"
		color="32"
	else
		result="KO"
		color="31"
	fi
	
	printf "\t| %-9s | %-50s | \033[1;%-2sm%-7s\033[0m |\n" $numServer $line $color $result
fi

exit 0
