output "ec2_public_ip" {
    value = module.create_ec2.ec2_public_ip
    sensitive = true
}
