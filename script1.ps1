#####
#
# Script 1 
# 43 - Beyond AWS Basics: PowerShell + AWS Basics: Automating Web Application Deployments
#
#####

$iamProfileName = (Invoke-WebRequest http://169.254.169.254/latest/meta-data/iam/security-credentials).Content
$iamProfileInfo = ConvertFrom-Json (Invoke-WebRequest http://169.254.169.254/latest/meta-data/iam/security-credentials/$iamProfileName).Content

Write-Host ""
Write-Host "Using IAM Profile assigned to machine:"
Write-Host "-----------------------------------"
Write-Host "        IAM Profile Name: $iamProfileName"
Write-Host "        IAM Profile Type:"$iamProfileInfo.Type
Write-host " IAM Profile AccessKeyId:"$iamProfileInfo.AccessKeyId
Write-Host "-----------------------------------"
