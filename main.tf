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



# resource "docker_image" "GETH_stable" {
#     name = "ethereum/client-go:stable"
# }












# VPC 
# resource "aws_instance" "foodmenu_app" {
#   ami           = "ami-069d73f3235b535bd"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "HelloWorld"
#   }
# }


# resource "aws_vpc" "foodmenu_vpc" {
#   cidr_block =  "10.0.0.0/16"
#   tags = {
#     name = "production_vpc"
#   }
# }

# resource "aws_subnet" "foodmenu_subnet1" {
#   vpc_id = "aws_vpc.foodmenu_vpc"
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-2a"
#   tags = {
#     name = "foodmenu_subnet1"
#   }
# }


# command = <<EOF
#         # loging to aws ecr and then also login to docker with an access token
# 	    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com
        
#         # doubt I need this gradle thing
# 	    # gradle build -p noiselesstech
        
#         #pull the stable build from dockerhub
#         docker pull ethereum/client-go:stable
	    
# 	    # docker push "${aws_ecr_repository.ecr_repo.repository_url}:latest"
#         docker push ethereum/client-go:stable
# 	    EOF
# 	  }