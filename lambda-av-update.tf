resource "aws_cloudwatch_event_rule" "av_update" {
  name        = var.av_update_name
  description = "Update AntiVirus"
  #Updates AV every day
  schedule_expression= var.av_update_trigger
  is_enabled = var.enable_automatic_av_updates
  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "av_update" {
  rule      = aws_cloudwatch_event_rule.av_update.name
  target_id = "UpdateAntiVirus${var.av_update_name}"
  arn       = aws_lambda_function.av_update.arn
}

resource "aws_iam_role" "bucket_antivirus_update" {
  depends_on = [
    aws_s3_bucket.av_definition
  ]

  name = var.av_update_name
  assume_role_policy = file("${path.module}/templates/lambda-assume-role.json")
}

resource "aws_iam_role_policy" "av_update" {
  name = var.av_update_name
  role = aws_iam_role.bucket_antivirus_update.id
  policy =   templatefile( 
      "${path.module}/templates/av-update-policy.json", 
      {
        bucket_av_definitions = aws_s3_bucket.av_definition.id
      }
    )
}

resource "aws_lambda_function" "av_update" {
  depends_on = [
    aws_s3_bucket.av_definition
  ]

  filename      = "${path.module}/files/bucket-av-update.zip"
  source_code_hash = filebase64sha256("${path.module}/files/bucket-av-update.zip")
  function_name = var.av_update_name
  role          = aws_iam_role.bucket_antivirus_update.arn
  
  runtime = "python3.7"
  handler = "update.lambda_handler"

  memory_size = 2048
  timeout = 300
  description = "Updates Anti-Virus database"

  environment {
    variables = {
      AV_DEFINITION_S3_BUCKET = aws_s3_bucket.av_definition.id
    }
  }

  tags = local.common_tags
}
