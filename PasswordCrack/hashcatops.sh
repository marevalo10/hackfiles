#Some examples to be used
#Dictionaries:
#/usr/sharee/wordlist/rockyou.txt
#/usr/share/seclists/Passwords/probable-v2-top1575.txt
#/usr/share/seclists/Passwords/darkweb2017-top1000.txt
#/usr/share/seclists/Passwords/2020-200_most_used_passwords.txt
#/usr/share/seclists/Passwords/500-worst-passwords.txt
#/usr/share/seclists/Passwords/Common-Credentials/10-million-password-list-top-10000.txt
#
#Bruteforce password based on a fix lenght of 8 with 1 upper, 5 lower and 2 digits
hashcat -m 1000 -a 3 hashes.txt ?u?l?l?l?l?l?d?d --session hashsess1

#Dictionary + mask at the end composed by an special char + 2 digits
hashcat -m 1000 -a 6 hashes.txt words.txt ?s?d?d --session hashsess2

#Mask + Dictionary. Mask at the beginning composed by an special char + 2 digits
hashcat -m 1000 -a 7 hashes.txt words.txt ?s?d?d --session hashsess3

#Prepared rules. One good in https://github.com/hashcat/hashcat/blob/master/rules/best64.rule
hashcat -m 1000 -a 0 hash.txt words.txt -r best64.rule --session hashsess4

#Use the passwordlist xato with a minimun length of 10 and based on the rules defined in base64.rule
hashcat -m 1800 -r best64.rule -i --increment-min=10 unshadow.txt xato10Musernames.txt


#To continue a session: --restore hashsess1