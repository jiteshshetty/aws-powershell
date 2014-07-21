#####
#
# Script 5
# 43 - Beyond AWS Basics: PowerShell + AWS Basics: Automating Web Application Deployments
#
#####

param(
    [string]$webpiProducts = "ASPNET45,WDeployPS,WDeployNoSMO,WDeploy",
    [string]$deployFileKey = "webdeploypackage.zip",
    [string]$deployFileBucket = "bucketName"
)	

Import-Module AWSPowerShell

function Run-Process([string]$processFileName, [string]$processArguments) {
    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $processFileName
    $pinfo.RedirectStandardError = $false
    $pinfo.RedirectStandardOutput = $false
    $pinfo.UseShellExecute = $true
    $pinfo.Arguments = $processArguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start()
    $p.WaitForExit()
    Write-Host "exit code: " + $p.ExitCode
}

$webPICmd = "C:\Program Files\Microsoft\Web Platform Installer\webpicmd.exe"
$downloadFolder = Join-Path $env:Temp "bootstrapInstall"

if(Test-Path $downloadFolder) {
    Remove-Item -Path $downloadFolder -Recurse -Force
}

New-Item -path $downloadFolder -type directory

if(!(Test-Path $webPICmd)) {

    $wpiInstaller = "$downloadFolder\wpiLauncher.exe"
    $source = "http://download.microsoft.com/download/8/C/5/8C5EEDC7-3D72-4BB6-A55E-37F3977CD892/wpilauncher.exe"

    Invoke-WebRequest -Uri $source -OutFile $wpiInstaller

    Run-Process -processFileName $wpiInstaller

    $ProcessActive = $null
    while($ProcessActive -eq $null){
        Start-Sleep -s 5
        $ProcessActive = Get-Process -name "WebPlatformInstaller" | Format-Wide -Column 1
    }

    Stop-Process -Name "WebPlatformInstaller"
}

$webPICmdArgs = "/Install /Products:$webpiProducts /AcceptEula /SuppressReboot"

write-host "$webPiCmd  $webPICmdArgs"
if(Test-Path -path $webPICmd){
    Run-Process -processFileName $webPICmd -processArguments $webPICmdArgs
}

Read-S3Object -BucketName $deployFileBucket -key $deployFileKey -File "$downloadFolder/$deployFileKey"

$zipOutputFolder = Join-Path $downloadFolder "unzip"
$fullZipPath = Join-Path $downloadFolder $deployFileKey

New-Item -ItemType Directory -Path $zipOutputFolder -Force

$shell = New-Object -com shell.application

$zipFile = $shell.namespace("$fullZipPath")
$zipOutput = $shell.namespace($zipOutputFolder)
$zipOutput.CopyHere($zipFile.items())

$cmdFile = ls $downloadFolder\**\*.cmd

$batCmd = $cmdFile[0].FullName

Run-Process -processFileName $batCmd -processArguments "/Y"

Remove-Item -Path $downloadFolder -Recurse -Force 
