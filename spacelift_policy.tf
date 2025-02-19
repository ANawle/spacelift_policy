terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "1.20.0"
    }
  }
}

provider "spacelift" {
  api_token = var.spacelift_api_token
}

variable "spacelift_api_token" {
  description = "API token for Spacelift"
  type        = string
  sensitive   = true
}

resource "spacelift_policy" "security_approval" {
  name        = "Require Security Approval for IAM Policy Changes"
  type        = "PLAN"
  body        = file("require_security_approval.rego")
  description = "Ensures that security team must approve any aws_iam_policy changes."
}

data "spacelift_stacks" "all_stacks" {}

resource "spacelift_policy_attachment" "attach_to_all_stacks" {
  for_each  = { for s in data.spacelift_stacks.all_stacks.stacks : s.id => s }
  policy_id = spacelift_policy.security_approval.id
  stack_id  = each.key
}
