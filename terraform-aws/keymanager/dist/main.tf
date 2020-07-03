provider "aws" {
  region = "us-east-1"
}

module "secret" {
  source = "../"

  name       = "ft-secret_uuid"
  value      = "password-policy-valid"
  policy     = data.template_file.centcom.rendered            # See: CentCom RegEx Policy
  kms_key_id = "arn:aws:kms:aws-region:account-id:key/key-id" # See: CentCom KMS Policy
  tags = {
    whodunnit = "centcom-aws"
    why       = "irp-2.2"
  }
}
