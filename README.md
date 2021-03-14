# s3-bucket-antivirus
## Overview
Implements a python solution using Claim Antivirus and architecture designed by ![upsidetravel team](https://github.com/upsidetravel). 

## Requirements
- ![terraform](https://www.terraform.io/downloads.html) v0.12.24 or later
- ![aws-cli](https://aws.amazon.com/cli/)

## Variables
| Variable | Description | Default | Required |
| --- | --- | --- | --- |
| s3_targets | A list of strings with the bucket names to be analized |  | Yes |
| project | Something to identify your resources. Could be project or organization name | "claim antivirus" | No |
| s3_bucket_av_definitions_name | The name of the bucket that will be created to save AntiVirus database and definitions. If the variable is not defined a random UUID will be used for the bucket name | Random UUID | No |
| av_scan_name | The prefix name to identify the resources created to scan the s3 buckets (lambda functions and iam roles and policies ) | av-scan | No |
| av_update_name | The prefix name to identify the resources created to update antivirus database (lambda functions and iam roles and policies ) | av-update | No |
| av_update_trigger | Cloudwatch trigger format to run lambda update functions in order to keep Claim antivirus up-to-date | "cron(0 0 * * ? *)" | No |
| enable_automatic_av_updates | Enable automatic updates for your antivirus | true | No |

## Usage
Configure your AWS credentials using aws-cli ( this is not required if your are using an instance with EC2 role attached to it) :

```
aws configure
```

Run terraform :
```
terraform init
terraform plan -var='s3_targets=[ "your_bucket_name", "another_bucket_to_analyze" ]' 
```
## Remote backend
In order to use s3 backend to save your terraform state for concurrent users, edit and configure ![backend.tf](/backend.tf) file with your bucket configuration.

## To Do

- Develop terraform code to configure SNS notifications automatically

