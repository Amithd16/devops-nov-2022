# Generates a secure private key and encodes it in OpenSSH MD5 hash format
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

# Create a key-pair for ec2 
resource "aws_key_pair" "tf-key-pair" {
    key_name = var.key_name
    public_key = tls_private_key.rsa.public_key_openssh
}

# Save the pem file locally to login to ec2_instance
resource "local_file" "tf-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = var.key_path
}

