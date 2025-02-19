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

# Create a security policy that requires security team approval for changes to aws_iam_policy
resource "spacelift_policy" "security_approval" {
  name        = "Require Security Approval for IAM Policy Changes"
  type        = "PLAN"
  body        = file("require_security_approval.rego")
  description = "Ensures that security team must approve any aws_iam_policy changes."
}

# Data source to fetch all stacks from Spacelift
data "spacelift_stacks" "all_stacks" {}

# Attach the security approval policy to every stack
resource "spacelift_policy_attachment" "attach_to_all_stacks" {
  policy_id = spacelift_policy.security_approval.id
  stack_ids = [for stack in data.spacelift_stacks.all_stacks.stacks : stack.id]
}
