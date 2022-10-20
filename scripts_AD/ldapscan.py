#! /usr/bin/python3
# Title : Ldap search in a server
# Date: 11/09/2022
# For a quick test, run this in python:
"""
#You can use ldapsearch utility or inside python complete it manually
# Examples Using ldapsearch:
ldapsearch -x -b "DC=internal,DC=mycompany,DC=com,DC=au" -H ldap://10.64.16.50
ldapsearch -x -b "DC=internal,DC=mycompany,DC=com,DC=au" -H ldap://10.64.16.50 "(&(objectclass=account)(uid=marevalo))"
ldapsearch -x -b "DC=internal,DC=mycompany,DC=com,DC=au" -H ldap://10.64.16.50 "(&(&(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=4194304))))"
# If bind is required (authentication) using an admin account then -D is required. -W is to be asked by the paswsord:
ldapsearch -x -b "DC=internal,DC=mycompany,DC=com,DC=au" -H ldap://10.64.16.50 -D "cn=marevalo,DC=internal,DC=mycompany,DC=com,DC=au" -W "(&(objectclass=account)(uid=ma*))"
# Additional examples: https://www.junosnotes.com/linux/how-to-search-ldap-using-ldapsearch-examples/

# Python code to test it quickly:
import ldap3, json
cn="DC=internal,DC=bupa,DC=com,DC=au"
host="internal.bupa.com.au"
ldapfilter="(&(objectClass=*))"
port=389    #or 636, 3268, 3269
usessl = False  # or True
server = ldap3.Server(host, get_info = ldap3.ALL, port=port, use_ssl = usessl)
connection = ldap3.Connection(server)
connection.bind() 
srvinfo = server.info 
print("{0}".format(srvinfo))
connection.search(search_base=cn, search_filter=ldapfilter, search_scope='SUBTREE', attributes='*')
ldapentries = connection.entries
results = ldapentries
if isinstance(ldapentries,dict):
    results = json.dumps(ldapentries,indent=4)
print("{0}".format(results))
ldapFilter = "(&(objectClass=user)(objectCategory=user)(servicePrincipalName=*))"
ldapFilter = "(SAMAccountName=marevalo)"

"""
#  Author: M4RC14N0

import ldap3
import argparse
from optparse import OptionParser
import os.path
import sys
import datetime
import json

def main():
    parser = OptionParser(description= """This program will look for any information in the LDAP server using insecure (389) and secure (636) ports
    """)
    #reverse shell
    msg = "Hostname or Server IP"
    parser.add_option("-s","--server", dest="host", help=msg)
    msg = "Domain CN route. example: \"DC=oscp,DC=local\""
    parser.add_option("-c","--cn", dest="cn", help=msg)
    msg = "Output file to save the information collected"
    parser.add_option("-o", "--output", dest="filename", help=msg)

    (options, args) = parser.parse_args()

    if options.host:
        ports=[389,636]
        usessl = False
        for port in ports:
            ldapfilter="(&(objectClass=*))"
            (srvinfo, ldapentries) = ldapsearch(options.host, port, options.cn, ldapfilter, usessl)
            if srvinfo:
                log("Success! There are some results to show using port {0}".format(port))
                print("Server information received:")
                printdict(srvinfo,options.filename)
                if ldapentries:
                    print("*******************************************************")
                    print("LDAP content received: ")
                    print("*******************************************************")
                    printdict(ldapentries)
                    #Look for SPN's
                    ldapFilter = "(&(objectClass=user)(objectCategory=user)(servicePrincipalName=*))"
                    (srvinfo, spncontent) = ldapsearch(options.host, port, options.cn, ldapfilter, usessl)
                    if spncontent:
                        print("*******************************************************")
                        print("Service Principal Accounts found: ")
                        print("*******************************************************")
                        printdict(spncontent,options.filename)
                    else:
                        print("No Service Principal Accounts found!!")
                else:
                    print("No information returned by the server!!")
            else:
                print("No server info on port {0}".format(port))
            usessl = True
    else:
        parser.print_help()
        sys.exit(-1)

def printdict(results,filename):
    if isinstance(results,dict):
        results = json.dumps(results,indent=4)
    print("{0}".format(results))
    if filename:
        with open(filename,"a") as outfile:
            #json.dump(results,outfile)
            outfile.write(results)
            print("Information gathered:\n {0}".format(results))
            print("File {0} saved with the json content gathered".format(filename))

def readjson(filename):
    if filename:
        with open(filename,"r") as inputfile:
            results=json.load(inputfile)
            print("Information readed from file {1}:\n {0}".format(results, filename))


def ldapsearch(host, port, cn, ldapfilter, usessl):
    #Cleartext communication
    server = ldap3.Server(host, get_info = ldap3.ALL, port =port, use_ssl = usessl)
    connection = ldap3.Connection(server)
    srvinfo = False
    ldapentries = False
    if connection.bind():
        srvinfo = server.info
        if connection.search(search_base=cn, search_filter=ldapfilter, search_scope='SUBTREE', attributes='*'):
            ldapentries = connection.entries
    #connection.close()
    return srvinfo,ldapentries

LAST_MSG = None
def log(msg):
    global LAST_MSG

    show = False
    if LAST_MSG is None:
        show = True
    elif LAST_MSG != msg:
        show = True

    LAST_MSG = msg
    print ("[{0}] {1}".format(datetime.datetime.now(), msg))


if __name__ == "__main__":
    main()

