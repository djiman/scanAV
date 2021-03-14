terraform {
  required_version = "> 0.12.0"

  # Uncomment and configure remote backend bucket configuration
  # backend "s3" {
  #  bucket = "your-backend-bucket-here"
  #  region = "us-west-2"
  #  key    = "backend/antivirus"
  # }
}
