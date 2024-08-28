resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}"
  description = "${var.name}-${var.env}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.port_no
    to_port     = var.port_no
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = var.prometheus_servers
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


resource "aws_instance" "main" {
  ami           = data.aws_ami.ami.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

tags = {
Name = "${var.name}-${var.env}"
}
}

# this to not recreate machines when tf apply this will not needed when ASG auto scaling group
 lifecycle {
    ignore_changes ={
      "ami"
    }
 }

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.name}-${var.env}.saidevops79.online"
  type    = "A"
  ttl     = 30
  records = [aws_instance.main.private_ip]
}

resource "null_resource" "main" {
  depends_on = [aws_route53_record.main]
# if instance id changing then it will trigger, it will only for null resource
  triggers = {
    instance_id = aws_instance.main.id
  }

  connection {
    host     = aws_instance.main.private_ip
    user     = "ec2-user"
    password = "DevOps321"
    type     = "ssh"
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-pull -i localhost, -U https://github.com/bharadwaj9git/anisble_expense.git -e role_name=${var.name} -e env=${var.env} expense.yml"
    ]
  }
}

