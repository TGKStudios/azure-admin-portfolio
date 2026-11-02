# 04 · Secure vendor file storage

**The request.** "Our 30 suppliers email us invoices and shipping manifests, and the inbox is a mess. Give them somewhere to upload files directly. Keep the files for a year as cheaply as possible, make sure we can recover anything someone deletes, and keep a copy the auditors can't touch."

## Planned

- Storage account with TLS 1.2, no anonymous access, and geo-redundant storage (GRS).
- Blob versioning, soft delete and the change feed.
- Supplier access through SAS tokens tied to a stored access policy, so every supplier can be cut off at once without rotating keys.
- Lifecycle rules: Cool after 30 days, Cold after 90, Archive after 180, delete after 365.
- Object replication to a separate auditors' account, where the copy is read-only.
- Storage firewall, and reading the difference between a firewall block and a missing role.

## What broke, and how I fixed it

*Added once the build is done.*

## Script

*Planned:* `New-VendorDropbox.ps1`, which builds the whole setup with parameters for the account names, the retention days and the supplier link's lifetime.
