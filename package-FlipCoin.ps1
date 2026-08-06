# package-FlipCoin.ps1
# Run on Windows x64 with a JDK that includes jpackage (JDK 25 recommended).
# Edit $JDK if your JDK is installed somewhere else.

$JDK = "F:\Java_JDK_25"
$InputDir = "W:\JavaProjects\FlipCoin\out\artifacts\FlipCoin_jar"
$MainJar = "FlipCoin.jar"
$MainClass = "Main"          # fully-qualified main class; change if your class has a package
$AppName = "FlipCoin"
$OutDir = "W:\JavaProjects\FlipCoin\dist"
$Icon = ""                   # optional: "W:\path\to\icon.ico"

if (!(Test-Path $JDK)) {
  Write-Error "JDK not found at $JDK. Install a JDK (25+) and update \$JDK path."
  exit 1
}

if (!(Test-Path "$JDK\bin\jpackage.exe")) {
  Write-Error "jpackage.exe not found in $JDK\bin. Ensure you have a JDK with jpackage (Adoptium/Oracle/OpenJDK 25+)."
  exit 1
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Quick test: verify the jar runs with your JDK
Write-Host "Testing jar execution..."
& "$JDK\bin\java.exe" -jar (Join-Path $InputDir $MainJar)
if ($LASTEXITCODE -ne 0) {
  Write-Warning "Jar did not run successfully with $JDK\bin\java.exe. Fix jar / main class before packaging."
}

###########
# A) Simple jpackage (bundles a runtime automatically)
###########
Write-Host "Running jpackage (simple)..."
$pkgArgs = @(
  "--type", "exe",
  "--name", $AppName,
  "--input", $InputDir,
  "--main-jar", $MainJar,
  "--main-class", $MainClass,
  "--win-console",
  "--app-version", "1.0.0",
  "--dest", $OutDir
)
if ($Icon -ne "") { $pkgArgs += ("--icon", $Icon) }

& "$JDK\bin\jpackage.exe" @pkgArgs
if ($LASTEXITCODE -eq 0) {
  Write-Host "Simple packaging complete. Output in $OutDir"
} else {
  Write-Warning "jpackage (simple) failed. See output above."
}

###########
# B) jlink (create smaller runtime) + jpackage
###########
Write-Host "Creating smaller runtime image with jlink..."
$RuntimeImage = (Join-Path $OutDir "runtime-image")
$JMODS = (Join-Path $JDK "jmods")

& "$JDK\bin\jlink.exe" `
  --module-path $JMODS `
  --add-modules java.base `
  --output $RuntimeImage `
  --strip-debug --compress=2 --no-header-files --no-man-pages

if ($LASTEXITCODE -ne 0) {
  Write-Warning "jlink failed; skipping jlink-based packaging."
  exit 0
}

Write-Host "Packaging with jpackage using runtime image..."
$pkgArgs2 = @(
  "--type", "exe",
  "--name", $AppName,
  "--input", $InputDir,
  "--main-jar", $MainJar,
  "--main-class", $MainClass,
  "--runtime-image", $RuntimeImage,
  "--win-console",
  "--app-version", "1.0.0",
  "--dest", $OutDir
)
if ($Icon -ne "") { $pkgArgs2 += ("--icon", $Icon) }

& "$JDK\bin\jpackage.exe" @pkgArgs2
if ($LASTEXITCODE -eq 0) {
  Write-Host "jlink + jpackage packaging complete. Output in $OutDir"
} else {
  Write-Warning "jpackage (with runtime image) failed. See output above."
}