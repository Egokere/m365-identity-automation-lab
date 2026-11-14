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

## Assigning a license to one of my users:
<img width="1910" height="908" alt="image" src="https://github.com/user-attachments/assets/71c894cc-3a80-4f0a-89c1-a07d3becbc1c" />

## Created Windows Device Compliance Policy
<img width="1909" height="914" alt="image" src="https://github.com/user-attachments/assets/8cabc2ab-15da-4801-8b62-4d660f4ae51c" />
