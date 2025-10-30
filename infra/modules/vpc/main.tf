data "aws_availability_zones" "available" {}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-igw" }
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)
  vpc_id                   = aws_vpc.this.id
  cidr_block               = each.key
  map_public_ip_on_launch  = true
  availability_zone        = element(data.aws_availability_zones.available.names, index(var.public_subnet_cidrs, each.key))
  tags = { Name = "${var.name_prefix}-public-${index(var.public_subnet_cidrs, each.key)+1}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain = "vpc"
  tags = { Name = "${var.name_prefix}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = { Name = "${var.name_prefix}-nat-${each.key}" }
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)
  vpc_id                   = aws_vpc.this.id
  cidr_block               = each.key
  map_public_ip_on_launch  = false
  availability_zone        = element(data.aws_availability_zones.available.names, index(var.private_subnet_cidrs, each.key))
  tags = { Name = "${var.name_prefix}-private-${index(var.private_subnet_cidrs, each.key)+1}" }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.name_prefix}-private-rt-${each.key}" }
}

resource "aws_route" "private_nat" {
  for_each = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(values(aws_nat_gateway.nat)[*].id, index(keys(aws_route_table.private), each.key))
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

output "vpc_id"             { value = aws_vpc.this.id }
output "public_subnet_ids"  { value = [for s in aws_subnet.public  : s.value.id] }
output "private_subnet_ids" { value = [for s in aws_subnet.private : s.value.id] }
