# ServerConn

Permit to connect via ssh, in command line, to a server stored in a "database" file.

## Configuration

First create a file named **servers.txt** in the serverconn directory.
This file will be used to create the menù of the command.

Create an header row:
```
[HEAD]My header
```

Create a server row that use the password stored in the **$SSHPASS** variable:
```
myserver.dummyserver.com
```

Create a server row that use the password stored in the **$SSHPASS** variable and specifying the username to use:
```
user@myserver.dummyserver.com
```

To specify the password to use, put at the beginning of the line:
```
[PASS=mypass]
```

To specify the password stored with pass unix command, put at the beginning of the line:
```
[PASSGPG=my/pass]
```

To **not** specify the password (in this case the password will be requested on login attempt), put at the beginning of the line:
```
[NOPASS]
```

## Usage

All servers are stored with an id, to show the menù, with the ids, launch the .sh file:
```bash
/your/path/serverconn/serverconn.sh
```

To connect to a server:
```bash
/your/path/serverconn/serverconn.sh [SERVER_ID]
```

To open in edit the servers.txt file (vim is the default editor, but you can specify a different editor after the 'e'):
```bash
/your/path/serverconn/serverconn.sh e
```
```bash
/your/path/serverconn/serverconn.sh e gedit
```

Backup the servers.txt file (the backup directory is the same where the program is stored):
```bash
/your/path/serverconn/serverconn.sh b
```

## Examples

servers.txt example:
```
[HEAD]My header
myserver.dummyserver.com
user@myserver.dummyserver.com
[PASS=mypass]myserver.dummyserver.com
[PASSGPG=my/pass]user@myserver.dummyserver.com
[NOPASS]myserver.dummyserver.com
```

Output menù produced:
```bash
My header
	 1 - myserver.dummyserver.com
	 2 - user@myserver.dummyserver.com
	 3 - myserver.dummyserver.com
	 4 - user@myserver.dummyserver.com
	 5 - myserver.dummyserver.com
```

Connect to the server numbered with the id 3:
```bash
/your/path/serverconn/serverconn.sh 3
```