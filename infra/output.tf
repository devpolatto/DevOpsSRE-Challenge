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

# output "ecr_repository" {
#   value = module.ecr.repository
# }

# output "rds_aurora" {
#   value = {
#     cluster_endpoint         = module.rds_aurora.rds_aurora.cluster_endpoint
#     reader_endpoint          = module.rds_aurora.rds_aurora.reader_endpoint
#     writer_instance_endpoint = module.rds_aurora.rds_aurora.writer_instance_endpoint
#     reader_instance_endpoint = module.rds_aurora.rds_aurora.reader_instance_endpoint
#     port                     = module.rds_aurora.rds_aurora.port
#     secret_name              = module.rds_aurora.rds_aurora.secret_name
#     secret_arn               = module.rds_aurora.rds_aurora.secret_arn
#   }
# }