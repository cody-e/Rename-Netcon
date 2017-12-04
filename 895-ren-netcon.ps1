###############################################################
<#
.SYNOPSIS
This script renames all the network connections in incremental order based on the MAC Addresses.
You must run the script as an administrator.
.DESCRIPTION
This script takes an optionally supplied network name and or temporary name, and renames the
network connections on the local machine. If names are not provided it uses the default values of
"Local Area Connection" for the network name and "Network" for the temporary name. The network
connections are sorted in ascending order on their MAC Addresses, and then renamed incrementally
using the temporary name first, to avoid conflicts, and then the new network name.
.PARAMETER NetName
The name to which all the network connections should be renamed
.PARAMETER TempName
The temporary name that is used initially to avoid conflicts eg: renaming a connection to a name
that is already in use
.EXAMPLE
.\895-ren-netcon.ps1
.EXAMPLE
.\895-ren-netcon.ps1 -NetName "NewNetworkName" -TempName "TempNetworkName"
#>

#Get the new network name and temporary name as parameters. If no values are provided then use default values.
Param(
[string] $NetName = "Local Area Connection",
[string] $TempName = "Network"
)

#We have to rename everything twice so do it as a function

Function Rename-NICs($Name){
#Get the network adapters from WMI and sort by MAC Address. Filter out any disabled or disconnected adapters.
$NICList = get-wmiobject -query "Select * from win32_NetworkAdapter where NetConnectionID is not null and MACAddress is not null" |
            sort-object MACAddress

#We need a counter to perform the incremental naming
$counter = 0

Foreach ($NIC in $NICList){
   
    #the first NIC does not have a number at the end of the name eg:"Local Area Connection"
    If ($counter -eq 0){
        $netnum = ""}
    Else{
        $netnum = " " + [String] $counter
        }#End If
   
    #Set the name of the NIC to the new name plus the incremental number, and then save it
    $NIC.NetConnectionID = $Name + $netnum
    $NIC.put() | out-null
   
    #Increment the counter and repeat
    $counter += 1
    }#End Foreach

}#End Function

#Use the function to change them all to a temporary name to avoid conflicts
Rename-NICs $TempName

#Use the function to change them all to the final correct names
Rename-NICs $NetName
###############################################################
