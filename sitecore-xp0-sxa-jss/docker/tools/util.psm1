function Get-EnvVar {
  param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] 
    $Key
  )

  select-string -Path ".env" -Pattern "^$Key=(.+)$" | % { $_.Matches.Groups[1].Value }
}


function Read-UserEnvFile {
  param(
    [Parameter()]
    [string] $EnvFile = ".env.user"
  )

  if (Test-Path $EnvFile) {
      Write-Host "User specific .env file found. Starting Docker with custom user settings." -ForegroundColor Green
      Write-Host "Variable overrides:-" -ForegroundColor Yellow
      
      Get-Content $EnvFile | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } | ForEach-Object {
          $var, $val = $_.trim().Split('=')
          Write-Host "  $var=$val" -ForegroundColor Yellow
          Set-Item -Path "env:$($var)" -Value $val
      }
  }
}


function Wait-SiteResponsive {
  param(
    [Parameter()]
    [string] $EndpointUrl = "http://localhost:8079/api/http/routers/cm-secure@docker"
  )

  Write-Host "Waiting for CM to become available...`n`n" -ForegroundColor Green
  $startTime = Get-Date
  $i = 0
  $cursorSave  = (Get-Host).UI.RawUI.cursorsize
  $colors = "Red", "Yellow","Green", "Cyan", "Blue", "Magenta"

  do {
      try {
          $status = Invoke-RestMethod $EndpointUrl
      } catch {
          if ($_.Exception.Response.StatusCode.value__ -ne "404") {
              throw
          }
      }

      # Credit: https://www.reddit.com/r/PowerShell/comments/i1bnfw/a_stupid_little_animation_script/
      "`t(>'-')>", "`t^('-')^", "`t<('-'<)", "`t^('-')^" | % { 
          Write-Host "`r$($_)" -NoNewline -ForegroundColor $colors[$i % 6]
          Start-Sleep -Milliseconds 250
      }
      $i++
  } while ($status.status -ne "enabled" -and $startTime.AddSeconds(30) -gt (Get-Date))

  (Get-Host).UI.RawUI.cursorsize = $cursorSave

  if (-not $status.status -eq "enabled") {
      $status
      Write-Error "Timeout waiting for Sitecore CM to become available via Traefik proxy. Check CM container logs."
  }
}


Export-ModuleMember -Function *
