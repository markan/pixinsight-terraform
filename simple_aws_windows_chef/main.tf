#
# See https://gist.github.com/irvingpop/b7bc6d1684df6975de3e7eeb73d83e4e for inspiration
#
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

data "template_file" "dna" {
  template = "${file("dna.json.tpl")}"

  vars {
    attribute1 = "value1"
    attribute2 = "value2"
    recipe = "mycookbook::default"
  }
}

resource "null_resource" "berks_package" {
  # assuming this is run from a cookbook/terraform directory
  provisioner "local-exec" {
    command = "rm -f ${path.module}/cookbooks.tar.gz ; berks package ${path.module}/cookbooks.tar.gz --berksfile=../Berksfile"
  }
}

# resource "aws_iam_role" "pi_role" {
#   name = "test_role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF

#   tags = {
#     tag-key = "tag-value"
#   }
# }

#resource "iam_instance_profile" "pi_instance_profile" {
#  
#}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_key_pair" "default" {
  key_name   = "id_rsa_2016_01_18"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNz1FOktd9ps6bCZWU+tbeIVcFeWfjbW0UfBN596IO/+RULRBi3HSy1BgS9FhGgeHBvCfIbHuyJh5Nuw/hDEM4LzbJ8JOh5Gfevc3YhKkdk/n3rb4Tj8nFK8Q7XIDSGOEPtZKZw/OyqfPmzwsMWbgZH5HRlR/M2ppZn1OeEyBt78Vf4KQxNbYfD/RSz7eQP78+RcFuX6a9wMLxMO83/M05LHGuG145CLtG+jH0fFgwo2fadrMFV3Uda1oIEAml8FVhpNvPSsFxHwJL1sdR4159hb7iw+mPu1HUHXye3VGtaSiHUnv88iP8eisoL62OAOHop+GC7rQ02WmOMHcDSkTfvfRUHk1bskBITo7Mc6ggGxAIsQVI56eT79xjgqCzckfCpNZkVvLeoyPmQVhvkw8tZ0VSX3aP07FyJig8RYjzB+MZ2ij5SZNhEupMn/5XXqFIRcPt6Fb7dyrNcoh6Nnxwo0VmVWoxFG4iEgXv3jHAL4JSv2RDsIxI0qsLMIprmP8= mark@alecto.local"
}


#resource "aws_vpc" "pi_vpc" {
#  "vpc-0a81384fda4275cd2"
#  
#}

resource "aws_instance" "pi_windows" {
  # note AMI depends on region.
  # MS Windows Server 2019 Base for us-west-2, ebs, hvm, ENA
  # ami             = "ami-0e65e5829cd5a9dcd" # us-west-2
  ami             = "ami-04203dd87d4abd6f6" # us-east-2
  instance_type   = "t2.large"
  vpc_security_group_ids = [aws_default_vpc.default.default_security_group_id]
#  vpc             = "default"
  role           = var.host_role
  key_name        = aws_key_pair.default.key_name

  
  # ebs_block_device {
  #   volume_size = 30 # GiB
  # }

  provisioner "remote-exec" {
    attributes_json = <<EOF
      {
        "key": "value",
        "app": {
          "cluster1": {
            "nodes": [
              "webserver1",
              "webserver2"
            ]
          }
        }
      }
    EOF

    environment     = "_default"
    client_options  = ["chef_license 'accept'"]
    run_list        = ["cookbook::recipe"]
    node_name       = "webserver1"
    secret_key      = "${file("../encrypted_data_bag_secret")}"
    server_url      = "https://chef.company.com/organizations/org1"
    recreate_client = true
    user_name       = "bork"
    user_key        = "${file("../bork.pem")}"
    version         = "12.4.1"

  }
  
}



