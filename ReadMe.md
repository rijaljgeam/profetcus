# 🎯 Pre-Requisite

## 1. Azure Authentication
```bash
# Login to Azure (use device code if browser doesn't work on WSL)
az login

# Verify you're using the correct subscription
az account show

# Set the subscription (already in variables.tf)
az account set --subscription "e41e0c9f-a4e9-4b2c-af90-a5bd668f2229"
```

## 2. Verify Backend State Storage Exists
Backend Initialization Check:
Check if bootstrap has been initialized:
Look for the backend.hcl file in your directory


If backend.hcl exists:
Verify that the storage account  in the file actually exists
If the storage account exists, you're ready to proceed with: terraform init -backend-config=backend.hcl


If backend.hcl does NOT exist:
Run: make bootstrap
This will create the storage account needed for storing the backend state file
The bootstrap process will generate the backend.hcl file
After bootstrap completes, proceed with: terraform init -backend-config=backend.hcl
---

# 🚦 Deployment Options

You can deploy the environment in two different ways:

---

## Option 1 — Manual Full-Cycle Deployment

Run each step individually to understand the full Terraform workflow:

```bash
make init      # Initialize backend and download providers
make fmt       # Format Terraform code
make validate  # Validate configuration syntax
make tfsec     # Security checks 
make plan      # Preview planned infrastructure changes
make apply     # Deploy resources (5–10 minutes)
make curl      # Test the API endpoint
```

Ideal for demonstrating each phase of Infrastructure as Code execution.

---

## Option 2 — One-Command Automated Deployment

Run an end-to-end deployment using a single command:

```bash
make deploy
```

This automatically performs:

bootstrap(initializes the backend stroage,if not) → fmt → validate → tfsec → plan → apply → curl  
Total runtime: ~12–15 minutes

Useful for fast CI-style execution.

---

# 🧱 What Will Be Created
```
# - Resource Group (quoteapi)
# - App Service Plan (B1 Linux, 2 instances)
# - Linux Web App (containerized Quote API)
# - PostgreSQL Flexible Server (B_Standard_B1ms, 7-day backups)
# - Key Vault (stores DB connection string)
# - Log Analytics Workspace
# - Diagnostic Settings (HTTP logs + PostgreSQL logs)
```

---

## Step 6: Verify the Deployment
```bash
# Test the API endpoint
make curl

# Should return JSON with quotes:
# {"id":1,"text":"Sample quote","author":"Someone"}

# Alternative manual test:
curl -v https://quoteapi-linux.azurewebsites.net/api/quotes
```

---

## Step 7: Show the Azure Portal (Optional)
```
# Open Azure Portal and show:
# 1. Resource Group "quoteapi" with all resources
# 2. App Service - show container logs
# 3. Key Vault - show secret (connection string)
# 4. Log Analytics - show query results
# 5. PostgreSQL - show database "quoteapi"
```

---

## Step 8: Demonstrate Destroy 
```bash
# Clean destroy
make destroy
```

---

**Estimated Azure Costs (if left running):**
- App Service (B1): ~$13/month
- PostgreSQL (B_Standard_B1ms): ~$12/month  
- Key Vault: ~$0.03/month
- Log Analytics: ~$2-5/month (depends on ingestion)

**Total: ~$27-30/month** if resources are left running.

---
# 🎓 Essential Eight Controls Mapping

Present this table during the demo:

| Control Area | Implementation | Resource |
|-------------|----------------|----------|
| **Application Control** | Containerized app deployment via Azure App Service | `modules/compute/` |
| **Patch Management** | Managed PostgreSQL with automatic patches | `modules/data/` |
| **Configuration Hardening** | Terraform IaC + Remote State + Key Vault for secrets | `backend.tf`, `modules/secrets/` |
| **User Access Control** | Azure AD Managed Identities for secure access | System-assigned MSI in compute module |
| **Restrict Admin Privileges** | Principle of least privilege via Key Vault RBAC | `modules/secrets/main.tf` |
| **Regular Backups** | PostgreSQL automated backups (7-day retention) | `modules/data/main.tf` |
| **Logging & Monitoring** | Log Analytics Workspace + Diagnostic Settings | `main.tf` logging section |

---

# 🐛 Troubleshooting Common Issues

## Issue 1: "Resource already exists" during apply
**Cause:** Previous deployment wasn't fully destroyed  
**Fix:**
```bash
# Force delete the resource group
az group delete --name quoteapi --yes --no-wait

# Wait for deletion to complete (check in portal)
# Then retry: make init && make apply
```

---

## Issue 2: Key Vault soft-delete prevents recreation
**Cause:** Key Vault has 7-90 day soft-delete period  
**Fix:**
```bash
# Purge the soft-deleted Key Vault
az keyvault purge --name profectdemo-kv --location australiaeast

# Or wait for soft-delete period to expire
# Or use a different keyvault_prefix in variables
```

---

## Issue 3: Container fails to start
**Cause:** Docker Hub rate limiting or wrong image  
**Check logs:**
```bash
az webapp log tail --name quoteapi-linux --resource-group quoteapi
```

---

## Issue 4: App can't read Key Vault secret
**Cause:** Managed identity propagation delay (~30-60 seconds)  
**Fix:** Wait 1 minute after apply, then restart app:
```bash
az webapp restart --name quoteapi-linux --resource-group quoteapi
```

---

## Issue 5: "Authentication failed" errors
**Cause:** Not logged into Azure CLI  
**Fix:**
```bash
az login
az account set --subscription "e41e0c9f-a4e9-4b2c-af90-a5bd668f2229"
```

---

# 📊 Expected Timeline

| Step | Duration | Notes |
|------|----------|-------|
| `make init` | 30 sec | Downloads providers |
| `make fmt` | 5 sec | Formats files |
| `make validate` | 5 sec | Validates config |
| `make plan` | 1-2 min | Shows execution plan |
| `make apply` | 5-10 min | **Longest step** (PostgreSQL creation) |
| `make curl` | 5 sec | Tests API |
| `make destroy` | 10-15 min | Deletes all resources |

Total Demo Time: ~25 minutes (15 for apply+destroy)

---

# 🔐 Security Notes 

1. PostgreSQL firewall is wide open (0.0.0.0/0)  for public access as requested
2. KeyVault Purge protection is not enabled as we would like to destroy it completely on destroy
3. No network isolation  

---

# 📝 Post-Demo Cleanup

```bash
make destroy

# Double-check everything is gone
az group list --query "[?name=='quoteapi']"

# If resources persist, force delete
az group delete --name quoteapi --yes --no-wait

# Delete Everything (Infra+StateFiles+CacheFiles+Backend.hdl)
make nuke
```
