# Create s3 bucket
resource "aws_s3_bucket" "demo_bucket" {
  bucket = "front-end-${data.aws_caller_identity.current.account_id}"
  tags = {
    Name = "My bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "demo_bucket" {
  bucket = aws_s3_bucket.demo_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "demo_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.demo_bucket]

  bucket = aws_s3_bucket.demo_bucket.id
  acl    = "private"
}

# Create CloudFront origin access control
resource "aws_cloudfront_origin_access_control" "demo_origin_access_control" {
  name                            = "${aws_s3_bucket.demo_bucket.id}.s3.us-east-1.amazonaws.com"
  origin_access_control_origin_type = "s3"
  signing_behavior                = "no-override"
  signing_protocol                = "sigv4"
}

# Create CloudFront distribution
resource "aws_cloudfront_distribution" "demo_distribution" {
  origin {
    domain_name              = aws_s3_bucket.demo_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.demo_origin_access_control.id
    origin_id                = "${aws_s3_bucket.demo_bucket.id}.s3.us-east-1.amazonaws.com"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "AppMod Journey Ecommerce Front End"
  default_root_object = "home/index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${aws_s3_bucket.demo_bucket.id}.s3.us-east-1.amazonaws.com"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress = true
  }

 
  price_class = "PriceClass_200"

    restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.environment
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  #Custom error response for single page applications
  custom_error_response {
    error_code      = 403
    response_code   = 200
    response_page_path = "/index.html"
  }
  custom_error_response {
    error_code      = 404
    response_code   = 200
    response_page_path = "/index.html"
  }
}

# Grant read permission to the CloudFront origin access identity
resource "aws_s3_bucket_policy" "demo_website_bucket_policy" {
  bucket = aws_s3_bucket.demo_bucket.id
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipal",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::front-end-${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.demo_distribution.id}"
                }
            }
        }
    ]
}
EOF
}