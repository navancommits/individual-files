param(
	
	[Parameter(Mandatory = $true)]

    [string]

    [ValidateNotNullOrEmpty()]

	$SitePrefix = "sc103instance",  	
		

	[Parameter(Mandatory = $false)]
	
	[ValidateNotNullOrEmpty()]
	
	[string]$InstallSourcePath = (Join-Path $PSScriptRoot "."),
		

	# Root folder where the site is installd. If left on the default [systemdrive]:\inetpub\wwwroot will be used

    [string]

    $SitePhysicalRoot = "c:\inetpub\wwwroot\" ,
	

	# Site suffix matches what is used by SIA

    [string]

    $SiteSuffix = ".dev.local" ,
	
	# Site suffix matches what is used by SIA

    [string]

    $SitecoreVersion = "9.3" 

)

$watch = [System.Diagnostics.Stopwatch]::StartNew()

$watch.Start() # Timer start

$SitePhysicalRootSitecore = $SitePhysicalRoot  + $SitePrefix.Trim() + "sc" + $SiteSuffix

$SitePhysicalRootxConnSrvr=$SitePhysicalRoot  + $SitePrefix.Trim() + "xconnect" + $SiteSuffix

$SitePhysicalRootIdSrvr=$SitePhysicalRoot  + $SitePrefix.Trim() + "identityserver" + $SiteSuffix

Write-Host "Site root" $SitePhysicalRootSitecore

Write-Host "Id root" $SitePhysicalRootIdSrvr

Switch ($SitecoreVersion)
{
    "10.3.0" {
		
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/8F77892C62CB4DC698CB7688E5B6E0D7.ashx?date=20221130T160548"
		break
	}
	"10.2.0" {
		
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/F6813A6E3E424AB99A6E9A7CC257648B.ashx?date=20211101T105423"
		break
	}
	"10.1.0" {
		
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/A76121649BE84CAD8DECAD641D307C32.ashx"
		break
	}
	"10.0.0" {
		
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/A74E47524738460B83332BAE82F123D1.ashx"
		break
	}
    "10.0.1" {
		
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/F348FF71C86D4F7096C2B929E0DA2F49.ashx?date=20201211T131403"
		break
	}
	"9.3" {
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/A1BC9FD8B20841959EF5275A3C97A8F9.ashx"
		break
	}
	"9.2" {
		$SdnUrl="https://sitecoredev.azureedge.net/~/media/1C1D7C4CBC934A6AA36825974A18A72E.ashx"
		break
	}
}

if (-not(Test-Path .\$SitecoreVersion\xp0 -PathType Container)) {

	$preference = $ProgressPreference
	$ProgressPreference = "SilentlyContinue"


	$sitecoreDownloadUrl = "https://sitecoredev.azureedge.net"
	$packages = @{
		"Sitecore Setup XP0 Developer Workstation.zip" = $SdnUrl
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
	

	Expand-Archive -Force -Path 'Sitecore * XP0 Developer Workstation.zip' -DestinationPath .\$SitecoreVersion\xp0
	remove-item -Force -Path 'Sitecore * XP0 Developer Workstation.zip'


	$ProgressPreference = $preference

	Write-Host "Unzipped Sitecore Zip"
}



################################Unzip Sitecore wdp file - start

$SitecoreWebSiteZipPath = $InstallSourcePath + "\" +  $SitecoreVersion + "\xp0\Sitecore * rev. * (OnPrem)_single.scwdp.zip"

Write-Host "Sitecore Wdp zip file whole path "$SitecoreWebSiteZipPath	


$SitecoreWdpFileLocation=Split-Path $SitecoreWebSiteZipPath -Parent

Write-Host "Sitecore Wdp file unzip path " $SitecoreWdpFileLocation

Write-Host "Sitecore Wdp file whole path" $SitecoreWdpFileLocation"\SitecoreWdp"

if (-not(Test-Path $SitecoreWdpFileLocation"\SitecoreWdp")) {


	Expand-Archive -Path $SitecoreWebSiteZipPath  -DestinationPath $SitecoreWdpFileLocation"\SitecoreWdp" -Force

}

$SourcePath=$SitecoreWdpFileLocation + "\SitecoreWdp\Content\Website" 

Write-host "Source path " $SourcePath
	

################################Unzip Sitecore wdp file - end

################################Unzip Sitecore ID wdp file - start

$SitecoreIDWebSiteZipPath = $InstallSourcePath + "\" +  $SitecoreVersion + "\xp0\Sitecore.IdentityServer * rev. * (OnPrem)_identityserver.scwdp.zip"


Write-Host "Sitecore Wdp ID zip file whole path "$SitecoreIDWebSiteZipPath


$SitecoreIDWdpFileLocation=Split-Path $SitecoreIDWebSiteZipPath -Parent


Write-Host "Sitecore Wdp ID file whole path" $SitecoreIDWdpFileLocation"\SitecoreIdWdp"

if (-not(Test-Path $SitecoreIDWdpFileLocation"\SitecoreIdWdp")) {

	Expand-Archive -Path $SitecoreIDWebSiteZipPath  -DestinationPath $SitecoreIDWdpFileLocation"\SitecoreIdWdp" -Force

}

$IdSourcePath=$SitecoreIDWdpFileLocation + "\SitecoreIdWdp\Content\Website" 

Write-host "Id Source path " $IdSourcePath



################################Unzip Sitecore ID wdp file - end


################################Unzip Sitecore xconnect wdp file - start

$SitecorexConnWebSiteZipPath = $InstallSourcePath + "\" +  $SitecoreVersion + "\xp0\Sitecore * rev. * (OnPrem)_xp0xconnect.scwdp.zip"


Write-Host "Sitecore Wdp xConnect zip file whole path "$SitecorexConnWebSiteZipPath


$SitecorexConnWdpFileLocation=Split-Path $SitecorexConnWebSiteZipPath -Parent


Write-Host "Sitecore Wdp xConnect file whole path" $SitecorexConnWdpFileLocation"\SitecorexConnWdp"

if (-not(Test-Path $SitecorexConnWdpFileLocation"\SitecorexConnWdp")) {

	Expand-Archive -Path $SitecorexConnWebSiteZipPath  -DestinationPath $SitecorexConnWdpFileLocation"\SitecorexConnWdp" -Force

}

$xConnSourcePath=$SitecorexConnWdpFileLocation + "\SitecorexConnWdp\Content\Website" 

Write-host "xConn Source path " $xConnSourcePath



################################Unzip Sitecore xconnect wdp file - end


#####################################################Sitecore webroot wdp package unzip and processing - start


$SourcePath=Get-Item -Path $SourcePath

Write-Host "Wdp start path "$SourcePath


$files = get-childitem -Path $SourcePath -recurse -Force

Write-host "Scanning for repair Operation at " $SitePhysicalRootSitecore

$WebSiteFixed=$false


foreach ($file in $files)
{
	$origPath=$file.FullName		

	$WebSiteCopyToLocation=$origPath.Replace($SourcePath,$SitePhysicalRootSitecore)
	
	if (-not(Test-Path $WebSiteCopyToLocation)) {
				
		Write-Host -Foregroundcolor blue "Change detected!!! Copy from Path "$origPath
		
		Write-Host -Foregroundcolor blue "Copy to Path "$WebSiteCopyToLocation
			
		copy-item $origPath -Destination  (Split-Path $WebSiteCopyToLocation -Parent)  -force 
		
		$WebSiteFixed=$true
	
	}
	
}


#####################################################Sitecore webroot wdp package unzip and processing - end

#####################################################Sitecore id wdp package unzip and processing - start


$IdSourcePath=Get-Item -Path $IdSourcePath

Write-Host "Wdp start path "$IdSourcePath

$idfiles = get-childitem -Path $IdSourcePath -recurse -Force

Write-host "Scanning id srvr for repair Operation at " $SitePhysicalRootIdSrvr

foreach ($file in $idfiles)
{
	$OrigidPath=$file.FullName	
	
	$WebSiteIdCopyToLocation=$origPath.Replace($IdSourcePath,$SitePhysicalRootIdSrvr)
			
	if (-not(Test-Path $WebSiteIdCopyToLocation)) {
		
		Write-Host -Foregroundcolor blue "Change detected!!! Copy from id Path "$OrigidPath
		
		Write-Host -Foregroundcolor blue "Copy to id Path "$WebSiteIdCopyToLocation
			
		copy-item $OrigidPath -Destination  (Split-Path $WebSiteIdCopyToLocation -Parent)  -force 	
		
		$WebSiteFixed=$true
	
	}
	
}

#####################################################Sitecore id wdp package unzip and processing - end

#####################################################Sitecore id wdp package unzip and processing - start

$xConnSourcePath=Get-Item -Path $xConnSourcePath

Write-Host "Wdp start path "$xConnSourcePath

$xConnfiles = get-childitem -Path $xConnSourcePath -recurse -Force 
 
Write-host "Scanning xConn srvr for repair Operation at " + $SitePhysicalRootxConnSrvr

foreach ($file in $xConnfiles)
{
	$OrigxConnPath=$file.FullName
	
	$WebSitexConnCopyToLocation=$origPath.Replace($xConnSourcePath,$SitePhysicalRootxConnSrvr)
	
	if (-not(Test-Path $WebSitexConnCopyToLocation)) {
				
		Write-Host -Foregroundcolor blue "Change detected!!! Copy from xConn Path "$OrigxConnPath
		
		Write-Host -Foregroundcolor blue "Copy to xConn Path "$WebSitexConnCopyToLocation		
		
		copy-item $OrigxConnPath -Destination  (Split-Path $WebSitexConnCopyToLocation -Parent)  -force		
		
		$WebSiteFixed=$true
	
	}
	
}

#####################################################Sitecore id wdp package unzip and processing - end

if (-not($WebSiteFixed)) {Write-Host -Foregroundcolor green "Nothing to fix... WebSite looks good!!!"}

Write-Host "Process Complete!" 


$watch.Stop() # Stopping the timer

Write-Host "Execution time in seconds " $watch.Elapsed # Print script execution time

