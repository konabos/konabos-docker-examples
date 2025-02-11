﻿Import-Module -Name (Join-Path $PSScriptRoot "..\logo")
Import-Module -Name (Join-Path $PSScriptRoot ".\tools\util")
Show-Start

#----------------------------------------------------------
## clean up
#----------------------------------------------------------

docker system prune -f

#----------------------------------------------------------
## load variables
#----------------------------------------------------------

$urls = @()
$cmUrl = Get-EnvVar -Key CM_HOST

$urls += $cmUrl
$altHosts = Get-EnvVar -Key ALT_HOST
$altHostsList = $altHosts.Replace('`', '').Split(',') | Foreach-Object { $urls += $_ }

#----------------------------------------------------------
## check license is present
#----------------------------------------------------------

$licensePath = Get-EnvVar -Key LICENSE_PATH
if (-not (Test-Path (Join-Path $licensePath "license.xml"))) {
    Write-Host "License file not present in folder." -ForegroundColor Red
    Break
}

#----------------------------------------------------------
## check traefik ssl certs present
#----------------------------------------------------------

if (-not (Test-Path .\traefik\certs\cert.pem)) {
    .\tools\mkcert.ps1 -FullHostName $urls
}

#----------------------------------------------------------
## check if user override env file exists
#----------------------------------------------------------

Read-UserEnvFile

#----------------------------------------------------------
## start docker
#----------------------------------------------------------

docker-compose up -d

Wait-SiteResponsive
Write-Host "`n`nDone... opening https://$($cmUrl)" -ForegroundColor DarkGray
start "https://$cmUrl"
