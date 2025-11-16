terraform {
  required_providers {
    supabase = {
      source  = "supabase/supabase"
      version = "~> 1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

variable "supabase_api_key" {
  default = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6Ynp0cnV6cm95cWx2ZmhheXJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI4OTAxNTgsImV4cCI6MjA3ODQ2NjE1OH0.xjcXC5GNNzxFBlE41kDK9F1eeaol6-AyrYiF2gRf1Yg"
}

variable "supabase_project_id" {
  default = "hzbztruzroyqlvfhayrd"
}

variable "supabase_url" {
  default = "https://hzbztruzroyqlvfhayrd.supabase.co"
}

variable "gcp_project_id" {
  default = "ditttto-daas-mvp"
}

variable "admin_email" {
  default = "dev@thiccrobot.com"
}

# Supabase Provider
provider "supabase" {
  api_key = var.supabase_api_key
}

# GCP Provider
provider "google" {
  project = var.gcp_project_id
}

# ============================================
# SUPABASE DATABASE SCHEMA
# ============================================

resource "supabase_database_schema" "ditttto_schema" {
  project_id = var.supabase_project_id
  
  # Users table
  sql = <<-SQL
    CREATE TABLE IF NOT EXISTS public.users (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      email VARCHAR(255) UNIQUE NOT NULL,
      name VARCHAR(255),
      role VARCHAR(50) DEFAULT 'user',
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS public.chat_history (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
      message TEXT NOT NULL,
      role VARCHAR(50) NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS public.files (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
      file_name VARCHAR(255) NOT NULL,
      file_path VARCHAR(512) NOT NULL,
      file_size BIGINT,
      mime_type VARCHAR(100),
      created_at TIMESTAMP DEFAULT NOW()
    );

    CREATE TABLE IF NOT EXISTS public.agent_sessions (
      id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
      user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
      session_data JSONB,
      status VARCHAR(50) DEFAULT 'active',
      created_at TIMESTAMP DEFAULT NOW(),
      updated_at TIMESTAMP DEFAULT NOW()
    );

    -- Enable RLS
    ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;
    ALTER TABLE public.agent_sessions ENABLE ROW LEVEL SECURITY;

    -- RLS Policies
    CREATE POLICY "Users can view own data" ON public.users
      FOR SELECT USING (auth.uid() = id);
    
    CREATE POLICY "Users can view own chat" ON public.chat_history
      FOR SELECT USING (auth.uid() = user_id);
    
    CREATE POLICY "Users can insert own chat" ON public.chat_history
      FOR INSERT WITH CHECK (auth.uid() = user_id);
  SQL
}

# ============================================
# GCP GOOGLE AUTH SETUP
# ============================================

resource "google_service_account" "ditttto_auth" {
  account_id   = "ditttto-auth"
  display_name = "ditttto™ Authentication Service"
}

resource "google_service_account_key" "ditttto_auth_key" {
  service_account_id = google_service_account.ditttto_auth.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_identity_platform_config" "ditttto_config" {
  project = var.gcp_project_id
  
  sign_in {
    allow_duplicate_emails = false
  }

  authorized_domains {
    domain = "thiccrobot.com"
  }

  authorized_domains {
    domain = "localhost"
  }
}

# Admin user
resource "google_identity_platform_tenant_inbound_saml_config" "admin_saml" {
  project = var.gcp_project_id
  name    = "admin-saml"
  
  display_name = "Admin SAML Config"
  enabled      = true
  
  idp_entity_id = "admin-idp"
  
  sso_url = "https://accounts.google.com/o/saml2/initsso"
  
  x509_certificates = [
    google_service_account_key.ditttto_auth_key.public_key
  ]
}

# ============================================
# CLOUD STORAGE
# ============================================

resource "google_storage_bucket" "ditttto_storage" {
  name          = "ditttto-daas-mvp-${var.gcp_project_id}"
  location      = "US"
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}

resource "google_storage_bucket_iam_member" "ditttto_storage_access" {
  bucket = google_storage_bucket.ditttto_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.ditttto_auth.email}"
}

# ============================================
# CLOUD RUN DEPLOYMENT
# ============================================

resource "google_cloud_run_service" "ditttto_app" {
  name     = "ditttto-daas-mvp"
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.ditttto_auth.email

      containers {
        image = "gcr.io/${var.gcp_project_id}/ditttto-mvp:latest"

        env {
          name  = "SUPABASE_URL"
          value = var.supabase_url
        }

        env {
          name  = "SUPABASE_API_KEY"
          value = var.supabase_api_key
        }

        env {
          name  = "ADMIN_EMAIL"
          value = var.admin_email
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.gcp_project_id
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "ditttto_public" {
  service  = google_cloud_run_service.ditttto_app.name
  location = google_cloud_run_service.ditttto_app.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ============================================
# OUTPUTS
# ============================================

output "supabase_url" {
  value = var.supabase_url
}

output "supabase_project_id" {
  value = var.supabase_project_id
}

output "gcp_project_id" {
  value = var.gcp_project_id
}

output "admin_email" {
  value = var.admin_email
}

output "cloud_run_url" {
  value = google_cloud_run_service.ditttto_app.status[0].url
}

output "storage_bucket" {
  value = google_storage_bucket.ditttto_storage.name
}

output "service_account_email" {
  value = google_service_account.ditttto_auth.email
}
