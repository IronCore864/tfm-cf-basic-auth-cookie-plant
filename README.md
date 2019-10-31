# Terraform Module - CloudFront for Basic Auth and Plant Cookie

This CloudFront distribution is basically empty, that when accessing, does a basic auth then plant the cookie for the corresponding top level domain. Used for protecting certain websites.

## Usage

Example:

```
module "cf_de_basic_auth_cookie_plant" {
  source = "git::https://github.com/IronCore864/tfm-cf-basic-auth-cookie-plant.git"
  naming_prefix = "xxx"
  acm_certificate_arn     = var.cookie_plant_cf_cert_arn
  aliases                 = var.cookie_plant_cf_aliases
  basic_auth_lambda_arn   = "xxx"
  cookie_plant_lambda_arn = "xxx"
  r53_zone_id             = var.r53_zone_id
  set_cookie_r53_name     = var.set_cookie_r53_name
}
```

