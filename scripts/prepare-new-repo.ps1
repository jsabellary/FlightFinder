# Creates a new repo folder with only Server, Shared, and React projects
param(
  [string]$DestinationName = "FlightFinderReact"
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$dest = Join-Path $root $DestinationName

if (Test-Path $dest) {
  Write-Host "Destination already exists: $dest" -ForegroundColor Yellow
} else {
  New-Item -ItemType Directory -Path $dest | Out-Null
}

# Copy projects
Copy-Item -Recurse -Force (Join-Path $root 'FlightFinder.Server') (Join-Path $dest 'FlightFinder.Server')
Copy-Item -Recurse -Force (Join-Path $root 'FlightFinder.Shared') (Join-Path $dest 'FlightFinder.Shared')
Copy-Item -Recurse -Force (Join-Path $root 'FlightFinder.React') (Join-Path $dest 'FlightFinder.React')

# Copy README if present
if (Test-Path (Join-Path $root 'README.md')) {
  Copy-Item -Force (Join-Path $root 'README.md') (Join-Path $dest 'README.md')
}

# Create .gitignore if not exists
$ignorePath = Join-Path $dest '.gitignore'
if (-not (Test-Path $ignorePath)) {
@"
# .NET
**/bin/
**/obj/
.vs/

# Node / Vite
**/node_modules/
**/dist/

# Logs
*.log

# Env
.env
.env.*
"@ | Set-Content -Encoding UTF8 $ignorePath
}

Push-Location $dest

if (-not (Test-Path (Join-Path $dest '.git'))) {
  git init -b main | Out-Null
}

git add .
if (-not (git diff --cached --quiet 2>$null)) {
  git commit -m "Initial import: Server + Shared + React" | Out-Null
}

Write-Host "Prepared repo at: $dest" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1) Create GitHub repo named '$DestinationName' (empty repo, no README)" -ForegroundColor Cyan
Write-Host "  2) Run: git remote add origin https://github.com/<your-username>/$DestinationName.git" -ForegroundColor Cyan
Write-Host "  3) Run: git push -u origin main" -ForegroundColor Cyan

Pop-Location
