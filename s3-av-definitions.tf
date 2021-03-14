

resource "random_uuid" "s3_av_definitions" {
  #keepers = {}
}

resource "aws_s3_bucket" "av_definition" {
  bucket = var.s3_bucket_av_definitions_name == "" ? random_uuid.s3_av_definitions.result : var.s3_bucket_av_definitions_name
  acl    = "private"

  versioning {
    enabled = false
  }
}