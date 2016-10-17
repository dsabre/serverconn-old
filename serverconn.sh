#!/bin/bash

FILE_PATH="`dirname \"$0\"`"
FILE_NAME="servers.txt"
SERVERS="${FILE_PATH}/${FILE_NAME}"

numServer=$1
i=1
confKey='e'
bckKey='b'

# if the server number is not there, show the list of configured servers
if [ -z "$numServer" ]; then

	clear

	while read line; do
		# skip empty rows
		if [ -z "$line" ]; then
			continue
		fi
		
		if $(echo $line | grep --quiet '\[HEAD\]'); then
			# heading row
			echo ""
			echo " $line" | sed -r 's/\[HEAD\]//g'
		else
			# command row
			str=$(echo $line | sed -r 's/\[NOPASS\]//g' | sed -r 's/\[PASS.*\]//g')
		
			counter=$i
			if [ ${#counter} -eq 1 ]; then
				counter=" $counter"
			fi
			
			echo -e "\t$counter - $str"
			
			i=$[i + 1]
		fi	
	done < ${SERVERS}
	
	echo ""
	echo " Configuration"
	echo -e "\t $confKey - to add/edit/remove the servers (it's possible to specify a second parameter to set the editor program, default is vi)"
	echo -e "\t $bckKey - to generate a backup of the configuration file"
	echo ""
	
	exit 0
fi

case $numServer in
	$confKey)
		prog=$2
		if [ -z "$prog" ]; then
			prog='vi'
		fi
		
		${prog} ${SERVERS}
		
		exit 0
	;;
	$bckKey)
		dt=$(date '+%Y%m%d%H%M%S')
	
		fileBck="servers_$dt.tar.gz"
		
		cd ${FILE_PATH}
		
		tar pczf $fileBck ${FILE_NAME}
		
		echo "Backup created: ${FILE_PATH}/$fileBck"

		exit 0
	;;
esac

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
	ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[NOPASS\]//g')
elif $(echo $line | grep --quiet '\[PASSGPG.*\]'); then
	# unix pass command
	pass=$(echo "$line" | grep -o '\[.*\]\+' | sed -r 's/\[PASSGPG=//g' | sed -r 's/\]//g')
	pass=$(pass $pass)
	
	sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[PASSGPG=.*\]//g')
elif $(echo $line | grep --quiet '\[PASS.*\]'); then
	# specified pass command
	pass=$(echo "$line" | grep -o '\[.*\]\+' | sed -r 's/\[PASS=//g' | sed -r 's/\]//g')
	
	sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[PASS=.*\]//g')
else
	# sshpass command
	sshpass -e ssh -o StrictHostKeyChecking=no $line
fi

exit 0

