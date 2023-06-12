### Consumer Account Resources
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}




###############################################################################
### Create S3 Buckets
###############################################################################
resource "aws_s3_bucket" "bucket" {
  bucket = "tf-djl-private-bucket"
  force_destroy = true

  tags = {
      Name        = "tf-djl-private-bucket"
      Environment = "DEV"
  }
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id      = "expire_version"
    filter {
      prefix = ""
    }
    expiration {days = 1}
    noncurrent_version_expiration {noncurrent_days = 1}
    abort_incomplete_multipart_upload { days_after_initiation = 1 }
    status = "Enabled"
  }

  

  rule {
    id      = "delete_version"
    filter {
      prefix = ""
    }
    expiration {expired_object_delete_marker = true}
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}
###############################################################################


###############################################################################
### IAM Resources (User, Policy and Key)
###############################################################################
## Create IAM Policy for SFDC service account
data "template_file" "iam_policy" {
  #template = "${file("IAM/SFDC_User_Policy_Write_Only.json")}"
  template = "${file("IAM/SFDC_User_Policy_Read_Write.json")}"

  vars = { bucket_name = "${aws_s3_bucket.bucket.bucket}"}
}

data "template_file" "iam_trust_policy" {
  template = "${file("IAM/SFDC_RolesAnywhere_Trust.json")}"

  vars = { trust_anchor_arn = "${aws_rolesanywhere_trust_anchor.test.arn}"}
}

resource "aws_iam_policy" "sfdc_user" {
  name        = "tf_sfdc_iam_policy"
  description = "IAM Policy to allow the PUT operations on S3 bucket."
  policy      = "${data.template_file.iam_policy.rendered}"
}

resource "aws_iam_role" "sfdc_user_role" {
  name                = "tf_sfdc_iam_role"
  assume_role_policy  = "${data.template_file.iam_trust_policy.rendered}"
  managed_policy_arns = [aws_iam_policy.sfdc_user.arn]
}


### REMOVED AS WE ARE USING ROLESANYWHERE ### Create IAM User
### REMOVED AS WE ARE USING ROLESANYWHERE resource "aws_iam_user" "sfdc_user" {
### REMOVED AS WE ARE USING ROLESANYWHERE   name     = "tf-sfdc-user"
### REMOVED AS WE ARE USING ROLESANYWHERE }
### REMOVED AS WE ARE USING ROLESANYWHERE 
### REMOVED AS WE ARE USING ROLESANYWHERE ### Attach Policy to user
### REMOVED AS WE ARE USING ROLESANYWHERE resource "aws_iam_user_policy_attachment" "sfdc_user" {
### REMOVED AS WE ARE USING ROLESANYWHERE   user       = aws_iam_user.sfdc_user.name
### REMOVED AS WE ARE USING ROLESANYWHERE   policy_arn = aws_iam_policy.sfdc_user.arn
### REMOVED AS WE ARE USING ROLESANYWHERE }
### REMOVED AS WE ARE USING ROLESANYWHERE 
### REMOVED AS WE ARE USING ROLESANYWHERE resource "aws_iam_access_key" "sfdc_user" {
### REMOVED AS WE ARE USING ROLESANYWHERE   user     = aws_iam_user.sfdc_user.name
### REMOVED AS WE ARE USING ROLESANYWHERE }
###############################################################################