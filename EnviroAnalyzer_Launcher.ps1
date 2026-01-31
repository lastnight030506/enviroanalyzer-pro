Add-Type -AssemblyName System.Windows.Forms

# Find R installation
function Find-R {
    $paths = @(
        "C:\Program Files\R\R-4.5.2\bin\Rscript.exe",
        "C:\Program Files\R\R-4.5.1\bin\Rscript.exe",
        "C:\Program Files\R\R-4.5.0\bin\Rscript.exe",
        "C:\Program Files\R\R-4.4.2\bin\Rscript.exe",
        "C:\Program Files\R\R-4.4.1\bin\Rscript.exe",
        "C:\Program Files\R\R-4.4.0\bin\Rscript.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    # Try registry
    try {
        $regPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\R-core\R" -ErrorAction SilentlyContinue).InstallPath
        if ($regPath) {
            $rPath = Join-Path $regPath "bin\Rscript.exe"
            if (Test-Path $rPath) { return $rPath }
        }
    } catch {}
    
    return $null
}

# Get script directory
$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find R
$rPath = Find-R
if (-not $rPath) {
    [System.Windows.Forms.MessageBox]::Show(
        "R is not installed!`n`nPlease download and install R from:`nhttps://cran.r-project.org/bin/windows/base/",
        "EnviroAnalyzer Pro",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Start-Process "https://cran.r-project.org/bin/windows/base/"
    exit 1
}

# Change to app directory
Set-Location $appDir

# Launch app
$command = "shiny::runApp('app.R', port = 3838, host = '127.0.0.1', launch.browser = TRUE)"
Start-Process -FilePath $rPath -ArgumentList "-e", "`"$command`"" -WindowStyle Normal
