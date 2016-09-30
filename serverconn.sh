#!/bin/bash

FILE_PATH="`dirname \"$0\"`"
FILE_NAME="servers.txt"
SERVERS="${FILE_PATH}/${FILE_NAME}"

numServer=$1
i=1
confKey='e'
bckKey='b'

# se il numero server non è passato, presento la lista dei server configurati
if [ -z "$numServer" ]; then

	clear

	while read line; do
		#salto le linee vuote
		if [ -z "$line" ]; then
			continue
		fi
		
		if $(echo $line | grep --quiet '\[HEAD\]'); then
			# linea di heading
			echo ""
			echo " $line" | sed -r 's/\[HEAD\]//g'
		else
			# linea di comando
			str=$(echo $line | sed -r 's/\[NOPASS\]//g' | sed -r 's/\[PASS.*\]//g')
		
			counter=$i
			if [ ${#counter} -eq 1 ]; then
				counter=" $counter"
			fi
			
			echo -e "\t$counter - $str" # stampo la riga del comando
			
			i=$[i + 1] # incremento il contatore
		fi	
	done < ${SERVERS}
	
	echo ""
	echo " Configurazione"
	echo -e "\t $confKey - per aggiungere/modificare/rimuovere i server (è possibile specificare un secondo parametro per indicare il programma di editor, default vi)"
	echo -e "\t $bckKey - per effettuare il backup del file di configurazione"
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
		
		echo "Backup effettuato: ${FILE_PATH}/$fileBck"

		exit 0
	;;
esac

# se arrivo qui significa che ho un id server al quale connettermi
# ottengo la riga relativa al server
found=0
while read line; do
	#salto le linee vuote
	if [ -z "$line" ]; then
		continue
	fi
	
	# salto le linee di heading
	if $(echo $line | grep --quiet '\[HEAD\]'); then
		continue
	fi
	
	# quando trovo la linea corretta rompo il ciclo
	if [ $i -eq $numServer ]; then
		found=$i
		break
	fi
	
	i=$[i + 1] # incremento il contatore
done < ${SERVERS}

# controllo che la scelta sia valida
if [ $found -eq 0 ]; then
	echo "Scelta non valida"
	exit 1
fi

# la scelta è valide e l'ultima linea era quella giusta
if $(echo $line | grep --quiet '\[NOPASS\]'); then
	ssh $(echo $line | sed -r 's/\[NOPASS\]//g')
elif $(echo $line | grep --quiet '\[PASS.*\]'); then
	pass=$(echo "$line" | grep -o '\[.*\]\+' | sed -r 's/\[PASS=//g' | sed -r 's/\]//g')
	
	sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $(echo $line | sed -r 's/\[PASS=.*\]//g')
else
	sshpass -e ssh -o StrictHostKeyChecking=no $line
fi

exit 0
