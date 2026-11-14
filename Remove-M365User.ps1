<#
.SYNOPSIS
    Executes same-day Zero Trust offboarding for an Entra ID user: blocks sign-in,
    revokes active sessions, removes shared mailbox delegation, and reclaims licenses.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [string]$SharedMailbox = "itsupport@Eze365.onmicrosoft.com",
    [switch]$UseDeviceAuth
)

$ErrorActionPreference = "Stop"

# 1. Connect to Microsoft Graph and Exchange Online
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
$graphParams = @{
    Scopes    = "User.ReadWrite.All", "Directory.AccessAsUser.All"
    NoWelcome = $true
}
if ($UseDeviceAuth) { $graphParams.UseDeviceAuthentication = $true }
Connect-MgGraph @graphParams

if (-not (Get-MgContext)) { throw "Not connected to Microsoft Graph. Sign-in was cancelled or failed." }

Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
if ($UseDeviceAuth) {
    Connect-ExchangeOnline -Device -ShowBanner:$false
} else {
    Connect-ExchangeOnline -ShowBanner:$false
}

# 2. Verify User Exists
$User = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -ErrorAction SilentlyContinue
if (-not $User) { throw "User '$UserPrincipalName' not found in Entra ID." }

# 3. Block Sign-In Immediately
Update-MgUser -UserId $User.Id -AccountEnabled:$false
Write-Host "Blocked sign-in for $UserPrincipalName" -ForegroundColor Yellow

# 4. Revoke All Active Refresh Tokens / Sessions
Revoke-MgUserSignInSession -UserId $User.Id | Out-Null
Write-Host "Revoked all active sessions for $UserPrincipalName" -ForegroundColor Yellow

# 5. Remove Shared Mailbox Delegation (if present)
if (Get-Mailbox -Identity $SharedMailbox -ErrorAction SilentlyContinue) {
    Remove-MailboxPermission -Identity $SharedMailbox -User $UserPrincipalName -AccessRights FullAccess -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Removed FullAccess delegation from $SharedMailbox" -ForegroundColor Yellow
}

# 6. Strip Paid Licenses to Reclaim Seats
$AssignedLicenses = (Get-MgUserLicenseDetail -UserId $User.Id).SkuId
if ($AssignedLicenses) {
    Set-MgUserLicense -UserId $User.Id -AddLicenses @() -RemoveLicenses $AssignedLicenses | Out-Null
    Write-Host "Reclaimed $($AssignedLicenses.Count) license(s) from $UserPrincipalName" -ForegroundColor Yellow
}

# 7. Clean Up Sessions
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph | Out-Null
Write-Host "Offboarding complete for $UserPrincipalName." -ForegroundColor Green
