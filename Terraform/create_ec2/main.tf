module "create_sg" {
    source = "./modules/create_sg"
    sg_name = "allow_http"
}

module "create_pem" {
    source = "./modules/create_key"
    key_name = "Terra_key"
    key_path = "./keys/Terra_key.pem"
}

module "create_ec2" {
    source = "./modules/create_ec2"
    ec2_type = "t2.micro"
    pem_name = module.create_pem.pem_key
    sg_ec2_id = module.create_sg.sg_id
    pem_path = module.create_pem.pem_path
}

module "create_s3" {
    source = "./modules/create_s3"
    bucket_name = "s3-terraform-backend-27022023"
}

module "create_locking" {
    source = "./modules/create_dynamodb"
    hash_key = "LockID"
    dynamodb_name = "backend-s3-locking-table"
}

resource "null_resource" "name" {
    provisioner "local-exec" {
        command = "echo ${module.create_ec2.ec2_public_ip} > ec2_ip.txt"
    }
}

