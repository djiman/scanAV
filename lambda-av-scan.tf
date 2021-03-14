resource "aws_iam_role" "bucket_antivirus_scan" {
  depends_on = [
    aws_s3_bucket.av_definition
  ]

  name = var.av_scan_name
  assume_role_policy = file("${path.module}/templates/lambda-assume-role.json")
}

resource "aws_iam_role_policy" "av_scan" {
  name = var.av_scan_name
  role = aws_iam_role.bucket_antivirus_scan.id
  policy =   templatefile( 
      "${path.module}/templates/av-scan-policy.json", 
      {
        s3_targets = jsonencode( formatlist("arn:aws:s3:::%s/*", var.s3_targets) )
        bucket_av_definitions = aws_s3_bucket.av_definition.id
      }
    )
}

resource "aws_lambda_function" "av_scan" {
  depends_on = [
    aws_s3_bucket.av_definition
  ]

  filename      = "${path.module}/files/bucket-av-scan.zip"
  source_code_hash = filebase64sha256("${path.module}/files/bucket-av-scan.zip")
  function_name = var.av_scan_name
  role          = aws_iam_role.bucket_antivirus_scan.arn
  
  runtime = "python3.7"
  handler = "scan.lambda_handler"

  memory_size = 2048
  timeout = 300
  description = "Scan s3 buckets"

  environment {
    variables = {
      AV_DEFINITION_S3_BUCKET = aws_s3_bucket.av_definition.id
      AV_DELETE_INFECTED_FILES = true
    }
  }

  tags = local.common_tags
}
