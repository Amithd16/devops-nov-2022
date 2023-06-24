output "pem_key" {
    value = aws_key_pair.tf-key-pair.key_name
}

output "pem_path" {
    value = local_file.tf-key.filename
}