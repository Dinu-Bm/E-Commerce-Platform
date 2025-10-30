resource "random_string" "suffix" {
  length = 6
  special = false
  upper = false
}
resource "aws_s3_bucket" "this" {
  bucket = "${var.name_prefix}-assets-${random_string.suffix.result}"
  force_destroy = true
}
output "bucket_name" { value = aws_s3_bucket.this.bucket }
output "bucket_arn"  { value = aws_s3_bucket.this.arn }
