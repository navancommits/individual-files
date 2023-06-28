param(
	
	[Parameter(Mandatory = $true)]

    [string]

    [ValidateNotNullOrEmpty()]

	$SitePrefix = "sc103instance",  	

		

	[Parameter(Mandatory = $false)]
	
	[ValidateNotNullOrEmpty()]
	
	[string]$InstallSourcePath,
	

	# The root folder with the WDP files.

    [string]    

    $PatchType = "cumulative",

	

	# Root folder where the site is installd. If left on the default [systemdrive]:\inetpub\wwwroot will be used

    [string]

    $SitePhysicalRoot = "c:\inetpub\wwwroot\" ,

	

	# Site suffix matches what is used by SIA

    [string]

    $SiteSuffix = ".dev.local" 

)


$SitePhysicalRootSitecore = $SitePhysicalRoot  + $SitePrefix.Trim() + "sc" + $SiteSuffix

$SitePhysicalRootxConnSrvr=$SitePhysicalRoot  + $SitePrefix.Trim() + "xconnect" + $SiteSuffix

$SitePhysicalRootIdSrvr=$SitePhysicalRoot  + $SitePrefix.Trim() + "identityserver" + $SiteSuffix

Write-Host "Site root" $SitePhysicalRootSitecore

Write-Host "Id root" $SitePhysicalRootIdSrvr


if (-not(Test-Path "Sitecore 10.3.0 rev. 008463 (Setup XP0 Developer Workstation rev. 1.5.0-r11).zip" -PathType Leaf)) {
	$preference = $ProgressPreference
	$ProgressPreference = "SilentlyContinue"


	$sitecoreDownloadUrl = "https://sitecoredev.azureedge.net"
	$packages = @{
	"Sitecore 10.3.0 rev. 008463 (Setup XP0 Developer Workstation rev. 1.5.0-r11).zip" = "https://sitecoredev.azureedge.net/~/media/8F77892C62CB4DC698CB7688E5B6E0D7.ashx?date=20221130T160548"
}


# download packages from Sitecore
$packages.GetEnumerator() | ForEach-Object {

	$filePath = Join-Path $InstallSourcePath $_.Key
	$fileUrl = $_.Value

	if (Test-Path $filePath -PathType Leaf)
	{
		Write-Host ("Required package found: '{0}'" -f $filePath)
	}
	else
	{
		if ($PSCmdlet.ShouldProcess($fileName))
		{
			Write-Host ("Downloading '{0}' to '{1}'..." -f $fileUrl, $filePath)
			Invoke-WebRequest -Uri $fileUrl -OutFile $filePath  -UseBasicParsing
		}
		else
		{
			# Download package
			Invoke-WebRequest -Uri $fileUrl -OutFile $filePath -UseBasicParsing
		}
	}
}
}

Expand-Archive -Force -Path 'Sitecore * XP0 Developer Workstation rev. *.zip' -DestinationPath ".\xp0"


$ProgressPreference = $preference

Write-Host "Unzipped Sitecore Zip"


################################Unzip Sitecore wdp file - start

$SitecoreWebSiteZipPath = $InstallSourcePath + "xp0\Sitecore * rev. * (OnPrem)_single.scwdp.zip"

Write-Host "Sitecore Wdp zip file whole path "$SitecoreWebSiteZipPath


$SitecoreWebsiteZipPath = (Get-ChildItem $SitecoreWebSiteZipPath).FullName	

Write-Host "Website zip Path" $SitecoreWebsiteZipPath


$SitecoreWdpFileLocation=Split-Path $SitecoreWebSiteZipPath -Parent

Write-Host "Sitecore Wdp file unzip path " $SitecoreWdpFileLocation


Write-Host "Sitecore Wdp file whole path" $SitecoreWdpFileLocation"\SitecoreWdp"



Expand-Archive -Path $SitecoreWebSiteZipPath  -DestinationPath $SitecoreWdpFileLocation"\SitecoreWdp" -Force

$SourcePath=$SitecoreWdpFileLocation + "\SitecoreWdp\Content\Website" 

Write-host "Source path " $SourcePath

################################Unzip Sitecore wdp file - end

################################Unzip Sitecore ID wdp file - start

$SitecoreIDWebSiteZipPath = $InstallSourcePath + "xp0\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.scwdp.zip"

Write-Host "Sitecore Wdp ID zip file whole path "$SitecoreIDWebSiteZipPath



$SitecoreIDWebsiteZipPath = (Get-ChildItem $SitecoreIDWebSiteZipPath).FullName	

Write-Host "ID Website zip Path" $SitecoreIDWebsiteZipPath


$SitecoreIDWdpFileLocation=Split-Path $SitecoreIDWebSiteZipPath -Parent


Write-Host "Sitecore Wdp ID file whole path" $SitecoreIDWdpFileLocation"\SitecoreIdWdp"


Expand-Archive -Path $SitecoreIDWebSiteZipPath  -DestinationPath $SitecoreIDWdpFileLocation"\SitecoreIdWdp" -Force

$IdSourcePath=$SitecoreIDWdpFileLocation + "\SitecoreIdWdp\Content\Website" 

Write-host "Id Source path " $IdSourcePath

################################Unzip Sitecore ID wdp file - end


################################Unzip Sitecore xconnect wdp file - start

$SitecorexConnWebSiteZipPath = $InstallSourcePath + "xp0\Sitecore * rev. * (OnPrem)_xp0xconnect.scwdp.zip"

Write-Host "Sitecore Wdp xConnect zip file whole path "$SitecorexConnWebSiteZipPath


$SitecorexConnWebsiteZipPath = (Get-ChildItem $SitecorexConnWebSiteZipPath).FullName	

Write-Host "xConnect Website zip Path" $SitecorexConnWebsiteZipPath


$SitecorexConnWdpFileLocation=Split-Path $SitecorexConnWebSiteZipPath -Parent


Write-Host "Sitecore Wdp xConnect file whole path" $SitecorexConnWdpFileLocation"\SitecorexConnWdp"


Expand-Archive -Path $SitecorexConnWebSiteZipPath  -DestinationPath $SitecorexConnWdpFileLocation"\SitecorexConnWdp" -Force

$xConnSourcePath=$SitecorexConnWdpFileLocation + "\SitecorexConnWdp\Content\Website" 

Write-host "xConn Source path " $xConnSourcePath


################################Unzip Sitecore xconnect wdp file - end



$HotFixFileName=Get-ChildItem -Path $InstallSourcePath  -Filter *cumulative*.zip

Write-Host "Unzipping the hotfix zip file - " $HotFixFileName

Expand-Archive -Path $HotFixFileName  -Force -DestinationPath "Hotfix"




if ($PatchType -eq 'cumulative')

{

	# The path to the Sitecore cumulative Package to Deploy.	

	$SitecorePackageZipPath = $InstallSourcePath + ".\Hotfix\Sitecore * rev. * (OnPrem)_single.cumulative.delta.scwdp.zip"
	
	Write-Host $SitecorePackageZipPath
	
	# The path to the Identity Server cumulative Package to Deploy.

	$IdentityServerPackageZipPath = $InstallSourcePath + ".\Hotfix\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.cumulative.delta.scwdp.zip"
	
	Write-Host $IdentityServerPackageZipPath

	# The path to the xConnect Server cumulative Package to Deploy.

	$XConnectPackageZipPath = $InstallSourcePath + ".\Hotfix\Sitecore * rev. * (OnPrem)_xp0xconnect.cumulative.delta.scwdp.zip"
	
	Write-Host $XConnectPackageZipPath	

}

else

{

	# The path to the Sitecore Package to Deploy.

	$SitecorePackageZipPath = $InstallSourcePath + "\Hotfix_Delta\Sitecore * rev. * (OnPrem)_single.delta.scwdp.zip"

	# The path to the Identity Server Package to Deploy.

	$IdentityServerPackageZipPath = $InstallSourcePath + "\Hotfix_Delta\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.delta.scwdp.zip"

	# The path to the xConnect Server Package to Deploy.

	$XConnectPackageZipPath = $InstallSourcePath + "\Hotfix_Delta\Sitecore * rev. * (OnPrem)_xp0xconnect.delta.scwdp.zip"

}



# The path to the Sitecore  Package to Deploy.

$SitecorePackagePath = (Get-ChildItem $SitecorePackageZipPath).FullName	


# The path to the Identity Server  Package to Deploy.

$IdentityServerPackagePath = (Get-ChildItem $IdentityServerPackageZipPath).FullName

# The path to the xConnect Server  Package to Deploy.

$XConnectPackagePath = (Get-ChildItem $XConnectPackageZipPath).FullName



$SitecorePackageUnzipPath = (Get-Item $SitecorePackageZipPath).FullName

$SitecorePackageUnzipDir = (Get-Item $SitecorePackageUnzipPath ).DirectoryName+"\sitecore"



$SitecoreIdentityServerPackageUnzipPath = (Get-Item $IdentityServerPackageZipPath).FullName

$SitecoreIdentityServerPackageUnzipDir = (Get-Item $SitecoreIdentityServerPackageUnzipPath ).DirectoryName+"\identity"



$SitecorexConnectServerPackageUnzipPath = (Get-Item $XConnectPackageZipPath).FullName

$SitecorexConnectServerPackageUnzipDir = (Get-Item $SitecorexConnectServerPackageUnzipPath ).DirectoryName+"\xconnect"


Write-Host "Unzipping the Sitecore Package file to - "  $SitecorePackageUnzipDir 

Expand-Archive -Path $SitecorePackagePath -Destination $SitecorePackageUnzipDir  -Force


Write-Host "Unzipping the Identity Package file to - "  $SitecoreIdentityServerPackageUnzipDir 

Expand-Archive -Path $IdentityServerPackagePath -Destination $SitecoreIdentityServerPackageUnzipDir  -Force

Write-Host "Unzipping the xConnect Package file to - "  $SitecorexConnectServerPackageUnzipDir

Expand-Archive -Path $XConnectPackagePath -Destination $SitecorexConnectServerPackageUnzipDir  -Force

#####################################################Sitecore webroot wdp package unzip and processing - start

$SitecoreHotFixTraversePath=$SitecorePackageUnzipDir + "\content\website"

Write-Host "Hotfix start path "$SitecoreHotFixTraversePath

$files = get-childitem -Path $SitecoreHotFixTraversePath -recurse -Force -File

Write-host "Starting revert Operation at " $SitePhysicalRootSitecore

foreach ($file in $files)
{
	$origPath=$file.FullName
	
	$fileName=$file.FullName.Replace($SitecoreHotFixTraversePath,$SitePhysicalRootSitecore)
	
	
	if (test-path $fileName) {
		
		Write-Host "Removing "$fileName
		
		remove-item $fileName -force		
	}
	
	#Replace hotfix path with wdp path
	$WebSiteWdpPath=$origPath.Replace($SitecoreHotFixTraversePath,$SourcePath)
	
	#check if the wdp path exists
	if (test-path $WebSiteWdpPath) {
		
		Write-Host "WDP Path "$WebSiteWdpPath
		
		#if exists, copy over to webroot path
		$WebSiteRootPath=$WebSiteWdpPath.Replace($SourcePath,$SitePhysicalRootSitecore)
		
		Write-Host "Copy over Path "$WebSiteRootPath
		
		copy-item $WebSiteWdpPath -Destination  $WebSiteRootPath  -force		
	}
	
}


#####################################################Sitecore webroot wdp package unzip and processing - end

#####################################################Sitecore id wdp package unzip and processing - start

$SitecoreIdSrvrHotFixTraversePath=$SitecoreIdentityServerPackageUnzipDir + "\content\website"

Write-Host "Hotfix Id start path "$SitecoreIdSrvrHotFixTraversePath

$idfiles = get-childitem -Path $SitecoreIdSrvrHotFixTraversePath -recurse -Force -File

Write-host "Starting id srvr revert Operation at " + $SitePhysicalRootIdSrvr

foreach ($file in $idfiles)
{
	$OrigidPath=$file.FullName
	
	$IdFileName=$file.FullName.Replace($SitecoreIdSrvrHotFixTraversePath,$SitePhysicalRootIdSrvr)
	
	
	if (test-path $IdFileName) {
		
		Write-Host "Removing "$IdFileName
		
		remove-item $IdFileName -force		
	}
	
	#Replace hotfix id path with wdp id path
	$IdWdpPath=$OrigidPath.Replace($SitecoreIdSrvrHotFixTraversePath,$IdSourcePath)
	
	#check if the id wdp path exists
	if (test-path $IdWdpPath) {
		
		Write-Host "ID WDP Path "$IdWdpPath
		
		#if exists, copy over to webroot path
		$IdWebSiteRootPath=$IdWdpPath.Replace($IdSourcePath,$SitePhysicalRootIdSrvr)
		
		Write-Host "Copy over ID Path "$IdWebSiteRootPath
		
		copy-item $IdWdpPath -Destination  $IdWebSiteRootPath  -force		
	}
	
}

#####################################################Sitecore id wdp package unzip and processing - end

#####################################################Sitecore id wdp package unzip and processing - start

$SitecorexConnHotFixTraversePath=$SitecorexConnectServerPackageUnzipDir + "\content\website"

Write-Host "Hotfix xConn start path "$SitecorexConnHotFixTraversePath

$xConnfiles = get-childitem -Path $SitecorexConnHotFixTraversePath -recurse -Force -File
 
Write-host "Starting xConn srvr revert Operation at " + $SitePhysicalRootxConnSrvr

foreach ($file in $xConnfiles)
{
	$OrigxConnPath=$file.FullName
		
	$xConnFileName=$file.FullName.Replace($SitecorexConnHotFixTraversePath,$SitePhysicalRootxConnSrvr)
	
	Write-Host "xconn file name path" $xConnFileName
	
	if (test-path $xConnFileName) {
		
		Write-Host "Removing "$xConnFileName
		
		remove-item $xConnFileName -force		
	}
	
	#Replace hotfix xConn path with wdp xConn path
	$xConnWdpPath=$OrigxConnPath.Replace($SitecorexConnHotFixTraversePath,$xConnSourcePath)
	
	#check if the xConn wdp path exists
	if (test-path $xConnWdpPath) {
		
		Write-Host "xConnect WDP Path "$xConnWdpPath
		
		#if exists, copy over to xconn webroot path
		$xConnWebSiteRootPath=$xConnWdpPath.Replace($xConnSourcePath,$SitePhysicalRootxConnSrvr)
				
		Write-Host "xConnect Copy over Path "$xConnWebSiteRootPath
		
		copy-item $xConnWdpPath -Destination  $xConnWebSiteRootPath  -force		
	}
	
}

#####################################################Sitecore id wdp package unzip and processing - end


Write-Host "Process Complete!" 
