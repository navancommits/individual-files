Set-StrictMode -Version Latest
function Start-Docker {
    param(
        [ValidateNotNullOrEmpty()]
        [string] 
        $DockerRoot = ".\",
        [Switch]
        $Build,
        [string]
        $MemoryLimit = "8GB",
        [String[]]
        $ComposeFiles = @(".\docker-compose.yml", ".\docker-compose.override.yml")
    )
try
{

    $fileArgs =  ($ComposeFiles | %{ "-f" + "$_" })
    if ($Build) {
       & "docker-compose" $fileArgs "build" "-m" "$MemoryLimit"
    }
    & "docker-compose" $fileArgs "up" "-d"
}
catch
{
	write-host "Issues with Docker, Maybe Docker Desktop is not started/logged-in or windows container not switched yet!"
	exit 0
}
}

function Stop-Docker {
    param(
        [Switch]$PruneSystem
    )
try
{
    if (Test-Path ".\docker-compose.yml") {
        docker-compose down --remove-orphans

        if ($PruneSystem) {
            docker system prune -f
        }
    }
    Pop-Location
}
catch
{
	write-host "Issues with Docker, Maybe Docker Desktop is not started/logged-in or windows container not switched yet!"
	exit 0
}

}