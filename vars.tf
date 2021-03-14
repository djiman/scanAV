locals{

    s3_targets = { 
        for bucket in var.s3_targets : bucket => bucket 
    }

    common_tags = {
        terraform = "true",
        project = var.project
    }
}

variable s3_targets {
    type = list(string)
    description = "Required. A list of s3 buckets to be analized."
}

variable project {
    description = "project or organization name"
    default = "clamAv antivirus"
}

variable s3_bucket_av_definitions_name {
    default = "av-definition-tf"
    description = "S3 bucket has to be created to save av definitions. A random name will be assigned to your bucket if this variable is not defined."
}


variable av_scan_name {
    default = "av-scan"
}

variable av_update_name {
    default = "av-update"
}

variable av_update_trigger {
    default = "cron(0 0/3 * * ? *)"
}

variable enable_automatic_av_updates {
    default = true
    description = "Enable cloudwatch rule to update AV database using cloudwatch rule"
}