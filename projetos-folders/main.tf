terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# ------------------------------------------------------------------------------
# 0. VARIAVEIS E PROVEDOR
# ------------------------------------------------------------------------------
locals {
  org_id          = "organizations/540829645030"
  billing_account = "018973-A8340F-83D8E5"
}

provider "google" {
  region = "us-central1"
  zone   = "us-central1-c"
}

# ------------------------------------------------------------------------------
# 1. PASTAS DEPARTAMENTAIS
# ------------------------------------------------------------------------------
resource "google_folder" "operacoes" {
  display_name = "Operacoes"
  parent       = local.org_id
}

resource "google_folder" "administrativo" {
  display_name = "Administrativo"
  parent       = local.org_id
}

# ------------------------------------------------------------------------------
# 2. PASTAS DE SISTEMAS / PRODUTOS
# ------------------------------------------------------------------------------
resource "google_folder" "caixa_pdv" {
  display_name = "Caixa-PDV"
  parent       = google_folder.operacoes.name
}

resource "google_folder" "financeiro" {
  display_name = "Financeiro"
  parent       = google_folder.administrativo.name
}

# ------------------------------------------------------------------------------
# 3. PASTAS DE AMBIENTES
# ------------------------------------------------------------------------------
# Ambientes do Caixa-PDV
resource "google_folder" "pdv_dev" {
  display_name = "Desenvolvimento"
  parent       = google_folder.caixa_pdv.name
}

resource "google_folder" "pdv_prod" {
  display_name = "Producao"
  parent       = google_folder.caixa_pdv.name
}

# Ambientes do Financeiro
resource "google_folder" "fin_dev" {
  display_name = "Desenvolvimento"
  parent       = google_folder.financeiro.name
}

resource "google_folder" "fin_prod" {
  display_name = "Producao"
  parent       = google_folder.financeiro.name
}

# ------------------------------------------------------------------------------
# 4. PROJETOS GCP
# ------------------------------------------------------------------------------
# Projetos Caixa-PDV
resource "google_project" "pdv_dev" {
  name                = "prj-pdv-dev"
  project_id          = "mercado-pdv-dev"
  folder_id           = google_folder.pdv_dev.name
  auto_create_network = false
  billing_account     = local.billing_account
}

resource "google_project" "pdv_prod" {
  name                = "prj-pdv-prod"
  project_id          = "mercado-pdv-prod"
  folder_id           = google_folder.pdv_prod.name
  auto_create_network = false
  billing_account     = local.billing_account
}

# Projetos Financeiro
resource "google_project" "fin_dev" {
  name                = "prj-fin-dev"
  project_id          = "mercado-fin-dev"
  folder_id           = google_folder.fin_dev.name
  auto_create_network = false
  billing_account     = local.billing_account
}

resource "google_project" "fin_prod" {
  name                = "prj-fin-prod"
  project_id          = "mercado-fin-prod"
  folder_id           = google_folder.fin_prod.name
  auto_create_network = false
  billing_account     = local.billing_account
}

# ------------------------------------------------------------------------------
# 5. GESTAO DE ACESSOS
# ------------------------------------------------------------------------------
# Time de Devs PDV: permissão de Editor apenas na pasta de Desenvolvimento
resource "google_folder_iam_member" "devs_pdv" {
  folder = google_folder.pdv_dev.name
  role   = "roles/editor"
  member = "group:gcp-pdv-devs@mercadocentral.com"
}

# Time de Devs Financeiro: permissão de Editor apenas na pasta de Desenvolvimento
resource "google_folder_iam_member" "devs_fin" {
  folder = google_folder.fin_dev.name
  role   = "roles/editor"
  member = "group:gcp-fin-devs@mercadocentral.com"
}

# Time de Operações / SRE: permissão de Viewer nos ambientes de Produção
resource "google_folder_iam_member" "ops_pdv_prod" {
  folder = google_folder.pdv_prod.name
  role   = "roles/viewer"
  member = "group:gcp-store-ops@mercadocentral.com"
}

resource "google_folder_iam_member" "ops_fin_prod" {
  folder = google_folder.fin_prod.name
  role   = "roles/viewer"
  member = "group:gcp-fin-ops@mercadocentral.com"
}
