data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "targets" {
  for_each = local.s3_targets
  bucket = each.key    
}

resource "aws_s3_bucket_policy" "av_policy" {
  
  depends_on = [
    aws_s3_bucket.av_definition,
    aws_iam_role.bucket_antivirus_scan  
  ]

  for_each = local.s3_targets
  bucket = each.key    

  policy = templatefile( 
      "${path.module}/templates/s3-target-policy.json", 
      {
        s3_targets = jsonencode( formatlist("arn:aws:s3:::%s/*", var.s3_targets) )
        account_id = data.aws_caller_identity.current.account_id
        av_scan_role_name = aws_iam_role.bucket_antivirus_scan.id
        target_name = each.key
      }
    )
}

resource "aws_lambda_permission" "allow_bucket" {
  depends_on = [
      aws_lambda_function.av_scan
  ]

  for_each = local.s3_targets

  statement_id  = "AllowExecutionFromS3Bucket${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.av_scan.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.targets[each.key].arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  
  depends_on = [
      aws_lambda_function.av_scan
  ]

  for_each = local.s3_targets
  bucket = each.key   

  lambda_function {
    lambda_function_arn = aws_lambda_function.av_scan.arn
    events              = ["s3:ObjectCreated:*"]
  }

}