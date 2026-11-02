# 03 · Governance guardrails: Azure Policy, management groups and resource locks

**The request.** "Our data has to stay in the US for our insurance contract, finance needs every resource tagged with a cost center, and last week someone deleted the production database by accident."

## What I built

- A **management group** with the subscription inside it, so any subscription added later gets the same rules.
- Three **Azure Policy** assignments:
    - *Allowed locations*: East US and West US only.
    - *Require a tag on resource groups*: `costcenter`.
    - *Inherit a tag from the resource group if missing*: copies `costcenter` down to resources, using the Modify effect.
- A **system-assigned managed identity** for the Modify policy, holding the **Tag Contributor** role, plus a **remediation task** for resources that existed before the policy.
- A **CanNotDelete lock** on the resource group.

## Proof

Each guardrail blocked a different mistake, even for the subscription Owner.

| Attempt | Blocked by | Error code |
|---|---|---|
| Create a resource group with no tag | Policy: require-costcenter | `RequestDisallowedByPolicy` |
| Create a storage account in West US 2 | Policy: allowed-locations | `RequestDisallowedByPolicy` |
| Delete the locked resource group | Resource lock | `ScopeLocked` |

A storage account I never tagged came out tagged `costcenter: CC100`, because the inherit policy copied it from the resource group.

## What broke, and how I fixed it

| Symptom | Cause | Fix |
|---|---|---|
| My first location test, in West Europe, failed with `RequestDisallowedByAzure` | That region wasn't accepting new customers for my subscription, so my policy was never evaluated | Re-tested in an open region (West US 2) and got `RequestDisallowedByPolicy`. Lesson: read *which system* refused a request before deciding why |

## Script

`Set-GovernanceBaseline.ps1` (in progress): assigns the three policies at a scope you choose, with parameters for the allowed regions and the tag name. It gives the policy's identity its role and starts remediation.

## Clean-up

Order matters. A lock has to come off before its resource group can be deleted. The policy identity's role has to go before the policy does, or it's left behind as an orphaned assignment.

```powershell
Remove-AzResourceLock -LockName nodelete -ResourceGroupName '<resource group>' -Force
Remove-AzResourceGroup -Name '<resource group>' -Force
Remove-AzRoleAssignment -ObjectId '<policy identity object id>' -RoleDefinitionName 'Tag Contributor' -Scope '/subscriptions/<subscription id>'
Remove-AzPolicyAssignment -Name inherit-costcenter -Scope '/subscriptions/<subscription id>'
Remove-AzPolicyAssignment -Name require-costcenter -Scope '/subscriptions/<subscription id>'
Remove-AzPolicyAssignment -Name allowed-locations -Scope '/subscriptions/<subscription id>'
Remove-AzManagementGroupSubscription -GroupName mg-ridgeline -SubscriptionId '<subscription id>'
Remove-AzManagementGroup -GroupName mg-ridgeline
```

## Skills

Azure Policy · policy effects (Deny, Modify) · remediation tasks · managed identities · management groups · resource locks · tagging
