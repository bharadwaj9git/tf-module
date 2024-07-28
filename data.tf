data "aws_route53_zone" "main"{
  name = "saidevops79.online"
  private_zone=false
}

data "aws_ami" "ami" {
  most_recent      = true
  name_regex       = "golden-ami"
  owners           = ["self"]
}

