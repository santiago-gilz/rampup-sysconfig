
packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "AWS_REGION" {
  type    = string
  default = "us-west-1"
}

variable "AWS_INSTANCE_TYPE" {
  type    = string
  default = "t2.micro"
}

variable "AWS_KEY_PAIR_NAME" {
  type    = string
  default = "sgilz-key-pair"
}

variable "common_tags" {
  type = map(string)
  default = {
    "Name"        = "sgilz-api-instance",
    "responsible" = "santiago.gilz",
    "project"     = "ramp-up-devops"
  }
}

source "amazon-ebs" "ui_centos8" {
  ami_description = "AMI for providing Movie Analyst ui"
  ami_name        = "ui-centos8"
  instance_type   = var.AWS_INSTANCE_TYPE
  region          = var.AWS_REGION
  run_tags        = var.common_tags
  run_volume_tags = var.common_tags
  ssh_username    = "centos"
  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "CentOS 8*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["125523088429"]
    most_recent = true
  }
  subnet_id = "subnet-0088df5de3a4fe490"
  tags      = var.common_tags
  vpc_id    = "vpc-0d2831659ef89870c"
}

build {
  name = "movie-analyst-ui"
  sources = [
    "source.amazon-ebs.ui_centos8"
  ]

  provisioner "ansible" {
    inventory_directory = "../environments/staging"
    playbook_file       = "../playbooks/ui.yml"
    roles_path          = "../roles"
    extra_arguments     = ["--extra-vars", "'api_lb_ip=elb.movie_analyst.internal'"]
  }
}
