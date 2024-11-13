output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
output "internet_gw_id" {
  description = "Internet Gateway Id"
  value       = aws_internet_gateway.IGW.id
}
output "public_route_table_id" {
    
  description = "Public Route table"
  value       = aws_route_table.public_rt[*].id
}
output "private_route_table_id" {
  description = "Private Route table"
  value       = aws_route_table.private_rt[*].id
}
output "public_subnet_id" {
  description = "Public subnet"
  value       = aws_subnet.public_subnet[*].id
}
output "private_subnet_id" {
  description = "private subnet"
  value       = aws_subnet.private_subnet[*].id
}
output "elastic_ip_id" {
  description = "elastic ip id"
  value       = aws_eip.elastic_IP[*].id
}
output "nat_gateway_id" {
  description = "Nat GW ID"
  value       = aws_nat_gateway.demo-nat-gateway[*].id
}
output "public_instance_ip" {
  description = "public instance id"
  value       = aws_instance.public_instance[*].public_ip

}