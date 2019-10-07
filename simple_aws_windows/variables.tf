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

variable "ssh_key_name" {
  type = string
  default = "id_rsa_2016_01_18"
}

variable "ssh_private_key_path" {
  type = string
  default = "~/.ssh/id_rsa_2016_01_18"
}

variable "ssh_public_key_path" {
  type = string
  default = "~/.ssh/id_rsa_2016_01_18.pub"
}


output "AdministratorPasswordEnc" {
  value = "${aws_instance.pi_windows.password_data}"
}
