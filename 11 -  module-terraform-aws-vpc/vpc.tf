# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = merge(local.common_tags, var.vpc_tags, {
    Name = local.common_name_suffix
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id //attaches the IGW to the VPC created earlier in your configuration (aws_vpc.main).

  tags = merge(local.common_tags, var.igw_tags, {
    Name = local.common_name_suffix
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "public" {
  count                   = length(var.public_subent_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subent_cidrs[count.index]
  availability_zone       = local.az[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, var.public_subnet_tags, {
    Name = "${local.common_name_suffix}-public-${local.az[count.index]} " #roboshop-public-us-east-1a
  })

}


resource "aws_subnet" "private" {
  count             = length(var.private_subent_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subent_cidrs[count.index]
  availability_zone = local.az[count.index]

  tags = merge(local.common_tags, var.private_subnet_tags, {
    Name = "${local.common_name_suffix}-private-${local.az[count.index]} " #roboshop-private-us-east-1a
  })

}

#this is also private just namesake we gave db
resource "aws_subnet" "database" {
  count             = length(var.database_subent_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subent_cidrs[count.index]
  availability_zone = local.az[count.index]

  tags = merge(local.common_tags, var.database_subnet_tags, {
    Name = "${local.common_name_suffix}-database-${local.az[count.index]} " #roboshop-database-us-east-1a
  })

}

# https://registry.terraform.io/providers/hashicorp/aws/3.9.0/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id


  tags = merge(local.common_tags, var.public_routeTable_tags, {
    Name = "${local.common_name_suffix}-public"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id


  tags = merge(local.common_tags, var.private_routeTable_tags, {
    Name = "${local.common_name_suffix}-private"
  })
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id


  tags = merge(local.common_tags, var.database_routeTable_tags, {
    Name = "${local.common_name_suffix}-database"
  })
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip

resource "aws_eip" "nat" {

  domain = "vpc"
  tags = merge(local.common_tags, var.elastic_ip_tags, {
    Name = "${local.common_name_suffix}-nat"
  })
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(local.common_tags, var.nat_gateway_tags, {
    Name = "${local.common_name_suffix}-nat"
  })
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example.id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.example.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association

resource "aws_route_table_association" "public" {
  count          = length(var.public_subent_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subent_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subent_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
