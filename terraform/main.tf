terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = local.aws_region
  access_key                  = "mock_key"
  secret_key                  = "mock_secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

# 1. Provision the S3 Bucket
resource "aws_s3_bucket" "resume_bucket" {
  bucket = "local-cloud-resume-bucket"
}

# 2. Enable Static Website Hosting on the Bucket
resource "aws_s3_bucket_website_configuration" "web_config" {
  bucket = aws_s3_bucket.resume_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# 3. Upload index.html to the Bucket
resource "aws_s3_object" "html" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "index.html"
  source       = "../frontend/index.html"
  content_type = "text/html"
}

# 4. Upload style.css to the Bucket
resource "aws_s3_object" "css" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "style.css"
  source       = "../frontend/style.css"
  content_type = "text/css"
}

# 5. Upload main.js to the Bucket
resource "aws_s3_object" "js" {
  bucket       = aws_s3_bucket.resume_bucket.id
  key          = "main.js"
  source       = "../frontend/main.js"
  content_type = "application/javascript"
}
