output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_cidr_block" {
    value = aws_subnet.public-subnet[*].id
}

output "private_cidr_block" {
    value = aws_subnet.private-subnet[*].id
}

output "database_cidr_block" {
    value = aws_subnet.database-subnet[*].id
}

