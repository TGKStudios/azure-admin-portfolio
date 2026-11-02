# 02 · Least-privilege access with Azure RBAC

**The request.** "The night-shift tech needs to restart the warehouse servers when they hang. He must not be able to touch finance's resources or delete anything."

## What I built

- A **custom role**, *Ridgeline VM Operator*, with exactly five actions: read VMs, start, restart, deallocate, and read resource groups. No write, no delete.
- That role assigned at the **narrowest useful scope**, one resource group.
- **Reader** on the subscription, assigned to a group so access follows group membership.
- The Entra role **Password Administrator**, assigned to a **role-assignable group**. That group setting can only be chosen when the group is created, so I rebuilt the admin group to get it.

## Design decisions

- **Why a custom role:** the closest built-in role, Virtual Machine Contributor, includes `Microsoft.Compute/virtualMachines/*`. The wildcard allows deleting VMs, which the request rules out.
- **Roles go on groups, not people**, so onboarding and offboarding are membership changes, not permission changes.
- **Azure roles and Entra roles are separate systems.** Azure RBAC controls resources; Entra roles control identities. They're assigned in different places.

## What broke, and how I fixed it

| Symptom | Cause | Fix |
|---|---|---|
| `Get-AzRoleAssignment` failed: *could not load type ... from assembly Azure.Core* | The Microsoft Graph and Az modules load different versions of the same library, and in Windows PowerShell 5.1 whichever loads first wins | Run Az and Graph in separate PowerShell sessions |
| A Reader assignment showed **"Identity not found"** after I rebuilt the admin group | Deleting a group doesn't delete its role assignments. The orphan also keeps its original type, *Group*, so a filter on type *Unknown* missed it | Removed it by object ID. The script I'm writing below finds orphans by checking whether each principal still exists |

## Scripts

- `Grant-VmOperatorRole.ps1` (in progress): creates the custom role from `vm-operator-role.json` if it doesn't exist yet, then assigns it to a group at a resource-group scope. Safe to run twice.
- `Find-OrphanedRoleAssignments.ps1` (in progress): lists role assignments whose user, group or app no longer exists, and removes them only when asked.

## Skills

Azure RBAC · custom role definitions · role scopes and inheritance · Microsoft Entra roles · role-assignable groups · Az PowerShell
