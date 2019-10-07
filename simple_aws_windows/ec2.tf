#
# EC2
#
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_key_pair" "default" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(var.ssh_public_key_path)}"
}


#resource "aws_vpc" "pi_vpc" {
#  "vpc-0a81384fda4275cd2"
#  
#}
#resource "aws_iam_instance_profile" "pi_profile" {
#  name            = "pi.profile"
#  role            = var.host_role
#}



resource "aws_instance" "pi_windows" {
  # note AMI depends on region.
  # MS Windows Server 2019 Base for us-west-2, ebs, hvm, ENA
  # ami             = "ami-0e65e5829cd5a9dcd" # us-west-2
  ami                    = "ami-04203dd87d4abd6f6" # us-east-2
  instance_type          = "t2.large"
  vpc_security_group_ids = [aws_default_vpc.default.default_security_group_id]
#  vpc             = "default"

  key_name               = aws_key_pair.default.key_name
  iam_instance_profile   = aws_iam_instance_profile.pi_profile.name 

  # ebs_block_device {
  #   volume_size = 30 # GiB
  # }

  
  get_password_data      = true
  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${rsadecrypt(self.password_data,file(var.ssh_private_key_path))}"
    host     = "${self.public_ip}"
  }

  provisioner "file" {
    source      = "setup.ps1"
    destination = "C:/setup.ps1"    
  }
  
  provisioner "remote-exec" {
#    interpreter = ["PowerShell"]
    
    scripts = ["setup.ps1"]

  }
}



