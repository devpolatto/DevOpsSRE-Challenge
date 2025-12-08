output "vpc" {
  value = {
    name       = var.vpc.name
    id         = aws_vpc.this.id
    arn        = aws_vpc.this.arn
    cidr_block = aws_vpc.this.cidr_block
  }
}

output "public_subnets" {
  value = {
    names = aws_subnet.public[*].tags["Name"]
    ids   = aws_subnet.public[*].id
    arns  = aws_subnet.public[*].arn
  }
}

output "private_subnets" {
  value = {
    names = aws_subnet.private[*].tags["Name"]
    ids   = aws_subnet.private[*].id
    arns  = aws_subnet.private[*].arn
  }
}

output "public_route_table_ids" {
  value = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  value = aws_route_table.private[*].id
}