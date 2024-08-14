# Based on https://github.com/svthalia/sideproject-template/.
terraform {
  required_version = ">=1.5.6"

  required_providers {
    aws = ">= 5.15.0"
  }

  backend "s3" {
    bucket  = "thalia-terraform-state"
    key     = "scavengerhunt/production.tfstate"
    region  = "eu-west-1"
    profile = "thalia"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "thalia"
}

# Server, disks, network, and S3 bucket.
module "sideproject" {
  source = "github.com/svthalia/sideproject-template//terraform/sideproject?ref=1901a50"

  project_name = "scavengerhunt"
  stage        = "production"
  zone_name    = "thalia.nu"
  domain       = "scavengerhunt.thalia.nu"

  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINw1ATvRfBsU0pxc4w7csjg+ElCjZ5bgwrj687/niu+o"

  s3_buckets = {
    "media" = {
      versioning = "Disabled"
    }
  }

  ec2_instance_type = "t3a.small"
}


# Policy to allow an EC2 instance to access the bucket.
resource "aws_iam_role_policy" "start_mediaconvert" {
  name   = "scavengerhunt-start-mediaconvert-policy"
  role   = module.sideproject.ec2_role_id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["iam:PassRole", "sts:AssumeRole"],
      "Resource": ["${aws_iam_role.mediaconvert.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "mediaconvert:CreateJob"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Policy to allow an EC2 instance to access the bucket.
resource "aws_iam_role_policy" "start_compression_lambda" {
  name   = "scavengerhunt-start-compression-lambda-policy"
  role   = module.sideproject.ec2_role_id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-1:627002765486:function:ScavengerhuntImageCompressor"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "mediaconvert" {
  name = "scavengerhunt-mediaconvert-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "mediaconvert.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name   = "AccessScavengerhuntBucket"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "${module.sideproject.bucket_arns.media}/files/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Put*"
            ],
            "Resource": [
                "${module.sideproject.bucket_arns.media}/compressed/*",
                "${module.sideproject.bucket_arns.media}/thumbnails/*"
            ]
        }
    ]
}
EOF
  }
}

output "mediaconvert_role_arn" {
  value = aws_iam_role.mediaconvert.arn
}
