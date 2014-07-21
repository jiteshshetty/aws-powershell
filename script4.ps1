#####
#
# Script 4
# 43 - Beyond AWS Basics: PowerShell + AWS Basics: Automating Web Application Deployments
#
#####

Import-Module AWSPowerShell
	
$instanceProfileInfo = ((Invoke-WebRequest http://169.254.169.254/latest/meta-data/iam/info).content | ConvertFrom-Json)
$roleName = (invoke-webrequest http://169.254.169.254/latest/meta-data/iam/security-credentials).Content
	
Write-Host ""
Write-Host "----------------------------------------"
Write-host " Instance Profile Arn: " + $instanceProfileInfo.InstanceProfileArn
Write-Host "  Instance Profile Id: " + $instanceProfileInfo.InstanceProfileId
Write-Host "Instance Profile Name: " + $roleName
Write-Host "        IAM Role Name: " + $iamRole.RoleName 
Write-Host "----------------------------------------"
Write-Host "Completed IAM Role description for instance" 
