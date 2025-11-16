#!/bin/bash

# ditttto™ DaaS MVP - Terraform Deployment Script
# Supports: init, plan, apply, destroy

set -e

PROJECT_ID="ditttto-daas-mvp"
ADMIN_EMAIL="dev@thiccrobot.com"
TF_DIR="./terraform"

echo "🚀 ditttto™ DaaS MVP - Deployment Script"
echo "=========================================="

# Command: init
if [ "$1" = "init" ]; then
  echo "📦 Initializing Terraform..."
  cd $TF_DIR
  terraform init
  cd ..
  echo "✅ Terraform initialized"

# Command: plan
elif [ "$1" = "plan" ]; then
  echo "📋 Planning deployment..."
  cd $TF_DIR
  terraform plan -out=tfplan
  cd ..
  echo "✅ Plan saved to tfplan"

# Command: apply
elif [ "$1" = "apply" ]; then
  echo "🔨 Applying infrastructure..."
  cd $TF_DIR
  terraform apply tfplan
  cd ..
  echo "✅ Infrastructure deployed"
  echo ""
  echo "📊 Deployment Summary:"
  cd $TF_DIR
  terraform output
  cd ..

# Command: persist
elif [ "$1" = "persist" ]; then
  echo "💾 Persisting state..."
  cd $TF_DIR
  terraform state pull > ../terraform.state.backup
  cd ..
  echo "✅ State backed up to terraform.state.backup"

# Command: destroy
elif [ "$1" = "destroy" ]; then
  echo "⚠️  WARNING: This will destroy all infrastructure!"
  read -p "Type 'yes' to confirm: " confirm
  if [ "$confirm" = "yes" ]; then
    echo "🗑️  Destroying infrastructure..."
    cd $TF_DIR
    terraform destroy -auto-approve
    cd ..
    echo "✅ Infrastructure destroyed"
  else
    echo "❌ Cancelled"
  fi

# Command: status
elif [ "$1" = "status" ]; then
  echo "📊 Current Infrastructure Status:"
  cd $TF_DIR
  terraform output
  cd ..

else
  echo "Usage: ./scripts/deploy.sh [command]"
  echo ""
  echo "Commands:"
  echo "  init      - Initialize Terraform"
  echo "  plan      - Plan deployment"
  echo "  apply     - Apply infrastructure"
  echo "  persist   - Backup state"
  echo "  destroy   - Destroy infrastructure"
  echo "  status    - Show current status"
  echo ""
  echo "Example workflow:"
  echo "  ./scripts/deploy.sh init"
  echo "  ./scripts/deploy.sh plan"
  echo "  ./scripts/deploy.sh apply"
fi
