#!/bin/bash
# Quick Demo Script - Run this for the live presentation
# Usage: ./demo.sh

set -e  # Exit on error

echo "=================================================="
echo "🚀 Terraform Azure Infrastructure Live Demo"
echo "=================================================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform not found. Please install it first."
    exit 1
fi
echo "✅ Terraform $(terraform version -json | grep -o '"version":"[^"]*' | cut -d'"' -f4)"

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install it first."
    exit 1
fi
echo "✅ Azure CLI installed"

# Check Azure login
if ! az account show &> /dev/null; then
    echo "❌ Not logged into Azure. Running 'az login'..."
    az login
    az account set --subscription "e41e0c9f-a4e9-4b2c-af90-a5bd668f2229"
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
echo "✅ Logged into Azure subscription: $SUBSCRIPTION"
echo ""

# Ask user what to do
echo "What would you like to do?"
echo "1) Full demo (init → plan → apply → test → destroy)"
echo "2) Deploy only (init → plan → apply → test)"
echo "3) Destroy only"
echo "4) Quick test (assuming already deployed)"
echo "5) Validate configuration only"
echo ""
read -p "Enter choice [1-5]: " choice

case $choice in
    1)
        echo ""
        echo "=================================================="
        echo "📦 Step 1: Initialize Terraform"
        echo "=================================================="
        make init
        
        echo ""
        echo "=================================================="
        echo "✨ Step 2: Format and Validate"
        echo "=================================================="
        make fmt
        make validate
        
        echo ""
        echo "=================================================="
        echo "📝 Step 3: Preview Plan"
        echo "=================================================="
        make plan
        
        read -p "Continue with apply? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo "Aborted."
            exit 0
        fi
        
        echo ""
        echo "=================================================="
        echo "🏗️  Step 4: Deploy Infrastructure (5-10 minutes)"
        echo "=================================================="
        time make apply
        
        echo ""
        echo "=================================================="
        echo "🧪 Step 5: Test API Endpoint"
        echo "=================================================="
        sleep 10  # Give the app a few seconds to fully start
        make curl
        
        echo ""
        echo "=================================================="
        echo "✅ Deployment Successful!"
        echo "=================================================="
        echo ""
        echo "App URL: https://quoteapi-linux.azurewebsites.net/api/quotes"
        echo ""
        
        read -p "Destroy resources now? (y/n): " destroy
        if [ "$destroy" = "y" ]; then
            echo ""
            echo "=================================================="
            echo "🗑️  Step 6: Destroy Infrastructure"
            echo "=================================================="
            time make destroy
            echo ""
            echo "✅ All resources cleaned up!"
        else
            echo ""
            echo "⚠️  Resources are still running. Remember to destroy later:"
            echo "   make destroy"
        fi
        ;;
        
    2)
        echo ""
        echo "Deploying infrastructure..."
        make init
        make fmt
        make validate
        make plan
        make apply
        sleep 10
        make curl
        echo ""
        echo "✅ Deployment complete!"
        echo "App URL: https://quoteapi-linux.azurewebsites.net/api/quotes"
        ;;
        
    3)
        echo ""
        echo "Destroying infrastructure..."
        make destroy
        echo ""
        echo "✅ All resources destroyed"
        ;;
        
    4)
        echo ""
        echo "Testing API endpoint..."
        make curl
        ;;
        
    5)
        echo ""
        echo "Validating configuration..."
        make init
        make fmt
        make validate
        echo ""
        echo "✅ Configuration is valid"
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=================================================="
echo "🎉 Demo Complete!"
echo "=================================================="
