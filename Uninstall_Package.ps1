##############################################

[CmdletBinding()]

Param ( 	
		

	# Web Root folder 
	
    [Parameter(Mandatory = $true)]

    [string]

    [ValidateNotNullOrEmpty()]

    $SitePhysicalRoot = "C:\inetpub\wwwroot\sc103lkgsc.dev.local" ,	
	
	# Zip file by default to be present in current execution folder    

    [string]

    [ValidateNotNullOrEmpty()]

    $PackageFileLocation = "." 

)

[int]$startMs = (Get-Date).Millisecond


$ErrorActionPreference = "Stop";


$FileNameWithFullPath=(Get-Item ".\*.zip").FullName

$PackageFileName=Split-Path $FileNameWithFullPath -Leaf

Write-Host $SitePhysicalRoot"\App_Data\packages\"$PackageFileName

if (-not(Test-Path -Path $SitePhysicalRoot"\App_Data\packages\"$PackageFileName -PathType Leaf)) {
	
	Write-Host "No Package named " $PackageFileName " installed in the instance"
	
	Exit
	
}


# Unzip the package zip

Expand-Archive -Path "*.zip"  -Force

Write-Host "Analysing Package!"


#Write-Host $FileNameWithFullPath

$PackageFileLocation=Split-Path $FileNameWithFullPath -Parent

#Write-Host "Package file unzip path " + $PackageFileLocation

$FileNameWithoutExt=(Get-Item ".\*.zip").BaseName

Write-Host "Package file whole path "$PackageFileLocation\$FileNameWithoutExt

Expand-Archive -Path $PackageFileLocation\$FileNameWithoutExt\package.zip  -DestinationPath $PackageFileLocation\$FileNameWithoutExt -Force

$SourcePath=$PackageFileLocation + "\" + $FileNameWithoutExt + "\files"

Write-host "Source path " $SourcePath

Write-host "Destination path " $SitePhysicalRoot


$files = get-childitem -Path $SourcePath -recurse -Force -File

Write-host "Starting uninstall Operation at " $SitePhysicalRoot

foreach ($file in $files)
{
	
	$fileName=$file.FullName.Replace($SourcePath,$SitePhysicalRoot)
	
	Write-Host "Removing "$fileName
	
	if (test-path $fileName) {
		remove-item $fileName -force
	}
	
}


Write-Host "Clearing blank folders at " $SitePhysicalRoot

$Directories = get-childitem $SitePhysicalRoot -directory -recurse | Where { (get-childitem $_.fullName).count -eq 0 } | select -expandproperty FullName
$Directories | Foreach-Object { Remove-Item $_ }

Write-Host "Removing package zip from " $SitePhysicalRoot

Remove-item $SitePhysicalRoot"\App_Data\packages\"$PackageFileName -Force

Write-Host "Package uninstall process complete!"


[int]$endMs = (Get-Date).Millisecond

# Calculate elapsed time
Write-Host "Execution time in milliseconds " $($endMs - $startMs)

##############################################
