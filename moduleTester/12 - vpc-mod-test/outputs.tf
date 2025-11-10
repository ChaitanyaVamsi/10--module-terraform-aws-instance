output "vpc_id" {
  value = module.samplecheck_vpc.vpc_id_module
}

# data "aws_availability_zones" "available" {
#   state = "available"
# }

# output "az" {
#   value = data.aws_availability_zones.available
# }

output "public_subnet" {
  value = module.samplecheck_vpc.pubic_subnet_id
}
