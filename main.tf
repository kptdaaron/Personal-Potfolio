terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }
    required_version = ">= 0.14.9"
}

# provider lets terraform know which api to use.
# in our case provider is aws.
provider "aws" {
    profile = "default"
    region = "us-east-1"
}

# this is default vpc in aws ,
# this niether be created during terraform apply and nor be destroyed during terraform destroy
# this the just for referncing attribute of default vpc
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Personal Portfolio"
  }
}

# resource "aws_instance" "personal_portfolio" {
#     ami = "ami-02cb75f995890cd96"
#     instance_type = "t2.micro"
# }

# key variable for referencing
variable "key_name" {
    default = "ec2Key"
}

#base_path for referencing
variable "base_path" {
    default = "/home/jactrajano/projects/Personal-Potfolio/"
}

# this will create a key with RSA algorithm with 4096 rsa bits
resource "tls_private_key" "private_key" {
    algorith = "RSA"
    rsa_bits = 4096
}

# this resource will create a key pair using above private key
resource "aws_key_pair" "key_pair" {
    key_name = var.key_name
    public_key = tls_private_key.private_key.public_key_openssh

    depends_on = [tls_private_key.private_key]
}

# this resource will save the private key at our specified path
resource "local_file" "save_key" {
    content = tls_private_key.private_key.private_key_pem
    filename = "${var.base_path}${var.key_name}.pem"
}

# this resource will create new security with specified inbound and outbound rules
resource "aws_security_group" "security_group" {
    name                    = "allow_tcp"
    description             = "Allow TCP inbound traffic"
    vpc_id                  = aws_default_vpc.default_vpc_id

    # creating inbound rule for tcp port 8080 to use Jenkins
    ingress {
        description         = "Allow Jenkins"
        from_port           = 8080
        to_port             = 8080
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    # creating inbound rule for tcp port 443 to allow https traffic
    ingress {
        description         = "Allow HTTPS"
        from_port           = 443
        to_port             = 443
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    #creating inbound rule for tcp port 80 to allow http traffic
    ingress {
        description         = "Allow HTTP"
        from_port           = 80
        to_port             = 80
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    # creating inbound rule for tcp port 22 to allow ssh into instance
    ingress {
        description         = "Allow SSH"
        from_port           = 22
        to_port             = 22
        protocol            = "tcp"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    # outbound rule to protocol -1 means all and port 0 means all
    egress {
        from_port           = 0
        to_port             = 0
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    tags = {
        Name = "allow_tcp"
    }
}

# this resource will create an ec2 instance with specified specs
resource "aws_instance" "ec2_instance" {
    ami                 = "ami-0022f774911c1d690"
    instance_type       = "t2.micro"
    key_name            = var.key_name
    security_groups     = [aws_security_group.security_group.name]
    tags = {
        Name = "webServer"
    }
}

# this resource will create an ebs volume with 1gb in size,
# we are creating this volume for persistent storage of critical data
resource "aws_ebs_volume "ebs_volume" {
    availability_zone   = aws_instance.ec2_instance.availability_zone
    size                = 1
    tags = {
        Name = "ebsVolume"
    }
}

# this will attach the above created volume to ec2 instance at /dev/sdf
resource "aws_volume_attachment" "attach_volume" {
    device_name         = "/dev/sdf"
    volume_id           = aws_ebs_volume.ebs_volume.vpc_id
    instance_id         = aws_instance.ec2_instance.id
    # !! warning
    # dont use force detach and preserve this volume from destroying if using in production or,
    # if it contain important data
    # else you will lose your data
    force_detach = true
}
