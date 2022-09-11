#From https://www.netwrix.com/cracking_kerberos_tgs_tickets_using_kerberoasting.html
#Build LDAP filter to look for users with SPN values registered for current domain
$ldapFilter = "(&(objectClass=user)(objectCategory=user)(servicePrincipalName=*))"
$domain = New-Object System.DirectoryServices.DirectoryEntry
$search = New-Object System.DirectoryServices.DirectorySearcher
$search.SearchRoot = $domain
$search.PageSize = 1000
$search.Filter = $ldapFilter
$search.SearchScope = "Subtree"
#Execute Search
$results = $search.FindAll()
#Display SPN values from the returned objects
$Results = foreach ($result in $results)
{
	$result_entry = $result.GetDirectoryEntry()
 
	$result_entry | Select-Object @{
		Name = "Username";  Expression = { $_.sAMAccountName }
	}, @{
		Name = "SPN"; Expression = { $_.servicePrincipalName | Select-Object -First 1 }
	}
}
 
$Results