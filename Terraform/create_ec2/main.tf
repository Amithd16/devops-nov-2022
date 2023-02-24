data "aws_ami" "get_ami" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_instance" "ec2_machine" {
    ami = data.aws_ami.get_ami.id
    instance_type = "${var.ec2_type}"
    key_name = var.pem_name
    vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]
    tags = {
        Name = "Terra EC2"
    }

    connection {
      type = "ssh"
      user = "ubuntu"
      agent = false
      host = "${aws_instance.ec2_machine.public_ip}"
      private_key = file("keys/K8S-Master.pem")
    }

    provisioner "remote-exec" {
        inline = [
          "sudo apt update",
          "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
          "sudo mkdir -m 0755 -p /etc/apt/keyrings",
          "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
          "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
          "sudo apt-get update",
          "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
        ]
    }
    
}    

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}





