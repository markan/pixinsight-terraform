#
#
# arn:aws:s3:::muking-astrophotography
variable "bucket" {
  type = string
  default = "muking-astrophotography"  
}

variable "region" {
  type = string
  default = "us-east-2"
}

variable "host_role" {
  type = string
  default = "HostBucketAccess_Careless"
}

variable "host_security_group" {
  type = string
  default = "launch-wizard-1"
}

#
# Note: Set up your .aws/credentials file, and set profile below to match your desired profile (may be default)
#
provider "aws" {
  profile = "Mark_Tools"
  region = var.region
}	

# IAM
#
# We need to set up some permissions
# 
data "aws_iam_policy_document" "pi_s3_access" {
  statement {
    sid = 1
    actions = [ "s3:*" ] 
    resources = [
      "arn:aws:s3:::${var.bucket}",
      "arn:aws:s3:::${var.bucket}/*"
    ]
  }
}

# handy for debug, run terraform refresh to see value
#output "pi_s3_access_policy_doc" {
#  value = "${data.aws_iam_policy_document.pi_s3_access.json}"
#}

resource "aws_iam_role_policy" "pi_s3_access" {
  name   = "pi_s3_access"
  role   = "${aws_iam_role.pi_role.id}"
  policy = "${data.aws_iam_policy_document.pi_s3_access.json}"
}

data "aws_iam_policy_document" "pi_s3_access_rel" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [ "s3.amazonaws.com" ]
    }
  }
}


#resource "aws_iam_policy" "pi_policy" {
#  name "pi_policy"
#  assume_role_policy = "${data.aws_iam_policy_document.pi_s3_access.json}"
#}

# This is what gives the instance rights on the s3 bucket
resource "aws_iam_role" "pi_role" {
  name = "pi_role"
  path = "/"
  assume_role_policy = "${data.aws_iam_policy_document.pi_s3_access_rel.json}"
}

resource "aws_iam_instance_profile" "pi_profile" {
  name = "pi_profile"
  role = "${aws_iam_role.pi_role.name}"
}
