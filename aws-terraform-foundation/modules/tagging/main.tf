resource "aws_organizations_policy" "tag_policy" {
  name = "FinTechTagPolicy"
  type = "TAG_POLICY"

  content = jsonencode({
    tags = {
      Environment = {
        tag_key = { "@@assign" = "Environment" }
        tag_value = {
          "@@assign" = ["Production", "Staging", "Development", "Sandbox"]
        }
      }
      Project = {
        tag_key = { "@@assign" = "Project" }
      }
      CostCenter = {
        tag_key = { "@@assign" = "CostCenter" }
        tag_value = { "@@assign" = ["CC-*"] }
      }
    }
  })
}
