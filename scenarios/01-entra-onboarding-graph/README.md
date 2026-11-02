# 01 · New-hire onboarding with Microsoft Entra ID and Microsoft Graph

**The request.** "Warehouse is hiring 12 people next month. HR is tired of emailing IT for every new account, and the auditor wants to know which outside contractors can sign in."

## What I built

Lab tenant with a Microsoft Entra ID P2 trial.

- Users created three ways: the Entra admin center, Microsoft Graph PowerShell (`New-MgUser`), and **Bulk create** from a CSV.
- **Dynamic security groups** driven by each user's Department attribute: Warehouse, Sales and Leadership.
- **Group-based licensing** on the Warehouse group, so new warehouse hires are licensed automatically.
- A **B2B guest** account for an outside contractor.
- **Self-service password reset** scoped to one group.

## Design decisions

- **Department drives access.** HR already maintains it, so an internal transfer moves a person's groups and licenses with no ticket. I tested this by changing one user's department with `Update-MgUser` and watching them move groups.
- **Licenses go on groups, not people.** Group-based licensing needs a usage location on every user, so the onboarding script I'm writing checks for it before creating anyone.
- **Dynamic groups need `-GroupTypes DynamicMembership`.** Without it, Graph creates an ordinary assigned group, stores the rule, and never applies it, with no error.

## What broke, and how I fixed it

| Symptom | Cause | Fix |
|---|---|---|
| `New-MgUser` returned **405 MethodNotAllowed** | `Connect-MgGraph` with a personal Microsoft account and no tenant signed me in to Microsoft's consumer tenant, where users can't be created | `Connect-MgGraph -TenantId <tenant>`, then confirm with `Get-MgContext` before changing anything |
| `New-MgGroup` returned **400** on `membershipRuleProcessingState` | The value must be `On` or `Paused` | Corrected the value |

## Script

`New-RidgelineHire.ps1` (in progress): reads a CSV of hires, checks each row, creates the users with Microsoft Graph, and reports which dynamic group each one will land in.

## Clean-up

```powershell
Remove-MgUser -UserId '<user principal name>'
Remove-MgGroup -GroupId '<group id>'
```

Deleted users stay in the Entra recycle bin for 30 days. The P2 trial ends on its own.

## Skills

Microsoft Entra ID · Microsoft Graph PowerShell · dynamic membership rules · group-based licensing · B2B collaboration · SSPR · bulk operations
