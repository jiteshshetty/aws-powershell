#####
#
# Script 3
# 43 - Beyond AWS Basics: PowerShell + AWS Basics: Automating Web Application Deployments
#
#####

param(
    [string]$existingS3Bucket = $(Read-Host "Enter the name of the bucket created earlier in this lab "),
    [ValidateScript({Test-Path $_ -PathType 'File'})]
    [string]$uploadFilePath = $(Read-host "Enter path to file for upload")
)

Import-Module AWSPowerShell

$keyName = ([System.IO.FileInfo]"$uploadFilePath").Name

Write-S3Object -BucketName $existingS3Bucket -File $uploadFilePath -Key $keyName
	
Write-Host ""
Write-Host "-----------------------------------"
Write-Host "      Bucket Name: $existingS3Bucket"
Write-Host " File Uploaded to: $keyName"
Write-host "      Source File: $uploadFilePath"
Write-Host "-----------------------------------"
Write-Host "S3 Bucket creation and file upload complete" 
