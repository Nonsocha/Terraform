module "custom_vpc" {
  source        = "./modules/vpc"
  vpc_cidr_block = var.vpc_cidr_block
}

resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = module.custom_vpc.public_subnets[0]

  tags = {
    Name = "WebServerInstance"
  }
}
