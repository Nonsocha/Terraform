
Here's a detailed Terraform script to create an EC2 instance within a custom VPC using the module method. The configuration is broken into separate files for better modularity and organization. Each section is explained in detail.

### Root main.tf
   This file calls the VPC module and provisions an EC2 instance.

```
provider "aws" {
  region = var.aws_region
}

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
```

### Root variables.tf
Define input variables for the root module.

```
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Example Ubuntu AMI
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}
```
### Root outputs.tf
Outputs the EC2 instance public IP and VPC ID.

```
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web_server.public_ip
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.custom_vpc.vpc_id
}
```

### Module vpc/main.tf
This file defines the resources to create a custom VPC, subnets, and an internet gateway.

```
resource "aws_vpc" "custom" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CustomVPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "CustomVPC-IGW"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = 2
  vpc_id            = aws_vpc.custom.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 4, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom.id

  tags = {
    Name = "CustomVPC-Public-RouteTable"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}
```

### Module vpc/variables.tf
Define input variables for the VPC module.

```
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
Module vpc/outputs.tf
Define outputs for the VPC module.

hcl
Copy code
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom.id
}
```

```
output "public_subnets" {
  description = "IDs of public subnets"
  value       = aws_subnet.public_subnets[*].id
}
```
### Steps to Deploy
### 1 Initialize the Terraform project:

```
terraform init
```

### 2 Review the execution plan:

```
terraform plan
```
### 3 Apply the configuration:
```
terraform apply
```
### 4 Verify Outputs:

The public IP of the EC2 instance and the VPC ID will be displayed as outputs.