resource "aws_vpc" "this" {
  cidr_block           = var.vpc.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.vpc.name}"
  }
}

resource "aws_internet_gateway" "this" {
  count  = var.aws_internet_gateway.enabled ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc.name}-igw"
  }
}


resource "aws_subnet" "private" {
  count             = length(local.private_subnets_cidr)
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnets_cidr[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc.name}-private-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
      Type = "Private"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count                   = var.aws_internet_gateway.enabled ? length(local.public_subnets_cidr) : 0
  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnets_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc.name}-public-subnet-${substr(var.availability_zones[count.index], -1, 1)}"
    Type = "Public"
  }
}

resource "aws_eip" "nat" {
  count  = length(local.public_subnets_cidr)
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.vpc.name}-nat-eip-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count         = length(local.public_subnets_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.vpc.name}-nat-gw-${count.index + 1}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(
    {
      Name = "${var.vpc.name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public[*].id)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = length(local.private_subnets_cidr)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(
    {
      Name = "${var.vpc.name}-private-rt-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private[*].id)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}