resource "aws_instance" "ec2_machine" {
    ami = data.aws_ami.get_ami.id
    instance_type = "${var.ec2_type}"
    key_name = var.pem_name
    tags = {
        Name = "Terra EC2"
    }
}

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


