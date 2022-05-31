variable "role_name" {
  type        = string
  description = "Role Name"
}
variable "service" {
  type        = string
  description = "Role Name"
}
variable "role_description" {
  type        = string
  description = "Role Description"
}
variable "attach_to" {
  type        = list(string)
  description = "A list of policy ARNs to attach the role to"
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = var.role_description
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : var.service
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_vpc_policy" {
  for_each   = toset(var.attach_to)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "role_id" {
  value = aws_iam_role.this.id
}

output "role_arn" {
  value = aws_iam_role.this.arn
}