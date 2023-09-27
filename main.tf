resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge (
  var.common_tags,
  { 
    Name = var.project_name
  },
   var.vpc_tags)
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = merge (
    var.common_tags, 
    {
        Name = var.project_name
    },
    var.gw_tags)
}

resource "aws_subnet" "public-subnet" {
  count = length(var.public_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_cidr_block[count.index]
  availability_zone = local.azs[count.index]
  tags = merge (var.common_tags, 
  {
    Name = "${var.project_name}-public-${local.azs[count.index]}"
  })
} 

resource "aws_subnet" "private-subnet" {
  count = length(var.private_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr_block[count.index]
  availability_zone = local.azs[count.index]
  tags = merge (var.common_tags, 
  {
    Name = "${var.project_name}-private-${local.azs[count.index]}"
  })
} 

resource "aws_subnet" "database-subnet" {
  count = length(var.database_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidr_block[count.index]
  availability_zone = local.azs[count.index]
  tags = merge (var.common_tags, 
  {
    Name = "${var.project_name}-database-${local.azs[count.index]}"
  })
} 


resource "aws_route_table" "public_route_table" {
vpc_id = aws_vpc.main.id
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id 
}
tags = merge (
    var.common_tags, 
    {
        Name = "${var.project_name} - public"
    },
    var.public_route_table_tags )
}
# Natgateway is chargable.
resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-subnet[0].id # we are providing NAT gateway only in 1a subnet

  tags = merge(
    var.common_tags,
    {
        Name = var.project_name
    },
    var.nat_gateway_tags
  )
  #To ensure proper ordering, it is recommended to add an explicit dependency
 # on the Internet Gateway for the VPC.
 depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private_route_table" {
vpc_id = aws_vpc.main.id
route {
    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id # As it is chargable, for now iam commenting and giving internet gateway
    
}
tags = merge (
    var.common_tags, 
    {
        Name = "${var.project_name} - private"
    },
    var.private_route_table_tags )
}

#either we can use this separate block or give as above 
# resource "aws_route" "private" {
#   route_table_id            = aws_route_table.private.id
#   destination_cidr_block    = "0.0.0.0/0"
#   nat_gateway_id = aws_nat_gateway.main.id
# }

resource "aws_route_table" "database_route_table" {
vpc_id = aws_vpc.main.id
route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id # As it is chargable, for now iam commenting and giving internet gateway
    #gateway_id = aws_internet_gateway.gw.id 
}
tags = merge (
    var.common_tags, 
    {
        Name = "${var.project_name} - database"
    },
    var.database_route_table_tags )
}
#grouping databases into one group
resource "aws_db_subnet_group" "database_route_table_group" {
subnet_ids = aws_subnet.database-subnet[*].id

  tags = merge (
    var.common_tags, 
    {
        Name = "${var.project_name} - database"
    },
    var.database_route_table_group_tags )
}

resource "aws_route_table_association" "public_association" {
count = length(var.public_cidr_block)
subnet_id = element(aws_subnet.public-subnet[*].id, count.index)
route_table_id = aws_route_table.public_route_table.id
}


#Association of subnet to route table
resource "aws_route_table_association" "private_association" {
count = length(var.private_cidr_block)
subnet_id = element(aws_subnet.private-subnet[*].id, count.index)
route_table_id = aws_route_table.private_route_table.id
}

#Association of subnet to route table
resource "aws_route_table_association" "database_association" {
count = length(var.database_cidr_block)
subnet_id = element(aws_subnet.database-subnet[*].id, count.index)
route_table_id = aws_route_table.database_route_table.id
}



