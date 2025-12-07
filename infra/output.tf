output "s3_website" {
  value = module.s3_website.s3_bucket_website
}

output "s3_cloudfront" {
  value = module.s3_cloudfront.cloudfront
}

output "vpc" {
  value = module.vpc.vpc
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "ecr_repository" {
  value = module.ecr.repository
}