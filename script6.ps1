#﻿
#
# Script 6
# 43 - Beyond AWS Basics: PowerShell + AWS Basics: Automating Web Application Deployments
#
#####

param( 
    $deployFileBucket = $(Read-Host "Enter the name of the bucket where the WebDeploy package was uploaded to"), 
    $deployFileKey = "webdeploypackage.zip"
)
	
$keyName = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/public-keys/).Content.Substring(2)
$ec2SecurityGroup = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/security-groups).Content
$iamRoleName = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/iam/security-credentials).Content
$iamInstanceProfileArn = (Get-IAMInstanceProfileForRole -RoleName $iamRoleName).Arn
$instanceAMIId = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/ami-id).Content
$instanceType = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/instance-type).Content
$availabilityZone = (Invoke-WebRequest -Uri http://169.254.169.254/latest/meta-data/placement/availability-zone).Content
$region = $availabilityZone.Substring(0, $availabilityZone.Length - 1)
	
$nl = [Environment]::NewLine
$powerShellCommand = "<powershell>" + $nl
$powerShellCommand += "param(" + $nl
$powerShellCommand += "    [string]`$webpiProducts = `"ASPNET45,WDeployPS,WDeployNoSMO,WDeploy`"," + $nl
$powerShellCommand += "    [string]`$deployFileKey = `"$deployFileKey`"," + $nl
$powerShellCommand += "    [string]`$deployFileBucket = `"$deployFileBucket`"" + $nl
$powerShellCommand += ")" + $nl + $nl
$powerShellCommand += "Import-Module AWSPowerShell" + $nl + $nl
$powerShellCommand += "function Run-Process([string]`$processFileName, [string]`$processArguments) {" + $nl
$powerShellCommand += "    `$pinfo = New-Object System.Diagnostics.ProcessStartInfo" + $nl 
$powerShellCommand += "    `$pinfo.FileName = `$processFileName" + $nl 
$powerShellCommand += "    `$pinfo.RedirectStandardError = `$false" + $nl 
$powerShellCommand += "    `$pinfo.RedirectStandardOutput = `$false" + $nl 
$powerShellCommand += "    `$pinfo.UseShellExecute = `$true" + $nl 
$powerShellCommand += "    `$pinfo.Arguments = `$processArguments" + $nl 
$powerShellCommand += "    `$p = New-Object System.Diagnostics.Process" + $nl 
$powerShellCommand += "    `$p.StartInfo = `$pinfo" + $nl 
$powerShellCommand += "    `$p.Start()" + $nl 
$powerShellCommand += "    `$p.WaitForExit()" + $nl 
$powerShellCommand += "    Write-Host `"exit code: `" + $p.ExitCode" + $nl 
$powerShellCommand += "}" + $nl + $nl
$powerShellCommand += "`$webPICmd = `"C:\Program Files\Microsoft\Web Platform Installer\webpicmd.exe`"" + $nl 
$powerShellCommand += "`$downloadFolder = Join-Path `$env:Temp `"bootstrapInstall`"" + $nl 
$powerShellCommand += "if(Test-Path `$downloadFolder) {" + $nl 
$powerShellCommand += "    Remove-Item -Path `$downloadFolder -Recurse -Force" + $nl 
$powerShellCommand += "}" + $nl 
$powerShellCommand += "New-Item -path `$downloadFolder -type directory" + $nl 
$powerShellCommand += "if(!(Test-Path `$webPICmd)) {" + $nl 
$powerShellCommand += "    `$wpiInstaller = `"`$downloadFolder\wpiLauncher.exe`"" + $nl
$powerShellCommand += "    `$source = ""http://download.microsoft.com/download/8/C/5/8C5EEDC7-3D72-4BB6-A55E-37F3977CD892/wpilauncher.exe""" + $nl 
$powerShellCommand += "    Invoke-WebRequest -Uri `$source -OutFile `$wpiInstaller" + $nl
$powerShellCommand += "    Run-Process -processFileName `$wpiInstaller" + $nl + $nl
$powerShellCommand += "    `$ProcessActive = `$null" + $nl
$powerShellCommand += "    while(`$ProcessActive -eq `$null){" + $nl
$powerShellCommand += "        Start-Sleep -s 5" + $nl
$powerShellCommand += "        `$ProcessActive = Get-Process -name `"WebPlatformInstaller`" | Format-Wide -Column 1" + $nl
$powerShellCommand += "    }" + $nl + $nl
$powerShellCommand += "    Stop-Process -Name `"WebPlatformInstaller`"" + $nl
$powerShellCommand += "}" + $nl + $nl
$powerShellCommand += "`$logPath = Join-Path `$downloadFolder `"webpilog.txt`"" + $nl + $nl
$powerShellCommand += "`$webPICmdArgs = `"/Install /Products:`$webpiProducts /AcceptEula /SuppressReboot`"" + $nl + $nl
$powerShellCommand += "write-host `"`$webPiCmd  `$webPICmdArgs`"" + $nl
$powerShellCommand += "if(Test-Path -path `$webPICmd){" + $nl
$powerShellCommand += "    Run-Process -processFileName `$webPICmd -processArguments `$webPICmdArgs" + $nl
$powerShellCommand += "}" + $nl + $nl
$powerShellCommand += "Read-S3Object -BucketName `$deployFileBucket -key `$deployFileKey -File `"`$downloadFolder/`$deployFileKey`"" + $nl + $nl
$powerShellCommand += "`$zipOutputFolder = Join-Path `$downloadFolder `"unzip`"" + $nl
$powerShellCommand += "`$fullZipPath = Join-Path `$downloadFolder `$deployFileKey" + $nl + $nl
$powerShellCommand += "New-Item -ItemType Directory -Path `$zipOutputFolder -Force" + $nl + $nl
$powerShellCommand += "`$shell = New-Object -com shell.application" + $nl + $nl
$powerShellCommand += "`$zipFile = `$shell.namespace(`"`$fullZipPath`")" + $nl
$powerShellCommand += "`$zipOutput = `$shell.namespace(`$zipOutputFolder)" + $nl
$powerShellCommand += "`$zipOutput.CopyHere(`$zipFile.items())" + $nl + $nl
$powerShellCommand += "`$cmdFile = ls `$downloadFolder\**\*.cmd" + $nl + $nl
$powerShellCommand += "`$batCmd = `$cmdFile[0].FullName" + $nl + $nl
$powerShellCommand += "Run-Process -processFileName `$batCmd -processArguments `"/Y`"" + $nl + $nl
$powerShellCommand += "Remove-Item -Path `$downloadFolder -Recurse -Force" + $nl
$powerShellCommand += "</powershell>" + $nl
$powerShellCommandBytes = [System.Text.Encoding]::UTF8.GetBytes($powerShellCommand)
$powerShellCommandUserData = [System.Convert]::ToBase64String($powerShellCommandBytes)

Set-DefaultAWSRegion $region

$newInstance = New-EC2Instance -ImageId $instanceAMIId -InstanceType $instanceType -KeyName $keyName -InstanceProfile_Arn $iamInstanceProfileArn -SecurityGroups $ec2SecurityGroup -UserData $powerShellCommandUserData -Placement_AvailabilityZone $availabilityZone -MinCount 1 -MaxCount 1
$nameTag = New-Object Amazon.EC2.Model.Tag

Write-Host "-----------------------------------------------"
Write-Host "       Instance ID: " $newInstance.RunningInstance[0].InstanceID
Write-Host "    Instance State: " $newInstance.RunningInstance[0].InstanceState.Name
Write-Host "          Key Name: " $newInstance.RunningInstance[0].KeyName
Write-Host " Availability Zone: " $newInstance.RunningInstance[0].Placement.AvailabilityZone
Write-Host "-----------------------------------------------"

$tag = New-Object Amazon.EC2.Model.Tag 
$tag.Key = "Name" 
$tag.Value = "AutoBootstrapTest" 
New-EC2Tag -Resources $newInstance.Instances[0].InstanceId -Tags $tag 

Write-Host "Completed creating instance in EC2 and tagged with name AutoBootstrapTest" 
