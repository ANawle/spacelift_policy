package spacelift

default allow = false

# Allow changes if the security team has approved
allow {
  input.request.changeset.approved_by_security_team
}

# Require approval if the change includes aws_iam_policy
deny[msg] {
  some change in input.request.changeset.resources
  change.type == "aws_iam_policy"
  not input.request.changeset.approved_by_security_team
  msg := "Security team approval is required for aws_iam_policy modifications."
}
