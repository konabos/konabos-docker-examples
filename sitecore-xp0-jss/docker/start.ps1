Import-Module -Name (Join-Path $PSScriptRoot "..\logo")
Import-Module -Name (Join-Path $PSScriptRoot ".\tools\config")
Show-Start

#----------------------------------------------------------
## clean up
#----------------------------------------------------------

docker system prune -f

#----------------------------------------------------------
## load variables
#----------------------------------------------------------

$url = Get-EnvVar -Key CM_HOST

#----------------------------------------------------------
## check license is present
#----------------------------------------------------------

$licensePath = Get-EnvVar -Key LICENSE_PATH
if (-not (Test-Path (Join-Path $licensePath "license.xml"))) {
    throw "License file not present in folder."
}

#----------------------------------------------------------
## check traefik ssl certs present
#----------------------------------------------------------

if (-not (Test-Path .\traefik\certs\cert.pem)) {
    .\tools\mkcert.ps1 -FullHostName ($url -replace "^.+?(\.)", "")
}

#----------------------------------------------------------
## check if user override env file exists and start docker
#----------------------------------------------------------

Read-UserEnvFile

#----------------------------------------------------------
## start
#----------------------------------------------------------

docker-compose up -d
start "https://$url"
