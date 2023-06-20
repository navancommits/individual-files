##############################################

[CmdletBinding()]

Param ( 



	[Parameter(Mandatory = $true)]

    [string]

    [ValidateNotNullOrEmpty()]

	$SitePrefix = "sc103instance",  	

		

	# The root folder with the WDP files.

    [string]    

    $SCInstallRoot = ".",

	

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



$ErrorActionPreference = "Stop";

$SitecoreSiteName =$SitePrefix.Trim() + "sc" + $SiteSuffix

$XConnectSiteName=$SitePrefix.Trim() + "xconnect" + $SiteSuffix

$IdentityServerSiteName=$SitePrefix.Trim() + "identityserver" + $SiteSuffix



Write-Host "Unzipping the main file - " + (Get-Item "$SCInstallRoot\*.zip").FullName

# Unzip the copied over zip

Expand-Archive -Path "*.zip"  -Force





if ($PatchType -eq 'cumulative')

{

	# The path to the Sitecore cumulative Package to Deploy.	

	$SitecorePackageZipPath = "$SCInstallRoot\*\Sitecore * rev. * (OnPrem)_single.cumulative.delta.scwdp.zip"

	# The path to the Identity Server cumulative Package to Deploy.

	$IdentityServerPackageZipPath = "$SCInstallRoot\*\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.cumulative.delta.scwdp.zip"

	# The path to the xConnect Server cumulative Package to Deploy.

	$XConnectPackageZipPath = "$SCInstallRoot\*\Sitecore * rev. * (OnPrem)_xp0xconnect.cumulative.delta.scwdp.zip"

}

else

{

	# The path to the Sitecore Package to Deploy.

	$SitecorePackageZipPath = "$SCInstallRoot\*\Sitecore * rev. * (OnPrem)_single.delta.scwdp.zip"

	# The path to the Identity Server Package to Deploy.

	$IdentityServerPackageZipPath = "$SCInstallRoot\*\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.delta.scwdp.zip"

	# The path to the xConnect Server Package to Deploy.

	$XConnectPackageZipPath = "$SCInstallRoot\*\Sitecore * rev. * (OnPrem)_xp0xconnect.delta.scwdp.zip"

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



Write-Host "Unzipping the Sitecore Package file to - " + $SitecorePackageUnzipDir 

Expand-Archive -Path $SitecorePackagePath -Destination $SitecorePackageUnzipDir  -Force

Write-Host "Unzipping the Identity Package file to - " + $SitecoreIdentityServerPackageUnzipDir 

Expand-Archive -Path $IdentityServerPackagePath -Destination $SitecoreIdentityServerPackageUnzipDir  -Force

Write-Host "Unzipping the xConnect Package file to - " + $SitecorexConnectServerPackageUnzipDir

Expand-Archive -Path $XConnectPackagePath -Destination $SitecorexConnectServerPackageUnzipDir  -Force



$SitecorePackageSource = "$SitecorePackageUnzipDir\Content\Website\*"

$SitecorePackageDest = $SitePhysicalRoot + $SitecoreSiteName + '\'



Write-Host "Copying the Sitecore Package file to - " + $SitecorePackageDest

Copy-Item $SitecorePackageSource -Destination $SitecorePackageDest -Force -Recurse



$SitecoreIdPackageSource = "$SitecoreIdentityServerPackageUnzipDir\Content\Website\*"

$SitecoreIdPackageDest = $SitePhysicalRoot + $IdentityServerSiteName + "\"



Write-Host "Copying the Id Package file to - $SitecoreIdPackageDest"

Copy-Item $SitecoreIdPackageSource -Destination $SitecoreIdPackageDest -Force -Recurse





$SitecorexConnectPackageSource = "$SitecorexConnectServerPackageUnzipDir\Content\Website\*"

$SitecorexConnectPackageDest = $SitePhysicalRoot + $XConnectSiteName + '\'



Write-Host "Copying the xConnect Package file to - $SitecorexConnectPackageDest"

Copy-Item $SitecorexConnectPackageSource -Destination $SitecorexConnectPackageDest -Force -Recurse



Write-Host "Process Completed!"



##############################################
