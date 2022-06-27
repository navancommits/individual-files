$entryPresent=.\Check-HostNameEntry.ps1 "sc10unisc.dev.local"

if($entryPresent -eq $false)
{
	write-host "not present"
	#Add-HostsEntry -HostName "mynewentry"
}
if($entryPresent -eq $True)
{
	write-host "present"
	#Remove-HostsEntry -HostName "mynewentry"
}