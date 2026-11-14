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

## Creating Windows Device Compliance Policy:
<img width="1909" height="914" alt="image" src="https://github.com/user-attachments/assets/8cabc2ab-15da-4801-8b62-4d660f4ae51c" />

## Conditional access policies:
<img width="1409" height="851" alt="image" src="https://github.com/user-attachments/assets/f2063d7a-17fc-4362-a190-1f0a24a4ff74" />

## Creating IT support Shared mailbox:
<img width="1858" height="865" alt="image" src="https://github.com/user-attachments/assets/c844bd58-a370-4500-b1a3-9aab1be8b76e" />

## Creating new mailbox rule to label mail from external senders
<img width="1914" height="879" alt="image" src="https://github.com/user-attachments/assets/69e744e5-dc5c-4d37-af3f-270c239b04de" />

## Checking for rule trigger [successful]
<img width="1908" height="891" alt="image" src="https://github.com/user-attachments/assets/3cdaeb17-6e38-48a6-9a50-c36f40c0b01d" />
<img width="1573" height="317" alt="image" src="https://github.com/user-attachments/assets/a70ccbf9-8cc4-4aa9-9e1a-daf0a1ea552d" />



