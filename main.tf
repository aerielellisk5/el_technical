terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    docker ={
        source = "kreuzwerker/docker"
        version = "2.16.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
#   shared_config_files      = ["path_to_config"]
  shared_credentials_files = ["~/.aws/credentials"]
#   gives access to my credentials
}

provider "docker" {
    # 
}

# create the AWS ECR Repo
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "gethecr"
  image_tag_mutability = "MUTABLE"
#   images can be overwritten
  force_delete = true
#   repository can be deleted even if there are images within them
  image_scanning_configuration {
    scan_on_push = true
    # checks for software vulnerabilities in container
  }
  lifecycle {
    prevent_destroy = false
    # this resource can be delete on destroy
  }
}

data "aws_caller_identity" "current" {}

# packaging the docker image
resource "null_resource" "docker_packaging" {
	
	  provisioner "local-exec" {
	    command = <<EOF
        #!/bin/bash
        
        # specifying that this is a bash script
	    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
        docker pull ethereum/client-go:stable
        imageID=`docker images -q ethereum/client-go:stable`


        #docker tag e9ae3c220b23 aws_account_id.dkr.ecr.us-west-2.amazonaws.com/my-repository:tag
        docker tag $imageID ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${aws_ecr_repository.ecr_repo.name}:stable
        # docker push aws_account_id.dkr.ecr.us-west-2.amazonaws.com/my-repository:tag
        docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${aws_ecr_repository.ecr_repo.name}:stable


        # docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/${aws_ecr_repository.ecr_repo.repository_url}
        # registry/repository
	    EOF
	  }
	

	  triggers = {
	    "run_at" = timestamp()
	  }
	

	  depends_on = [
	    aws_ecr_repository.ecr_repo,
	  ]
}

#Setting Up the EC2 Instance

#Creating an Policy to attach to the role
resource "aws_iam_policy" "ec2-access-ecr-policy" {
  name = "ecr-access-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "role" {
  name               = "ec2-access-ecr-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach" {
  name       = "ec3-ecr-attach"
  roles      = [aws_iam_role.role.name] 
  # policy_arn = "${aws_iam_policy.policy.arn}"
  policy_arn = aws_iam_policy.ec2-access-ecr-policy.arn
}

resource "aws_iam_instance_profile" "ec2-profile" {
  name = "ec2_to_ecr_profile"
  role = aws_iam_role.role.name
}

# resource "aws_instance" "example_instance" {
#   ami           = "ami-0e9107ed11be76fde"
#   instance_type = "t2.micro"
#   iam_instance_profile = aws_iam_instance_profile.ec2-profile.name

#   tags = {
#     Name = "gethinstnace"
#   }

# lifecycle {
#     # Reference the security group as a whole or individual attributes like `name`
#     replace_triggered_by = [aws_security_group.example]
#   }
# }

resource "aws_vpc" "geth_vpc" {
  cidr_block =  "10.0.0.0/16"
  tags = {
    name = "production_vpc"
  }
}

resource "aws_subnet" "geth_subnet1" {
  vpc_id = aws_vpc.geth_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    name = "geth_subnet1"
  }
}

resource "aws_security_group" "geth_connection" {
  name        = "geth_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.geth_vpc.id

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "geth_sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}