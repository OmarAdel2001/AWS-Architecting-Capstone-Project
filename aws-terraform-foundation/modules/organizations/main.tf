# Get current organization
data "aws_organizations_organization" "org" {}

# ===================================
# IMPORT existing DenyRoot SCP
# ===================================

resource "aws_organizations_policy" "deny_root" {
  name = "DenyRootUserAccess"
  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyRootUser"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })

  lifecycle {
    prevent_destroy = true
  }
}



locals {
  root_id = data.aws_organizations_organization.org.roots[0].id
}

# ===============================
# Organizational Units (OUs)
# ===============================

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = local.root_id
}

resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "staging" {
  name      = "Staging"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads.id
}

# ===============================
# Attach EXISTING policies
# (DO NOT recreate them)
# ===============================

# Attach DenyRoot SCP (already exists: p-pwqsja4e)
resource "aws_organizations_policy_attachment" "attach_root" {
  policy_id = "p-pwqsja4e"
  target_id = local.root_id
}

# Attach Tag Policy (already exists: p-95zoe7m4il)
resource "aws_organizations_policy_attachment" "attach_tag_policy" {
  policy_id = "p-95zoe7m4il"
  target_id = local.root_id
}
