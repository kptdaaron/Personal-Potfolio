terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 3.27"
        }
    }
    required_version = ">= 0.14.9"
}

# CREATING PROVIDER AND PROFILE

# provider lets terraform know which api to use.
# in our case provider is aws.
provider "aws" {
    profile = "default"
    region = "us-east-2"
}

## CREATING DEFAULT VPC

# this is default vpc in aws ,
# this niether be created during terraform apply and nor be destroyed during terraform destroy
# this the just for referncing attribute of default vpc
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Personal Portfolio"
  }
}


## CREATING VARIABLES

# key variable for referencing
variable "key_name" {
    default = "ec2Key"
}

#base_path for referencing
variable "base_path" {
    default = "/home/jactrajano/projects/Personal-Potfolio/"
}

## CREATING PRIVATE KEY AND KEY PAIR

# this will create a key with RSA algorithm with 4096 rsa bits
resource "tls_private_key" "private_key" {
    algorithm = "RSA"
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

## CREATING SECURITY GROUP

# this resource will create new security with specified inbound and outbound rules
resource "aws_security_group" "security_group" {
    name                    = "allow_tcp"
    description             = "Allow TCP inbound traffic"
    vpc_id                  = aws_default_vpc.default_vpc.id

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

## S3 BUCKET

# this resource will create an s3 bucket with name personal-portfolio
# this bucket will contain all our website static files

resource "aws_s3_bucket" "s3_bucket_jactrajano_portfolio" {
    bucket = "jactrajano-portfolio"

    tags = {
        Name = "static file as bucket"
    }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
    bucket = aws_s3_bucket.s3_bucket_jactrajano_portfolio.id
    acl = "private"
}

# here we are blocking all the public access to this bucket,
# we want the objects from this bucket to be accessible by via Cloudfround distribution

resource "aws_s3_bucket_public_access_block" "s3_block_access" {
    bucket = aws_s3_bucket.s3_bucket_jactrajano_portfolio.id
    block_public_acls = true
    block_public_policy = true
    restrict_public_buckets = true
    ignore_public_acls = true
}

# this will create an s3 origin id which wil be used in Cloudfront to set origin as s3 bucket
locals {
    s3_origin_id = "s3Origin"
}

## CREATING EC2 INSTANCE

# this resource will create an ec2 instance with specified specs
resource "aws_instance" "ec2_instance" {
    ami                 = "ami-0fa49cc9dc8d62c84"
    instance_type       = "t2.micro"
    key_name            = var.key_name
    security_groups     = [aws_security_group.security_group.name]
    tags = {
        Name = "Personal Website"
    }
}

## CREATING EBS VOLUME

# this resource will create an ebs volume with 1gb in size,
# we are creating this volume for persistent storage of critical data
resource "aws_ebs_volume" "ebs_volume" {
    availability_zone   = aws_instance.ec2_instance.availability_zone
    size                = 1
    tags = {
        Name = "ebsVolume"
    }
}

# this will attach the above created volume to ec2 instance at /dev/sdf
resource "aws_volume_attachment" "attach_volume" {
    device_name         = "/dev/sdf"
    volume_id           = aws_ebs_volume.ebs_volume.id
    instance_id         = aws_instance.ec2_instance.id
    # !! warning
    # dont use force detach and preserve this volume from destroying if using in production or,
    # if it contain important data
    # else you will lose your data
    force_detach = true
}


## CREATING NULL RESOURCE AND PROVISIONER

# provisioner to execute Ansible playbook
resource "null_resource" "configure_server" {

# execution in terraform has no sequence in execution, so if e.g. resource 3 is dependent on resource 1 & 2,
# we can use depends_on paramater to pass the list of resources on which a resource is dependent
    depends_on = [aws_instance.ec2_instance, aws_ebs_volume.ebs_volume, aws_volume_attachment.attach_volume]

    # provisioners are used to execute command on local or remote machine. Here we are using local-exec
    provisioner "local-exec" {

    # this command will be executed on local mahine and will change the persmission of key file which we saved previously
        command = "chmod 400 ${var.base_path}${var.key_name}.pem"
    }
    provisioner "local-exec" {
    # this command will connect to ec2 instance and run the playbook on that instance
    # ANSIBLE_HOST_KEY_CHECKING=False means it will not give warning for host authenticity,
    # else we have to manually pass yes on terminal
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user --private-key ${var.base_path}${var.key_name}.pem -i '${aws_instance.ec2_instance.public_ip},' playbook.yml"    
    }
}

## CloudFront Distribution

# origin access identity for distribution
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "cloudfront distribution identity"
}

# distribution
resource "aws_cloudfront_distribution" "distribution" {
    origin {
        # this is the domain name of s3 bucket which we created
        domain_name = aws_s3_bucket.s3_bucket_jactrajano_portfolio.bucket_regional_domain_name
        # here we are using that s3 origin id
        origin_id = local.s3_origin_id

        s3_origin_config {
            origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        }
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "cloudfront for static content"

    default_cache_behavior {
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = local.s3_origin_id

        forwarded_values {
            query_string = false
            
            cookies {
                forward = "none"
            }
        }

        # here we are defining to redirect http traffic to https
        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    # here we are defining geo_restriction as none
    # this is a very useful attribute. It can be used when we have to block content on a certain geographical region
    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }

    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

## UPDATING S3 BUCKET POLICY

# this section creates an s3 policy to allow distribution to read objects from bucket
data "aws_iam_policy_document" "s3_policy" {
    statement {
        actions     = ["s3:GetObject"]
        resources   = ["${aws_s3_bucket.s3_bucket_jactrajano_portfolio.arn}/*"]

        principals {
            type        = "AWS"
            identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
        }
    }

    statement {
        actions     = ["s3:ListBucket"]
        resources   = ["${aws_s3_bucket.s3_bucket_jactrajano_portfolio.arn}"]    

        principals {
            type        = "AWS"
            identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
        }
    }
}

# this will update bucket policy for the distribution we created above
resource "aws_s3_bucket_policy" "update_s3_policy" {
    bucket = aws_s3_bucket.s3_bucket_jactrajano_portfolio.id
    policy = data.aws_iam_policy_document.s3_policy.json
}

# instance ip
output "instance_ip" {
    value = aws_instance.ec2_instance.public_ip
}

# distribution id
output "distribution_domain" {
    value = aws_cloudfront_distribution.distribution.domain_name
}
