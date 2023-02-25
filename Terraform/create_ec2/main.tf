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
