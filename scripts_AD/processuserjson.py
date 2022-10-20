#! /usr/bin/python3
# Title : read user.json extracted by bloodhound and process the information to facilitate the analysis
# Date: 11/09/2022

#Extract the data from the json

import ldap3
import argparse
from optparse import OptionParser
import os.path
import sys
import datetime
import json
import numpy as np
import pandas as pd
import csv

filename="20220907101003_users.json"
with open(filename,"r") as inputfile:
    results=json.load(inputfile)
meta = results['meta']
data = results['data']
print("Number of objects loaded: {}".format(len(data)))
# Obtain the key values: dict_keys(['AllowedToDelegate', 'ObjectIdentifier', 'PrimaryGroupSID', 'Properties', 'Aces', 'SPNTargets', 'HasSIDHistory', 'IsDeleted', 'IsACLProtected'])
datafields = data[0].keys()
# Column 'Properties' contains all the user's information
# dict_keys users (['name', 'domain', 'domainsid', 'distinguishedname', 'unconstraineddelegation', 'trustedtoauth', 'passwordnotreqd', 'enabled', 'lastlogon', 'lastlogontimestamp', 'pwdlastset', 'dontreqpreauth', 'pwdneverexpires', 'sensitive', 'serviceprincipalnames', 'hasspn', 'displayname', 'email', 'title', 'homedirectory', 'description', 'userpassword', 'admincount', 'sidhistory', 'whencreated', 'unixpassword', 'unicodepassword', 'logonscript', 'samaccountname', 'sfupassword'])
userproperties = data [0]['Properties'].keys()
# Creates an array with all users information and checks if any object has SPNTargets. Creates an additional array for special accounts!
userslist = []
specialuserslist = []
specialusersindex = []
domainname = ""
domainsid = ""
for i, user in enumerate(data):
    # Domian information
    if (len(user['Properties']) == 3):
        adinfo = json.dumps(user['Properties'],indent=4)
        print("Domain information stored in position {0}: \n{1}".format(i,adinfo))
        domain = user['Properties']['domain']
        domainsid = user['Properties']['domain']
    # Special accounts
    elif (len(user['Properties']) != 30):
        print("User {0} has a different number of columns: {1}".format(i,len(user['Properties'])))
        #print("User info: {0}".format(user['Properties']))
        specialuserslist.append(list(user['Properties'].values()))
        specialusersindex.append(i)
        if (len(specialusersindex)==1):
            # Special users have one more column: 'allowedtodelegate' (number 24). This is a list with all the accounts permitted to be delegated!
            # dict_keys especial users (['name', 'domain', 'domainsid', 'distinguishedname', 'unconstraineddelegation', 'trustedtoauth', 'passwordnotreqd', 'enabled', 'lastlogon', 'lastlogontimestamp', 'pwdlastset', 'dontreqpreauth', 'pwdneverexpires', 'sensitive', 'serviceprincipalnames', 'hasspn', 'displayname', 'email', 'title', 'homedirectory', 'description', 'userpassword', 'admincount', 'allowedtodelegate', 'sidhistory', 'whencreated', 'unixpassword', 'unicodepassword', 'logonscript', 'samaccountname', 'sfupassword'])
            specialusersproperties = (user['Properties'].keys())
    # User accounts
    else: 
        #Conver the user values in a list
        userslist.append(list(user['Properties'].values()))
    if (user['SPNTargets'] or user['AllowedToDelegate'] or user['IsACLProtected'] or user['IsDeleted']):
        print("Position {0} / username {5} has something special: SPNTargets: {1}, AllowedToDelegate: {2}, IsACLProtected: {3}, IsDeleted: {4}".format(i, user['SPNTargets'], user['AllowedToDelegate'], user['IsACLProtected'], user['IsDeleted'], user['Properties']['name']))

print("Process finilized. A total of {0} users were analised.".format(i+1))
print("{0} special users were identified in these positions: \n\t {1}.".format(len(specialuserslist),specialusersindex))

# Stores the userslist in a CSV file
with open('users.csv', 'w', newline='') as usersfile: 
    write = csv.writer(usersfile) 
    write.writerow(userproperties) 
    write.writerows(userslist) 

# Stores the specialuserslist in a CSV file
with open('specialusers.csv', 'w', newline='') as specialusersfile: 
    write = csv.writer(specialusersfile) 
    write.writerow(specialusersproperties) 
    write.writerows(specialuserslist) 
    
for i, user in enumerate(userslist):    
    # Print the values in a file
    if (len(user) != 30):
        print("User {0} has a different number of columns: {1}".format(i,len(user)))
        print("User info: {0}".format(user))
#Extract the properties array for each user
allusersinfo = pd.DataFrame(arrayusers, columns=userproperties)
dfobj = dfobj.to_json(orient='split')
 
print("NumPy array to Json:")
print(dfobj)




#Obtain the detailed user information:
subkeys = data[0]['Properties'].keys()
fieldnames = ['name', 'domain', 'domainsid', 'distinguishedname', 'unconstraineddelegation', 'trustedtoauth', 'passwordnotreqd', 'enabled', 'lastlogon', 'lastlogontimestamp', 'pwdlastset', 'dontreqpreauth', 'pwdneverexpires', 'sensitive', 'serviceprincipalnames', 'hasspn', 'displayname', 'email', 'title', 'homedirectory', 'description', 'userpassword', 'admincount', 'sidhistory', 'whencreated', 'unixpassword', 'unicodepassword', 'logonscript', 'samaccountname', 'sfupassword']
dataMatrix = np.array([data[i]['Properties'] for i in orderedNames])
for i in range [0,10]:
    user = data[i]
    samaccountname, domainsid,passwordnotreqd, enabled, dontreqpreauth, pwdneverexpires, sensitive, serviceprincipalnames, hasspn, admincount, unixpassword, logonscript, sfupassword

    for key, value in data.iteritems():
        print key, 'is:', value
    print ''