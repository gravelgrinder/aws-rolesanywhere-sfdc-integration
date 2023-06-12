output "sfdc_bucket" { value = aws_s3_bucket.bucket.bucket }
output "sfdc_bucket_domain_name" { value = aws_s3_bucket.bucket.bucket_regional_domain_name }

output "trust_anchor_arn" { value = aws_rolesanywhere_trust_anchor.test.arn }
output "profile_arn" { value = aws_rolesanywhere_profile.test.arn }

#output "sfdc_username" { value = aws_iam_user.sfdc_user.name }
#output "sfdc_user_id" { 
#    value = aws_iam_access_key.sfdc_user.id
#}
#output "sfdc_user_secret" { 
#    value = nonsensitive(aws_iam_access_key.sfdc_user.secret)
#}

### aws configure set aws_access_key_id     AKIAY57HXHWI5LASJQ7K                     --profile sfdc_s3
### aws configure set aws_secret_access_key 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 --profile sfdc_s3
### aws configure set region                us-east-1                                --profile sfdc_s3
### aws configure set output                json                                     --profile sfdc_s3