### Create bucket where static pages and cron job for cost
### analyzer
## Generate or Create S3 bucket
resource "aws_s3_bucket" "server_bucket" {
    bucket = "nthn-serverless-project-bucket"
}

##S3 bucket policy
## all block policy are disable by default
resource "aws_s3_bucket_public_access_block" "s3_policy_block" {
    bucket = aws_s3_bucket.server_bucket.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

##Create API-Gateway##
## API Gateway is a layer acts a Front door for our backend services which is in Lambda
resource "aws_apigatewayv2_api" "api-front-door" {
    name = "api-backend"
    protocol_type = "HTTP"

    cors_configuration {
      allow_origins = [ "*" ]
      allow_methods = [ "POST" ]
      allow_headers = ["*"]
    }
}


#### Create cloudfront ###
## a CDN or content delivery network. Which serves contents from S3/API Gateway
## This will add security and won't allow user to directly access 
## content in your Bucket or VPC

##Create a access control where will point to s3 bucket
resource "aws_cloudfront_origin_access_control" "s3_oac" {
    name = "s3-oac"
    origin_access_control_origin_type = "s3"
    signing_behavior = "always"
    signing_protocol = "sigv4"
  
}

#2
##Cloud Distribution
resource "aws_cloudfront_distribution" "serverless_cdn" {
  enabled = true 


    ##Origin Point enabling to S3 bucket
  origin {
    domain_name = aws_s3_bucket.server_bucket.bucket_regional_domain_name
    origin_id = "S3-Static-Assets"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  origin {
    domain_name = replace(aws_apigatewayv2_api.api-front-door.api_endpoint, "/^https?://([^/]*).*/", "$1")
    origin_id = ("APIGateway-Backend")

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = [ "TLSv1.2" ]
      
    }

  }
  
  default_cache_behavior {
    target_origin_id = "APIGateway-Backend"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods = [ "GET", "HEAD" ]
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction { restriction_type = "none"}
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}