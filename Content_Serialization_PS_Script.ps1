#Requires -RunAsAdministrator
param (
	[ValidateNotNullOrEmpty()]
    [string] 
    $RepoName="https://github.com/navancommits/SerializationContent.git",  
	
    [ValidateNotNullOrEmpty()]
    [string] 
    $WorkingRootDirectory="C:\scs",   
	
	[ValidateNotNullOrEmpty()]
    [string] 
    $WorkingDirectory="\SerializationContent",   

	[ValidateNotNullOrEmpty()]
    [string] 
    $CheckoutBranch="main",
	
	[ValidateNotNullOrEmpty()]
    [string] 
    $FeatureBranch="newfeature",
	
	[ValidateNotNullOrEmpty()]
    [string] 
    $IdServerUrl="https://sc103tstijkidentityserver.dev.local",	
	
	[ValidateNotNullOrEmpty()]
    [string] 
    $CMServerUrl="https://sc103tstijksc.dev.local"
)

Set-Location $WorkingRootDirectory

$tstamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "" }

If ([System.Diagnostics.EventLog]::SourceExists('SCSScript') -eq $False) {

	New-EventLog -LogName Application -Source 'SCSScript'

}

$RepoDirectory = $WorkingRootDirectory + $WorkingDirectory

if (-not(Test-Path -Path $RepoDirectory))
{
	Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "Cloning repo $RepoName"
	#Write-Host "Cloning repo $RepoName"
	
	git clone $RepoName
	
	git fetch origin
	
	Write-Host "Restoring Sitecore CLI..." -ForegroundColor Green
	
	Set-Location $RepoDirectory
    
	dotnet tool restore
	
	dotnet new tool-manifest
	dotnet tool install Sitecore.CLI --add-source https://sitecore.myget.org/F/sc-packages/api/v3/index.json
	dotnet sitecore init
	
	dotnet nuget add source https://sitecore.myget.org/f/sc-packages -n sc-packages
	dotnet sitecore plugin add -n Sitecore.DevEx.Extensibility.Serialization
	dotnet sitecore login --authority $IdServerUrl --cm $CMServerUrl --allow-write true --client-credentials true --client-id "NonInteractiveClient" --client-secret "SUPERLONGSECRETHERE"  
	
	(Get-Content .\sitecore.json).replace('/TODO', '') | Set-Content .\sitecore.json
	Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "First time Interactive login setup complete!"
}

Set-Location $RepoDirectory

git pull

git checkout $CheckoutBranch

Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "Checkout $CheckoutBranch"

dotnet sitecore ser pull

Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "Pull latest changes from Sitecore instance "

$status=git status -s

if ($status -ne $null)
{
	
	$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "" }

	$FeatureBranch=$FeatureBranch + $timestamp

	#Write-Host "Checking out $FeatureBranch"
	Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "Checking out $FeatureBranch"

	git checkout -b $FeatureBranch
	
	#Write-Host "New files detected"
	Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "New files detected but will check-in only yml files"
	
	git add *.yml
	
	$timestamp = Get-Date -Format o | ForEach-Object { $_ -replace ":", "." }
	
	git commit -m "New Files found at $timestamp"

	git push --set-upstream origin $FeatureBranch		
}

#delete merged branches reference: https://blogs.blackmarble.co.uk/rfennell/tidying-up-local-branches-with-a-git-alias-and-a-powershell-script/

#Write-Host "Process complete!"
Write-EventLog -LogName Application -EventID 3000 -EntryType Information -Source 'SCSScript' -Message "Process complete!"