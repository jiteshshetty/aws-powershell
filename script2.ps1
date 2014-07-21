#####
#
# Script 2
# 43 - Beyond AWS Basics: PowerShell + AWS Basics: Automating Web Application Deployments
#
#####

param(
    [string]$uniqueNameKey = $(Read-Host "Enter EC2 Key Pair name to ensure unique naming")
)

$iamGroup = New-IAMGroup -Path "/demo-groups/" -GroupName "ec2LaunchAccessGroup_$uniqueNameKey"

Write-Host "New Group Name: " + $iamGroup.GroupName
Write-Host "           Arn: " + $iamGroup.Arn
Write-Host "       GroupId: " + $iamGroup.GroupId
Write-Host "          Path: " + $iamGroup.Path

$iamUser = New-IAMUser -Path "/demo-users/" -UserName "ec2LaunchUser_$uniqueNameKey"
Add-IAMUserToGroup -UserName $iamUser.UserName -GroupName $iamGroup.GroupName

$ec2PolicyDoc = "{""Statement"": [{""Effect"": ""Allow"",""Action"": ""ec2:*"",""Resource"": ""*""}, {""Effect"": ""Allow"",""Action"": ""s3:*"", ""Resource"": ""arn:aws:s3:::*""}]}"

$policyName = "ec2LaunchUserPolicy" 
if($uniqueNameKey.Trim().Length -gt 0) {
    $policyName += "_$uniqueNameKey"
}

Write-IAMGroupPolicy -GroupName $iamGroup.GroupName -PolicyName $policyName -PolicyDocument $ec2PolicyDoc

$securityCreds = New-IAMAccessKey -UserName $iamUser.UserName

Write-Host ""
Write-Host "----------------------------------------------"
Write-Host "Security Cred User Name: " + $securityCreds.UserName
Write-Host "                 Status: " + $securityCreds.Status
Write-Host "            AccessKeyID: " + $securityCreds.AccessKeyId
Write-Host "        SecretAccessKey: " + $securityCreds.SecretAccessKey
Write-Host "----------------------------------------------"

Set-AWSCredentials -AccessKey $securityCreds.AccessKeyId -SecretKey $securityCreds.SecretAccessKey -StoreAs labCredSet

Write-Host "User, Group, Policy and AWS Credentials have been created and configured" 
