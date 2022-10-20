

#Build LDAP filters to look for users with SPN values registered for current domain
$ldapFilter = "(&(objectclass=user)(objectcategory=user)(servicePrincipalName=*))"
$domain = New-Object System.DirectoryServices.DirectoryEntry
$search = New-Object System.DirectoryServices.DirectorySearcher
$search.SearchRoot = $domain
$search.PageSize = 1000
$search.Filter = $ldapFilter
$search.SearchScope = "Subtree"
#Execute Search
$results = $search.FindAll()
#Display SPN values from the returned objects
foreach ($result in $results)
{
    $userEntry = $result.GetDirectoryEntry()
    Write-Host "User Name = " $userEntry.name
    foreach ($SPN in $userEntry.servicePrincipalName)
    {
        Write-Host "SPN = " $SPN       | Out-File -FilePath .\spnaccounts.txt -Append
    }
    Write-Host ""   
}




#Build LDAP filter to find service accounts based on naming conventions
$ldapFilter = "(&(objectclass=Person)(cn=*svc*))"
$domain = New-Object System.DirectoryServices.DirectoryEntry
$search = New-Object System.DirectoryServices.DirectorySearcher
$search.SearchRoot = $domain
$search.PageSize = 1000
$search.Filter = $ldapFilter
$search.SearchScope = "Subtree"

#Add list of properties to search for
$objProperties = "name"
Foreach ($i in $objProperties){$search.PropertiesToLoad.Add($i)}

#Execute Search
$results = $search.FindAll()
#Display values from the returned objects
foreach ($result in $results)
{
    $userEntry = $result.GetDirectoryEntry()
    Write-Host "User Name = " $userEntry.name | Out-File -FilePath .\serviceaccounts.txt -Append
    Write-Host ""   | Out-File -FilePath .\serviceaccounts.txt -Append
} 


#Finding service accounts based on OU
$ldapFilter = "(&(objectClass=organizationalUnit)(|name=*Service*)(name=*svc*)))"
$search = New-Object System,DirecoryServices.DirectorySearcher
$search.SearchRoot = "LDAP://OU=Service Accounts,OU=JEFFLAB,DC=local"
$search.PageSize = 1000
$search.Filter = $ldapFilter
$search.SearchScope = "Subtree"


#Find password never expires accounts
$ldapFilter = "(&(objectclass=user)(objectcategory=user)(useraccountcontrol:1.2.840.113556.1.4.803:=65536))"


