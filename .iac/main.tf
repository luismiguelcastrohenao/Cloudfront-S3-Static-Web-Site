# S3 bucket para sitio
resource "aws_s3_bucket" "luism_static_site" {
  //bucket = "luism-static-site3"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "luism-static-site2-oac"
  description                       = "OAC for luism-static-site2"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
        # Local values assign names to expressions, letting you use the name multiple times within a module instead of repeating the expression
locals {
  s3_origin_id = "s3-origin"
}
      # origin (Required) - Whether the distribution is enabled to accept end user requests for content.
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.luism_static_site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.s3_origin_id
  }

# (Required) - Whether the distribution is enabled to accept end user requests for content.
  enabled             = true
  # is_ipv6_enabled     = true
  # comment             = "Some comment"
  default_root_object = "index.html"

# (Required) - Default cache behavior for this distribution (maximum one). 
          #Requires either cache_policy_id (preferred) or forwarded_values (deprecated) be set.
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"] # "DELETE", "OPTIONS", "PATCH", "POST", "PUT"
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    # min_ttl                = 0
    # default_ttl            = 3600
    # max_ttl                = 86400
  }

# (Required) - The restriction configuration for this distribution (maximum one).
  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Environment = "production"
  }

# (Required) - The SSL configuration for this distribution (maximum one).
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Política de bucket para permitir acceso solo desde CloudFront
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.luism_static_site.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.luism_static_site.arn}/*"
        Condition = {
          ArnLike = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn   #"arn:aws:cloudfront::465731220541:distribution/E4DN24XBGRSAB"
          }
        }
      }
    ]
  })
}
