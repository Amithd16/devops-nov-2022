# variable "ami_id" {
#     description = "This is the ami id to create ec2 instance"
#     type = string 
#     default = "ami-0caf778a172362f1c"
# }

variable "ec2_type" {
    description = "This is the ami id to create ec2 instance"
    type = string 
    default = "t2.micro"
}

variable "pem_name" {
    description = "This is the ami id to create ec2 instance"
    type = string 
    default = "K8S-Master"
}
