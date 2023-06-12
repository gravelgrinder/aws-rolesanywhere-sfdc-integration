###############################################################################
### Create a Roles Anywhere Trust Anchor
###############################################################################
resource "aws_rolesanywhere_trust_anchor" "test" {
  name = "example"
  source {
    source_data {
      acm_pca_arn = aws_acmpca_certificate_authority.example.arn
    }
    source_type = "AWS_ACM_PCA"
  }
  enabled = true
  # Wait for the ACMPCA to be ready to receive requests before setting up the trust anchor
  depends_on = [aws_acmpca_certificate_authority_certificate.example]
}
###############################################################################



###############################################################################
### Create a Roles Anywhere Profile
###############################################################################
resource "aws_rolesanywhere_profile" "test" {
  name      = "example"
  role_arns = [aws_iam_role.sfdc_user_role.arn]
  enabled = true
}
###############################################################################