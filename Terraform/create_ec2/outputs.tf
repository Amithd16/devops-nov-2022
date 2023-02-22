output "ec2_public_ip" {
    value = aws_instance.ec2_machine.public_ip
}

output "ami_id" {
    value = data.aws_ami.get_ami.id
}
