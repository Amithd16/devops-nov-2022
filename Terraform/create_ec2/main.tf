resource "aws_instance" "ec2_machine" {
    ami = "ami-0caf778a172362f1c"
    instance_type = "t2.micro"
    key_name = "K8S-Master"
    count = 4
    tags = {
        Name = "Terra EC2"
    }
}