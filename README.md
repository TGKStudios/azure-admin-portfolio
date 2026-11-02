# Azure Administration Portfolio

Hands-on Microsoft Azure and Microsoft Entra ID administration scenarios, built while preparing for **AZ-104: Microsoft Azure Administrator**. Each scenario starts from a realistic business request, is built and automated with PowerShell, then proven, deliberately broken, and torn down.

All scenarios run in my personal lab tenant. *Ridgeline Supply Co.* is a fictional company used to give each scenario a business reason.

## Scenarios

| # | Scenario | What it shows | Status |
|---|---|---|---|
| 01 | [New-hire onboarding with Entra ID and Microsoft Graph](scenarios/01-entra-onboarding-graph/) | Users, dynamic groups, group-based licensing, B2B guests, SSPR, Microsoft Graph PowerShell | Built; script in progress |
| 02 | [Least-privilege access with Azure RBAC](scenarios/02-least-privilege-rbac/) | Custom roles, role scopes, role-assignable groups, orphaned assignment cleanup | Built; scripts in progress |
| 03 | [Governance guardrails](scenarios/03-governance-guardrails/) | Azure Policy, remediation tasks, managed identities, management groups, resource locks | Built; script in progress |
| 04 | [Secure vendor file storage](scenarios/04-secure-vendor-storage/) | SAS and stored access policies, lifecycle tiers, object replication, storage firewall | Planned |

## How each scenario is organized

- **README.md**: the request, what I built, the design decisions and why, and **what broke and how I fixed it**.
- **PowerShell scripts**, added as each one is finished: parameterized, with comment-based help (`Get-Help .\Script.ps1 -Full`) and `-WhatIf` support where they change things.
- **Clean-up**: every scenario says how to remove what it created.

## Safety

- No keys, SAS tokens, passwords, tenant IDs or subscription IDs in this repository. Scripts take those as parameters.
- A pre-commit hook (`tools/Test-NoSecrets.ps1`) scans every commit for secrets and blocks it if it finds one.

## Certifications

- Microsoft Certified: Azure Fundamentals (AZ-900), August 2026
- Microsoft Certified: Azure Administrator Associate (AZ-104), in progress

## About

Tyler Kauffman, IT professional with about 10 years in IT support and systems administration: identity and access management, Microsoft Entra ID, Active Directory, Intune and Microsoft 365. Based in the Columbus, Ohio area.
