# PowerShell script to replicate AASMI OS build steps using Windows-compatible tools

# Log file path
$logFile = "windows-build.log"

# Function to log messages
function Log-Message {
    param([string]$message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "$timestamp - $message"
    Write-Output $entry
    Add-Content -Path $logFile -Value $entry
}

# Start logging
Log-Message "Starting Windows-native AASMI OS build process."

# Step 1: Clone the project repository (assuming Git is installed)
$repoUrl = "https://github.com/yourusername/aasmi-os.git"  # Replace with actual repo URL
$clonePath = "D:\Visual Stuido Porjects\AASMI"

if (-Not (Test-Path $clonePath)) {
    Log-Message "Cloning repository from $repoUrl to $clonePath"
    git clone $repoUrl $clonePath
} else {
    Log-Message "Repository already cloned at $clonePath"
}

# Step 2: Install required Windows tools
# Note: Windows does not have native live-build, so alternative tools or scripts are needed.
# This script assumes you have installed tools like:
# - 7zip for archive handling
# - Rufus CLI for USB flashing
# - Any other required utilities

# Step 3: Prepare build environment
# Copy necessary files, themes, wallpapers, and scripts to a build directory
$buildDir = "$clonePath\build"
if (-Not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
    Log-Message "Created build directory at $buildDir"
} else {
    Log-Message "Build directory exists at $buildDir"
}

# Copy files (example)
Copy-Item -Path "$clonePath\ui-ux" -Destination $buildDir -Recurse -Force
Copy-Item -Path "$clonePath\build-scripts" -Destination $buildDir -Recurse -Force

# Step 4: Build ISO using Windows tools
# Since live-build is not available, you may use tools like oscdimg (Windows ADK) or mkisofs (from Cygwin)
# Example using oscdimg (must be installed and in PATH)
$isoOutput = "$buildDir\AASMI_OS.iso"
$sourceDir = "$buildDir\live-filesystem"  # This directory should contain the prepared live filesystem

if (-Not (Test-Path $sourceDir)) {
    Log-Message "Source directory for ISO build not found: $sourceDir"
    throw "Source directory for ISO build not found."
}

Log-Message "Building ISO image at $isoOutput"
$oscdimgPath = "oscdimg"  # Ensure oscdimg is in PATH or provide full path

$oscdimgArgs = @(
    "-m",               # Ignore max size limit
    "-o",               # Optimize storage by encoding duplicate files only once
    "-u2",              # UDF file system version 2.01
    "-udfver102",       # UDF version 1.02
    "-bootdata:2#p0,e,b$buildDir\boot\etfsboot.com#pEF,e,b$buildDir\efi\microsoft\boot\efisys.bin", # Boot sector files
    $sourceDir,
    $isoOutput
)

try {
    Start-Process -FilePath $oscdimgPath -ArgumentList $oscdimgArgs -Wait -NoNewWindow
    Log-Message "ISO image built successfully."
} catch {
    Log-Message "ISO build failed: $_"
    throw $_
}

# Step 5: Inform user to create bootable USB manually using tools like Rufus GUI or CLI

Log-Message "Build process completed. Please use Rufus or similar tool to create a bootable USB from the ISO."

# End of script
