resource "aws_ecr_repository" "this" {
  name = var.repo_name
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}
output "repo_url" { value = aws_ecr_repository.this.repository_url }
output "repo_arn" { value = aws_ecr_repository.this.arn }
