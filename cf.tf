locals {
  # only lowercase alphanumeric characters and hyphens allowed in s3 bucket name
  s3_origin_bucket = "${replace(var.naming_prefix, "_", "-")}-basic-auth-cookie"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "CF origin access identity for bucket ${local.s3_origin_bucket}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = true

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_bucket

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = var.basic_auth_lambda_arn
    }

    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = var.cookie_plant_lambda_arn
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2018"
  }

  wait_for_deployment = false
  retain_on_delete    = true
}

resource "aws_route53_record" "set-cookie" {
  zone_id = var.r53_zone_id
  name    = var.set_cookie_r53_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
