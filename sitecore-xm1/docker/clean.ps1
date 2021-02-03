param(
  [Parameter()]
  [switch]$IncludeDatabases
)

# Remove all unsused conrainers, networks, images, volumes
docker system prune -f

# Clean the data
if ($IncludeDatabases)
{
  Write-Host "Cleaning all data..." -ForegroundColor DarkRed -BackgroundColor Yellow
  git clean -xdf ./data
}
else 
{
  Write-Host "Cleaning data but not databases..." -ForegroundColor DarkRed -BackgroundColor Yellow
  git clean -xdf ./data -e *.mdf -e *.ldf
}
 