#! /usr/bin/env python3
# Title : MY PROGRAM
# Date: DD/MM/YYYY
#  Author: M4RC14N0

import argparse
from optparse import OptionParser
import os.path
import sys
import datetime

def main():
    parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter,
    description= """Any detail about the program
        that helps to understand the prupose
    """)
    parser.add_argument("server", help="Server to target", type=str)
    parser.add_argument("-p", "--port", help="Port to use defaults to 445", type=int)
    parser.add_argument("-u", "--username", help="Username to connect as defaults to nobody", type=str)
    parser.add_argument("--password", help="Password for user default is empty", type=str)
    parser.add_argument("--local", help="Perform local attack. Payload should be fullpath!", type=bool)
    args = parser.parse_args()

    if not os.path.isfile(args.payload):
        print("[!] Unable to open: " + args.payload)
        sys.exit(-1)

    port = 445
    user = "nobody"
    password = ""
    fullpath = ""

    if args.port:
        port = args.port
    if args.username:
        user = args.username
    if args.password:
        password = args.password
    if args.local:
        fullpath = args.payload

    #ANOTHER:
    parser = OptionParser()

    parser.add_option("-t", "--target", dest="sambaTarget", help="target ip address")
    parser.add_option("-p", "--port", dest="sambaPort", default=445, help="target port")

    msg = "module path on target server (do not use to auto-resolve the module's path)"
    parser.add_option("-m", "--module", dest="module", help=msg)

    msg = "Use a 32 bit payload (by default, it uses a x86_64 one)"
    parser.add_option("-x", "--use-x32", dest="is_32", default=False, help=msg)

    msg = "Shell to use (by default /bin/sh)"
    parser.add_option("-s", "--shell", dest="shell", default="/bin/sh", help=msg)

    msg = "Use old entry point for share library (samba 3.5.0 / 3.6.0))"
    parser.add_option("-o", "--old-version", dest="sambaVersion", default=0, help=msg)

    msg = "Do not compile libimplant*.so"
    parser.add_option("-n", "--no-compile", dest="noimplant", default=0, help=msg)

    #login
    msg = "Username to login into the Samba server"
    parser.add_option("-u", "--username", dest="username", help=msg)
    msg = "Password to login into the Samba server"
    parser.add_option("-P", "--password", dest="password", help=msg)

    #reverse shell
    msg = "Hostname for reverse shell"
    parser.add_option("--rhost", dest="host", help=msg)
    msg = "Port for reverse shell"
    parser.add_option("--rport", dest="port", default=31337, help=msg)

    msg = "Use this option if you need to run a custom .so"
    parser.add_option("--custom", dest="customBinary", default="", help=msg)

    (options, args) = parser.parse_args()
    if options.sambaTarget:
        exploit = CSmbExploit(options)
        if exploit.exploit():
            log("Success! You should have a reverse shell by now :)")
    else:
        parser.print_help()
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
           