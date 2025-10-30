data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["ec2.amazonaws.com"] }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "${var.name_prefix}-ec2-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version="2012-10-17",
    Statement=[
      { "Effect":"Allow", "Action":[
          "ecr:GetAuthorizationToken","ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer","ecr:BatchGetImage"
        ], "Resource":"*" },
      { "Effect":"Allow", "Action":[ "logs:CreateLogStream","logs:PutLogEvents","logs:CreateLogGroup" ], "Resource":"*" },
      { "Effect":"Allow", "Action":["s3:GetObject"], "Resource":["${var.s3_bucket_arn}/*"] }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

output "instance_profile" { value = aws_iam_instance_profile.ec2_profile.name }
output "role_name"        { value = aws_iam_role.ec2_role.name }
