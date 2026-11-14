<#
.SYNOPSIS
    Creates a new Entra ID user, assigns a license, and grants access to a shared mailbox.
#>

param(
    [string]$DisplayName       = "Charlie Davis",
    [string]$UserPrincipalName = "charlie@Eze365.onmicrosoft.com",
    [string]$MailNickname      = "charlie",
    [string]$TempPassword      = "TempPass2026!",
    [string]$SharedMailbox     = "itsupport@Eze365.onmicrosoft.com",
    [string]$SkuPartNumber     = "SPB",   # Microsoft 365 Business Premium
    [int]$MailboxTimeoutMinutes = 10,
    [switch]$UseDeviceAuth                # use if the browser sign-in popup keeps failing
)

# Stop at the first real error instead of cascading
$ErrorActionPreference = "Stop"

# 1. Connect to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
$graphParams = @{
    Scopes    = "User.ReadWrite.All", "Organization.Read.All"
    NoWelcome = $true
}
if ($UseDeviceAuth) { $graphParams.UseDeviceAuthentication = $true }
Connect-MgGraph @graphParams

# Verify the connection actually succeeded
if (-not (Get-MgContext)) { throw "Not connected to Microsoft Graph. Sign-in was cancelled or failed." }

# 2. Connect to Exchange Online
Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
if ($UseDeviceAuth) {
    Connect-ExchangeOnline -Device -ShowBanner:$false
} else {
    Connect-ExchangeOnline -ShowBanner:$false
}

# 3. Pre-flight checks (before creating anything)
$License = Get-MgSubscribedSku | Where-Object { $_.SkuPartNumber -eq $SkuPartNumber } | Select-Object -First 1
if (-not $License) {
    $available = (Get-MgSubscribedSku).SkuPartNumber -join ", "
    throw "SKU '$SkuPartNumber' not found in tenant. Available SKUs: $available"
}
$freeUnits = $License.PrepaidUnits.Enabled - $License.ConsumedUnits
if ($freeUnits -lt 1) { throw "No free licenses left for $SkuPartNumber." }

if (-not (Get-Mailbox -Identity $SharedMailbox -ErrorAction SilentlyContinue)) {
    throw "Shared mailbox '$SharedMailbox' was not found in Exchange Online."
}

$existing = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -ErrorAction SilentlyContinue
if ($existing) { throw "User $UserPrincipalName already exists. Aborting." }

# 4. Create the user in Entra ID
$UserParams = @{
    DisplayName       = $DisplayName
    UserPrincipalName = $UserPrincipalName
    MailNickname      = $MailNickname
    AccountEnabled    = $true
    UsageLocation     = "US"
    PasswordProfile   = @{
        Password                      = $TempPassword
        ForceChangePasswordNextSignIn = $true
    }
}

$NewUser = New-MgUser @UserParams
if (-not $NewUser.Id) { throw "User creation did not return an object ID." }
Write-Host "Created user: $($NewUser.UserPrincipalName)" -ForegroundColor Green

# 5. Assign the license
Set-MgUserLicense -UserId $NewUser.Id -AddLicenses @{ SkuId = $License.SkuId } -RemoveLicenses @() | Out-Null
Write-Host "Assigned $SkuPartNumber license to $($NewUser.DisplayName)" -ForegroundColor Green

# 6. Wait for the mailbox to be provisioned (poll instead of a fixed sleep)
Write-Host "Waiting for Exchange mailbox provisioning (up to $MailboxTimeoutMinutes min)..." -ForegroundColor Cyan
$deadline = (Get-Date).AddMinutes($MailboxTimeoutMinutes)
do {
    Start-Sleep -Seconds 15
    $mbx = Get-Mailbox -Identity $NewUser.UserPrincipalName -ErrorAction SilentlyContinue
} until ($mbx -or (Get-Date) -gt $deadline)

if (-not $mbx) {
    throw "Mailbox for $($NewUser.UserPrincipalName) was not provisioned within $MailboxTimeoutMinutes minutes. Re-run the permission step later."
}

# 7. Grant access to the shared mailbox
Add-MailboxPermission -Identity $SharedMailbox -User $NewUser.UserPrincipalName -AccessRights FullAccess -AutoMapping $true | Out-Null
Write-Host "Granted FullAccess to $SharedMailbox" -ForegroundColor Green

# 8. Clean up sessions
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-MgGraph | Out-Null
Write-Host "Done." -ForegroundColor Green