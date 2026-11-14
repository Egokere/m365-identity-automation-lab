# Microsoft 365 & Entra ID Administration Lab

A hands-on Microsoft 365 Business Premium lab built to practice day-to-day identity, endpoint, and messaging administration alongside PowerShell 7 automation.

## What I Built & Configured

* **Automated Onboarding (`New-M365User.ps1`):** Parameterized PowerShell 7 script using `Microsoft.Graph` and `ExchangeOnlineManagement` that checks available licenses, creates a new Entra ID user, assigns a Business Premium SKU, polls until the Exchange mailbox finishes provisioning, and delegates Full Access to the IT Support shared mailbox.
* **Automated Offboarding (`Remove-M365User.ps1`):** Parameterized offboarding script that immediately disables sign-in, revokes active refresh tokens/sessions, strips shared mailbox permissions, and reclaims the user's M365 license.
* **Zero Trust Access (Entra ID + Intune):** Configured an Intune Windows 10/11 compliance policy (BitLocker, Firewall, Antivirus) tied to a Conditional Access policy requiring MFA and a compliant device for all users, with Break-Glass admin exclusions.
* **Exchange Online:** Set up an unlicensed IT Support shared mailbox (`FullAccess` and `SendAs` delegation), configured an inbound `[EXTERNAL]` email warning transport rule, and validated delivery paths with Message Trace.

## Example Usage

```powershell
# Onboard a new user
.\New-M365User.ps1 -DisplayName "Charlie Davis" -UserPrincipalName "charlie@://onmicrosoft.com" -MailNickname "charlie"

# Offboard a user and reclaim their license
.\Remove-M365User.ps1 -UserPrincipalName "charlie@://onmicrosoft.com"
```

<img width="1893" height="910" alt="image" src="https://github.com/user-attachments/assets/fdc7c166-ccfc-4d0c-802b-9eb8856e0698" />
