TF ?= terraform
TFSEC ?= tfsec
TFSEC_FLAGS ?= --soft-fail
FQDN ?= quoteapi-linux.azurewebsites.net
BOOTSTRAP_DIR ?= bootstrap

.PHONY: bootstrap bootstrap-init init fmt validate tfsec plan apply test destroy deploy clean clean-all bootstrap-destroy nuke

#Initialize Bootstrap, creates remote state storage
bootstrap:
	@echo "🔧 Setting up remote state storage..."
	@cd $(BOOTSTRAP_DIR) && $(TF) init && $(TF) apply -auto-approve
	@echo "✅ Backend configuration ready!"

# Initialize Terraform (with backend if exists)
init:
	@if [ -f backend.hcl ]; then \
		$(TF) init -backend-config=backend.hcl -reconfigure; \
	else \
		echo "💡 No backend.hcl found. Run 'make bootstrap' first for remote state."; \
		$(TF) init; \
	fi

# Format code
fmt:
	@$(TF) fmt -recursive

# Validate configuration
validate: 
	@$(TF) validate

# Security scan
tfsec:
	@$(TFSEC) $(TFSEC_FLAGS) .

# Plan changes
plan: 
	@$(TF) plan

# Apply changes
apply:
	@$(TF) apply -auto-approve

# Test API endpoint
curl:
	@echo ""
	@echo "🌐 Testing API endpoint...quoteapi-linux.azurewebsites.net/quotes"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@curl -s "https://$(FQDN)/quotes"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Destroy infrastructure
destroy:
	@$(TF) destroy -auto-approve

# Clean generated files
clean:
	@rm -f backend.hcl
	@echo "✅ Cleaned up backend configuration"

# Deep clean - remove all caches and generated files
clean-all:
	@echo "⚠️  WARNING: Only run this after destroying infrastructure and bootstrap!"
	@echo "Have you destroyed all infrastructure? Type 'yes' to proceed:"
	@read answer && [ "$$answer" = "yes" ] || (echo "❌ Aborted." && exit 1)
	@echo "🧹 Deep cleaning all Terraform files..."
	@rm -f backend.hcl
	@rm -rf .terraform .terraform.lock.hcl
	@rm -f terraform.tfstate terraform.tfstate.backup
	@rm -rf $(BOOTSTRAP_DIR)/.terraform $(BOOTSTRAP_DIR)/.terraform.lock.hcl
	@rm -f $(BOOTSTRAP_DIR)/terraform.tfstate $(BOOTSTRAP_DIR)/terraform.tfstate.backup
	@rm -f $(BOOTSTRAP_DIR)/backend.hcl
	@echo "✅ All Terraform caches and state files removed"

# Destroy bootstrap infrastructure
bootstrap-destroy:
	@echo "⚠️  Destroying bootstrap infrastructure..."
	@cd $(BOOTSTRAP_DIR) && $(TF) destroy -auto-approve
	@$(MAKE) clean
	@echo "Remove bootstrap local state files and caches? Type 'yes' to proceed:"
	@read answer && [ "$$answer" = "yes" ] && \
		rm -rf $(BOOTSTRAP_DIR)/.terraform $(BOOTSTRAP_DIR)/.terraform.lock.hcl && \
		rm -f $(BOOTSTRAP_DIR)/terraform.tfstate $(BOOTSTRAP_DIR)/terraform.tfstate.backup && \
		echo "✅ Bootstrap destroyed and cleaned" || \
		echo "✅ Bootstrap destroyed"

# Nuclear option - destroy everything and clean all files
# Nuclear option - destroy everything and clean all files
nuke:
	@echo ""
	@echo "☢️  ═══════════════════════════════════════════════════════"
	@echo "☢️  NUCLEAR OPTION - COMPLETE DESTRUCTION"
	@echo "☢️  ═══════════════════════════════════════════════════════"
	@echo ""
	@echo "⚠️  This will permanently:"
	@echo "   💥 Destroy ALL main infrastructure resources"
	@echo "   💥 Destroy bootstrap storage account"
	@echo "   🗑️  Remove all Terraform state files"
	@echo "   🗑️  Remove all Terraform caches"
	@echo "   🗑️  Remove all lock files"
	@echo ""
	@echo "🚨 ═══════════════════════════════════════════════════════"
	@echo "🚨  ARE YOU ABSOLUTELY SURE?!"
	@echo "🚨 ═══════════════════════════════════════════════════════"
	@echo ""
	@echo "   This will launch the nuclear option and turn your"
	@echo "   infrastructure into a smoking crater! 💣"
	@echo ""
	@echo "   Everything. Will. Be. GONE. 💀"
	@echo ""
	@echo "   - Your databases? VAPORIZED! 🔥"
	@echo "   - Your storage? ATOMIZED! ☢️"
	@echo "   - Your configs? OBLITERATED! 💥"
	@echo "   - Your state files? ANNIHILATED! 🗑️"
	@echo ""
	@echo "   There's no undo button. No time machine. No backup plan."
	@echo "   This is the point of no return! 🎢"
	@echo ""
	@read -p "   Type 'NUKE IT' to proceed: " confirmation; \
	confirmation_upper=$$(echo "$$confirmation" | tr '[:lower:]' '[:upper:]'); \
	if [ "$$confirmation_upper" != "NUKE IT" ]; then \
		echo ""; \
		echo "✋ Phew! Crisis averted. Your infrastructure lives another day."; \
		echo "   (Probably a good call there, friend.) 😅"; \
		echo ""; \
		exit 1; \
	fi
	@echo ""
	@echo "💥 Launching nuclear strike in 3... 2... 1... 🚀"
	@sleep 1
	@echo ""
	@echo "💥 Step 1/3: Destroying main infrastructure..."
	@$(TF) destroy -auto-approve || true
	@echo ""
	@echo "💥 Step 2/3: Destroying bootstrap infrastructure..."
	@cd $(BOOTSTRAP_DIR) && $(TF) destroy -auto-approve || true
	@echo ""
	@echo "🧹 Step 3/3: Cleaning all files..."
	@rm -f backend.hcl
	@rm -rf .terraform .terraform.lock.hcl
	@rm -f terraform.tfstate terraform.tfstate.backup
	@rm -rf $(BOOTSTRAP_DIR)/.terraform $(BOOTSTRAP_DIR)/.terraform.lock.hcl
	@rm -f $(BOOTSTRAP_DIR)/terraform.tfstate $(BOOTSTRAP_DIR)/terraform.tfstate.backup
	@echo "✅ Removed backend.hcl"
	@echo "✅ Removed all Terraform state files"
	@echo ""
	@echo "💀 ═══════════════════════════════════════════════════════"
	@echo "💀 NUKE COMPLETE - Everything has been vaporized!"
	@echo "💀 Your infrastructure is now a beautiful wasteland. 🏜️"
	@echo "💀 Ready for fresh deployment with: make deploy"
	@echo "💀 ═══════════════════════════════════════════════════════"
	@echo ""

# Full deployment workflow
deploy: bootstrap init fmt validate tfsec plan apply curl
	@echo ""
	@echo "🎉 ═══════════════════════════════════════════════════════"
	@echo "🎉 DEPLOYMENT COMPLETE!"
	@echo "🎉 ═══════════════════════════════════════════════════════"
	@echo ""