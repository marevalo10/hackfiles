#! /usr/bin/env python3
# Title : Ldap search in a server
# Date: 11/09/2022
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
    parser.add_option("-cn", dest="cn", help=msg)
    msg = "Output file to save the information collected"
    parser.add_option("-o", "--output", dest="filename", help=msg)

    (options, args) = parser.parse_args()

    if options.host:
        ports=[389,636]
        ldapfilter="(&(objectClass=*))"
        usessl = False
        for port in ports:
            (srvinfo, ldapcontent) = ldapsearch(options.host, port, options.cn, ldapfilter, usessl)
            if srvinfo:
                log("Success! There are some results to show using port {}".format(port))
                print("Server information received:")
                printdict(srvinfo)
                if ldapcontent:
                    print("*******************************************************")
                    print("LDAP content received: ")
                    print("*******************************************************")
                    printdict(ldapcontent)
                    #Look for SPN's
                    ldapFilter = "(&(objectClass=user)(objectCategory=user)(servicePrincipalName=*))"
                    (srvinfo, spncontent) = ldapsearch(options.host, port, options.cn, ldapfilter, usessl)
                    if spncontent:
                        print("*******************************************************")
                        print("Service Principal Accounts found: ")
                        print("*******************************************************")
                        printdict(spncontent)
                        if options.filename:
                            with open(filename,"x") as outfile:
                                outfile.write(spncontent)
                    else:
                        print("No Service Principal Accounts found!!")
                else:
                    print("No information returned by the server!!")
            else:
                print("No server info on port {}".format(port))
            usessl = True
    else:
        parser.print_help()
        sys.exit(-1)

def printdict(dicttoprint):
    results = json.dump(dicttoprint,indent=4)
    print("{}".format(results))


def ldapsearch(ldapserver, ldapport, cn, ldapfilter, usessl):
    #Cleartext communication
    server = ldap3.Server(ldapserver, get_info = ldap3.ALL, port =ldapport, use_ssl = usessl)
    connection = ldap3.Connection(server)
    connection.bind()
    srvinfo = server.info
    connection.search(search_base=cn, search_filter=ldapfilter, search_scope='SUBTREE', attributes='*')
    ldapentries = connection.entries
    connection.close()
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
    print ("[{0}}] {1}}".format(datetime.datetime.now(), msg))


if __name__ == "__main__":
    main()

