# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate all public subnets with the public route table
resource "aws_route_table_association" "public_assocs" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt.id
}

# Create route tables for each private subnet using corresponding NAT GW
resource "aws_route_table" "private_rts" {
  count  = length(var.private_subnet_ids)
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_ids[count.index]
  }

  tags = {
    Name = "nat-gw-${count.index + 1}"
  }
}

# Associate each private subnet to its respective NAT route table
resource "aws_route_table_association" "private_assocs" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_rts[count.index].id
}
