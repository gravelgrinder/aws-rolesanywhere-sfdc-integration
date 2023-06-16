# aws-rolesanywhere-sfdc-integration

Demonstration for how to leverage AWS RolesAnywhere to allow integration between Salesforce and S3.


## Architecture
![alt text](https://github.com/gravelgrinder/aws-rolesanywhere-sfdc-integration/blob/main/architecture_diagram.png?raw=true)

## Setup Steps
1. Run the following to Initialize the Terraform environment.

```
terraform init
```

2. Provision the resources in the Terraform scripts.  This will create the following...
    - Amazon S3 bucket
    - IAM profile
    - IAM role
    - Private Certificate Authority
    - CA Root Certificate
    - Roles Anywhere Trust Anchor
    - Roles Anywhere Profile
    The RolesAnywhere Profile will be linked to the `tf_sfdc_iam_role` IAM role.  That role's trust policy will limit the AssumeRole action to the Trust Anchor we created as well as the Certificate CN name = "Devin".
```
terraform apply
```

3. Create a CA Signed Certificate in Salesforce. Follow the steps in [this documentation](https://help.salesforce.com/s/articleView?id=sf.security_keys_uploading_signed_cert.htm&type=5).  NOTE: The "Common Name" field must match the conditional "CN" value in the IAM Trust relationship (see the `./IAM/SFDC_RolesAnywhere_Trust.json` policy file).  The current value is set to "Devin", change this as necessary.

4. Create the Signing Request.  Replace the parameters accordingly.  This includes the CA Arn and Certificate Signing Request (`.csr` file downloaded from SFDC).  The signing algorithm and validity can be changed to your requirements if needed. 
```
aws acm-pca issue-certificate \
    --certificate-authority-arn ${CA_ARN) \
    --csr fileb:///Users/lwdvin/Downloads/S3_Demo_Cert.csr \
    --signing-algorithm SHA256WITHRSA \
    --validity "Value=180,Type=DAYS"
```

5. Get the Certificate from the CA. Use the "CertificateArn" in step #4 to populate the `--certificate-arn` value.
```
aws acm-pca get-certificate \
    --certificate-authority-arn ${CA_ARN) \
    --certificate-arn ${CERT_ARN} \
    --output text
```

6. Upload the Signed Certificate to Salesforce.

7. Setup the External Credential to the S3 service using "Roles Anywhere" credential type.

8. Setup the Named Credentials.  Authenticate with the External Credential you defined in Step #7 and the Client Certificate you uploaded in step #6.

9. Make sure the currenty Salesforce user has access to the Named Credential.

10. Debug the call to S3 using the Developer Console.
![Code snippit to call S3](https://github.com/gravelgrinder/aws-rolesanywhere-sfdc-integration/blob/main/Pictures/ApexCodeDebug.png?raw=true)
![Code snippit to call S3](https://github.com/gravelgrinder/aws-rolesanywhere-sfdc-integration/blob/main/Pictures/ApexResults.png?raw=true)


## Helpful Links
  - [S3 Bucket Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
  - [Youtube: Best Practices for Integrating and Securing Salesforce Data with AWS](https://www.youtube.com/watch?v=kVmdCuRcpAg)
  - [Youtube: IAM Roles Anywhere](https://www.youtube.com/watch?v=DOH37VVadlc)
  - [SFDC Docs: Use AWS Roles Anywhere with Named Credentials](https://help.salesforce.com/s/articleView?id=release-notes.rn_security_other_nc_roles_anywhere.htm&release=242&type=5)
  - [SFDC Docs: Authentication Protocols for Named Credentials](https://help.salesforce.com/s/articleView?id=sf.nc_auth_protocols.htm&type=5)
  - [SFDC Docs: AWS Sig v4 External Credential](https://help.salesforce.com/s/articleView?id=sf.nc_create_edit_awssig4_ext_cred.htm&type=5)
  - [AWS User Guide: Trust model in AWS IAM Roles Anywhere](https://docs.aws.amazon.com/rolesanywhere/latest/userguide/trust-model.html)
  - [AWS CLI Command Reference: aws acm-pca issue-certificate](https://docs.aws.amazon.com/cli/latest/reference/acm-pca/issue-certificate.html)
  - [AWS CLI Command Reference: aws acm-pca get-certificate](https://docs.aws.amazon.com/cli/latest/reference/acm-pca/get-certificate.html)
  