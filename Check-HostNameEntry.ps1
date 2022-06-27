# ==============================================================================================
# 
# Microsoft PowerShell Source File 
# 
# NAME: Check-HostNameEntry.ps1 
# 
# USAGE: .\Check-HostNameEntry.ps1  -HostNameString "entrytocheck"
# 
#Reference: https://www.sapien.com/blog/wp-content/uploads/2009/02/parse-hosts.txt
# 
# COMMENT: This script will check if the local computer windows hosts file has an specific entry
# 
#returns $true or $false
#can be used in calling script as follows: 

#$entryPresent=.\Check-HostNameExists.ps1 "cm.sitecore.local"
#if ($entryPresent -eq $false) 
#{write-host "not present"}
#else {write-host "present"}
# ==============================================================================================

param (
			[Parameter(Mandatory = $true)]
			[ValidateNotNullOrEmpty()]
			[string] 
			$HostNameString
	)
try
{
	
	#write-host "Trying to match : $HostNameString"
	$result=$false
	#define a regex to return first NON-whitespace character
	[regex]$r="\S"
	#strip out any lines beginning with # and blank lines
	$HostsData = Get-Content $env:windir\system32\drivers\etc\hosts | where {
		(($r.Match($_)).value -ne "#") -and ($_ -notmatch "^\s+$") -and ($_.Length -gt 0)
	}
	 
	#write-host $HostsData
	if ($HostsData){
			#only process if something was found in HOSTS
			$HostsData | foreach {
				#created named values                              
				$_ -match "(?<IP>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+(?<HOSTNAME>\S+)" | Out-Null
							
				$ip=$matches.ip				
				$hostname=$matches.hostname				
				
				if ($result -eq $false)
				{
					write-host $hostname
					if ($hostname -eq $HostNameString) {
						$result=$true
						Write-Host "matched"
						return 	$result	
						#break													
					}
				}
				else
				{
					return 	$result	
					#break
				}
				
					  
			} #end ForEach
	} #end If $HostsData
	else {
			Write-Host ("{0} has no entries in its HOSTS file." -f $computername.toUpper()) -foreground Magenta
			$result=$false			
	}
	
	return 	$result		
}
catch
{
	write-host  "error"
	$result=$false
	return $result
}