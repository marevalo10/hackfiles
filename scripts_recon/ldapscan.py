import ldap3
ldapip=X.Y.Z.W
server = ldap3.Server(ldapip, get_info = ldap3.ALL, port =636, use_ssl = True)
connection = ldap3.Connection(server)
connection.bind()
server.info
connection.search(search_base='DC=vsphere,DC=local', search_filter='(&(objectClass=*))', search_scope='SUBTREE', attributes='*')
connection.entries

