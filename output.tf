output "sfdc_bucket" { value = aws_s3_bucket.bucket.bucket }
output "sfdc_bucket_domain_name" { value = aws_s3_bucket.bucket.bucket_regional_domain_name }

output "trust_anchor_arn" { value = aws_rolesanywhere_trust_anchor.test.arn }
output "profile_arn" { value = aws_rolesanywhere_profile.test.arn }