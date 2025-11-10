# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection

resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0
  #  peer_owner_id = var.peer_owner_id
  #  this is used when we want to peer in another account , but for now we do peeing in same account so not required

  peer_vpc_id = data.aws_vpc.default.id # acceptor
  vpc_id      = aws_vpc.main.id         # requestor

  accepter {
    allow_remote_vpc_dns_resolution = true
    #  with this flag enabled (and proper networking setup),
    #  you can seamlessly reach EC2 instances across VPCs using private DNS names, not just IPs.
    # Private IP: 10.0.1.10
    # Private DNS: ip-10-0-1-10.ec2.internal - we can use this also to ping


  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  auto_accept = true

  #  When you create a VPC peering connection, one VPC acts as the requester, and the other as the accepter.
  # Normally, when you create the peering connection, it goes into a "pending acceptance" state.
  # You (or another Terraform configuration) must then accept it explicitly, using a resource like:
  # on the aws_vpc_peering_connection resource itself, Terraform will automatically accept the peering immediately upon creation — no manual step needed.

  # | Setting              | Meaning                                                                        |
  # | -------------------- | ------------------------------------------------------------------------------ |
  # | `auto_accept = true` | Automatically accepts the VPC peering connection when created.                 |
  # | Works when           | Both VPCs are in the **same account and region**.                              |
  # | Not valid when       | VPCs are in **different accounts or regions** (must use an accepter resource). |

  tags = merge(local.common_tags, var.vpc_tags, {
    Name = "${local.common_name_suffix}-default"
  })

}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "public_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id       // here we are referring the route table of public chech in vpc.tf
  destination_cidr_block    = data.aws_vpc.default.cidr_block // this is default vpc cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# resource "aws_route" "private_peering" {
#   count                     = var.is_peering_required ? 1 : 0
#   route_table_id            = aws_route_table.private.id // here we are referring the route table of private check in vpc.tf
#   destination_cidr_block    = data.aws_vpc.default.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.default.id
# }

resource "aws_route" "default_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.default_vpc_route_table.id // here we are referring the route table of default vpc refer data.tf
  destination_cidr_block    = var.vpc_cidr                                    // this is our created vp cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}
