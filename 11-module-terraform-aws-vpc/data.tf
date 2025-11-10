data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_vpc" "default" { // instead of default we can give any name suppose vpc_info, wassup_info
  default = true
}

output "default_vpc_id" {
  value = data.aws_vpc.default.id
}

data "aws_route_table" "default_vpc_route_table" {
  vpc_id = data.aws_vpc.default.id # Replace with the actual ID of your VPC

  filter {
    name   = "association.main"
    values = ["true"]
  }
}

output "default_route_table_id" {
  value = data.aws_route_table.default_vpc_route_table.id
}
