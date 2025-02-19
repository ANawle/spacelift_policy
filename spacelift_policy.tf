resource "spacelift_policy" "security_approval" {
  name        = "Require Security Approval for IAM Policy Changes"
  type        = "PLAN"
  body        = file("spacelift-policies/require_security_approval.rego")
  description = "Ensures that security team must approve any aws_iam_policy changes."
}

resource "spacelift_policy_attachment" "attach_to_all_stacks" {
  policy_id = spacelift_policy.security_approval.id
  stack_ids = [for stack in data.spacelift_stacks.all_stacks.stacks : stack.id]
}

data "spacelift_stacks" "all_stacks" {}
