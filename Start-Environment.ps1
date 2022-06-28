#Requires -RunAsAdministrator
param (
    [ValidateNotNullOrEmpty()]
    [string] 
    $ComposeProjectName="sc-mvp",
    [ValidateNotNullOrEmpty()]
    [string] 
    $LicensePath = "c:\sitecore\license.xml",
    [switch]
    $InitializeEnvFile,
    [Switch]
    $Pull,
    [Switch]
    $Clean,
    [Switch]
    $StartMvpSite,
    [Switch]
    $StartSugconSites
)

Import-Module -Name (Join-Path $PSScriptRoot "docker\tools\Init-Env") -Force

Show-Logo

if (!(Test-Path ".\docker\license\license.xml")) {
    Write-Host "License.xml not found in .\docker\license\" -ForegroundColor Yellow
    
    if (!(Test-Path $LicensePath)) {
        Write-Host "Please copy a valid Sitecore license file to .\docker\license\ or supply a path to license file using the -LicensePath arg.." -ForegroundColor Red
        exit 0
    }
    
    Write-Host "Copying $($LicensePath) to .\docker\license\" -ForegroundColor Green
    Copy-Item $LicensePath ".\docker\license\license.xml"
}

Stop-IisIfRunning

$HostDomain = "$($ComposeProjectName.ToLower()).localhost"

if (!(Test-Path ".\.env") -or $InitializeEnvFile) { 
    Initialize-EnvFile -HostDomain $HostDomain -ComposeProjectName $ComposeProjectName

    # Rendering site hostnames..
    Set-EnvFileVariable "MVP_RENDERING_HOST" -Value "mvp.$($HostDomain)"
    Set-EnvFileVariable "SUGCON_EU_RENDERING_HOST" -Value "sugcon-eu.$($HostDomain)"
    Set-EnvFileVariable "SUGCON_ANZ_RENDERING_HOST" -Value "sugcon-anz.$($HostDomain)"

    # OKTA Dev stuff...
    Set-EnvFileVariable "OKTA_DOMAIN" -Value (Read-ValueFromHost -Question "OKTA Domain (has to start with https://)" -ValidationRegEx "https://.{8,}" -Required )
    Set-EnvFileVariable "OKTA_CLIENT_ID" -Value (Read-ValueFromHost -Question "OKTA Client ID" -Required)
    Set-EnvFileVariable "OKTA_CLIENT_SECRET" -Value (Read-ValueFromHost -Question "OKTA Client Secret" -Required)
}

Install-SitecoreDockerTools

if (!(Test-Path ".\docker\traefik\certs\cert.pem")) {
    Write-Host "TLS certificate for Traefik not found, generating and adding hosts file entries" -ForegroundColor Green 

}

$HostDomain = Get-EnvValueByKey "HOST_DOMAIN" 
if ($HostDomain -eq "") {
    throw "Required variable 'HOST_DOMAIN' not found in .env file."
}  

Initialize-HostNames $HostDomain

# Rendering site hostnames..
$mvpSite=Check-HostNameExists "mvp.$($HostDomain)"
$sugconeuSite=Check-HostNameExists "sugcon-eu.$($HostDomain)"
$sugconanzSite=Check-HostNameExists "sugcon-anz.$($HostDomain)"
if ($mvpSite -eq $false) {Add-HostsEntry "mvp.$($HostDomain)"}
if ($sugconeuSite -eq $false) {Add-HostsEntry "sugcon-eu.$($HostDomain)"}
if ($sugconanzSite -eq $false) {Add-HostsEntry "sugcon-anz.$($HostDomain)"}


if ($Pull) {
    Write-Host "Pulling the latest Sitecore base images.." -ForegroundColor Magenta
    docker images --format "{{.Repository}}:{{.Tag}}" | Select-String -Pattern "scr.sitecore.com/" | % { docker image pull $($_) }
}

if ($Clean) {
    Write-Host "Cleaning content in deploy and data folders.." -ForegroundColor Magenta
    ./docker/clean.ps1
}

$composeFiles = @(".\docker-compose.yml", ".\docker-compose.override.yml")

$startAll = !$StartMvpSite -and !$StartSugconSites

if ($startAll -or $StartMvpSite) {
    $composeFiles += ".\docker-compose.mvp.yml"
} 

if ($startAll -or $StartSugconSites) {
    $composeFiles += ".\docker-compose.sugcon.yml"
}


if ([Environment]::Is64BitProcess -eq [Environment]::Is64BitOperatingSystem)
{
	$programFilesPath=${env:ProgramFiles}
}else
{
	$programFilesPath=${env:ProgramFiles(x86)}
}

$dotnetFolder= "$programFilesPath\dotnet";
$dotnetexe="$dotnetFolder\dotnet.exe";
$sdk="$dotnetFolder\sdk";

if (!(Test-Path "$dotnetexe") -or !(Test-Path "$sdk")) {
	Write-Host "Install dotnet Core 3.1 runtime and sdk from https://dotnet.microsoft.com/en-us/download" -ForegroundColor Yellow
	exit 0
}

$result=Get-ChildItem  "$sdk" -filter "3.1.*" -Directory | % { $_.fullname }
if (!$result) {
	Write-Host "Install dotnet core SDK from https://dotnet.microsoft.com/en-us/download" -ForegroundColor Yellow
	exit 0
}

# Restore dotnet tool for sitecore login and serialization
dotnet tool restore

$dockerFolder= "$programFilesPath\docker\docker";
#just for safety, checking for one of the exe in the folder
$dockerApp="$programFilesPath\docker\docker\Docker Desktop.exe";

if (!(Test-Path "$dockerFolder")-or !(Test-Path "$dockerApp")) {
	Write-Host "Restart execution after installing Docker Desktop for Windows from https://docs.docker.com/desktop/windows/install/" -ForegroundColor Yellow
	exit 0
}

Start-Docker -Build -ComposeFiles $composeFiles

Push-Items -IdHost "https://id.$($HostDomain)" -CmHost "https://cm.$($HostDomain)"

#TODO: this will be generalized when more sugcon sites are added.
if ($startAll -or $StartMvpSite) {
    Write-Host "`nMVP site is accessible on https://mvp.$HostDomain/`n`nUse the following command to monitor:"  -ForegroundColor Magenta
    Write-PrePrompt
    Write-Host "docker logs -f mvp-rendering`n"
} 

if ($startAll -or $StartSugconSites) {
    Write-Host "`nSUGCON EU site is accessible on https://sugcon-eu.$HostDomain/`n`nUse the following command to monitor:"  -ForegroundColor Magenta
    Write-PrePrompt
    Write-Host "docker logs -f sugcon-eu-rendering`n"
} 

Write-Host "Opening cm in browser..." -ForegroundColor Green
Start-Process https://cm.$HostDomain/sitecore/
