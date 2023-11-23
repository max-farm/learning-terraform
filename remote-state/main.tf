#this runs only once 
#creating s3 bucket with versioning enabled for storing tfsate file 
#encryption enabled by default 
#outputs name of the bucket

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tfstate_bucket" {
  bucket_prefix = "tfstate-bucket-"
  tags = {
    Name = "tfstate-bucket"  
    }
}

resource "aws_s3_bucket_versioning" "tfstate_bucket_versioning" {
    bucket = aws_s3_bucket.tfstate_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

output "tfstate_bucket" {
  value = aws_s3_bucket.tfstate_bucket.bucket
}