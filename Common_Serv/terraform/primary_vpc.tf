resource "aws_vpc" "comsrv_vpc" {
  cidr_block = local.primary_vpc_cidr
 
  instance_tenancy                 = local.instance_tenancy
  enable_dns_hostnames             = local.enable_dns_hostnames
  enable_dns_support               = local.enable_dns_support
  assign_generated_ipv6_cidr_block = local.assign_generated_ipv6_cidr_block
 
  tags = merge(
    { "Name"    = "${local.primary_vpc_name}"
    },
    local.common_tags
  )
}


resource "aws_subnet" "private_tgw_subnet" {
  count             = length(local.private_tgw_subnet_list)
  vpc_id            = aws_vpc.comsrv_vpc.id
  cidr_block        = local.private_tgw_subnet_list[count.index]
  availability_zone = local.availability_zones[count.index]
 
  tags = merge(
    {
      Name = try(
        local.private_tgw_subnet_name[count.index],
        format("${local.primary_vpc_name}-private-tgw-%s", element(local.availability_zones, count.index))
      )
    },
    local.common_tags
  )
}

resource "aws_route_table" "private_tgw_rt" {
  vpc_id = aws_vpc.comsrv_vpc.id
  tags = merge(
    {
      "Name" = local.private_tgw_rtb_name
    },
    local.common_tags
  )
}

resource "aws_route_table_association" "private_tgw_rt_assoc" {
    count   = length(local.private_tgw_subnet_list)
    subnet_id = element(aws_subnet.private_tgw_subnet.*.id, count.index)
    route_table_id = aws_route_table.private_tgw_rt.id
}

resource "aws_route" "private_tgw_subnet_egress" {
    route_table_id  = aws_route_table.private_tgw_rt.id
    destination_cidr_block = "0.0.0.0/0"
    transit_gateway_id = data.aws_ec2_transit_gateway.primary_network_tgw.id

    timeouts {
        create = "5m"
    }
}

#Private Subnet and route table association for bastion as sugesst by vikas_dubey

resource "aws_subnet" "private_bastion_subnet" {
    count   = length(local.private_subnet_list_bastion)
    vpc_id  = aws_vpc.comsrv_vpc.id
    cidr_block = local.private_subnet_list_bastion[count.index]
    availability_zone = local.availability_zones[count.index]


      tags = merge(
    {
      Name = try(
        local.private_subnet_name[count.index],
        format("${local.primary_vpc_name}-private-tgw-%s", element(local.availability_zones, count.index))
      )
    },
    local.common_tags
  )
}

resource "aws_route_table" "private_bastion_rt" {
    vpc_id = aws_vpc.comsrv_vpc.id
    tags = merge(
        {
            Name = local.private_subnet_rtb_name_bastion
        },
        local.common_tags
    )
}

resource "aws_route_table_association" "private_bastion_rt_assoc" {
    count   = length(local.private_subnet_list_bastion)
    subnet_id = element(aws_subnet.private_tgw_subnet.*.id, count.index)
    route_table_id = aws_route_table.private_bastion_rt.id

    depends_on = [
        aws_route_table.private_bastion_rt
    ]
}

resource "aws_route" "private_bastion_route" {
    count   = length(local.private_subnet_list_bastion)
    route_table_id = aws_route_table.private_bastion_rt.id
    destination_cidr_block = "0.0.0.0/0"
    transit_gateway_id = local.network_tgw.id

    timeouts {
        create = "5m"
    }

    depends_on = [
        aws_route_table.private_bastion_rt
    ]
}

#-----------------------------------------------
#PRivate Subnet and route table assocuation for resolver 

resource "aws_subnet" "private_resolver_subnet" {
    count   = length(local.private_subnet_list_resolver)
    vpc_id  = aws_vpc.comsrv_vpc.id
    cidr_block = local.private_subnet_list_resolver[count.index]
    availability_zone = local.availability_zones[count.index]


      tags = merge(
    {
      Name = try(
        local.private_subnet_name_resolver[count.index],
        format("${local.primary_vpc_name}-private-%s", element(local.availability_zones, count.index))
      )
    },
    local.common_tags
  )
}

resource "aws_route_table" "private_resolver_rt" {
    vpc_id = aws_vpc.comsrv_vpc.id
    tags = merge(
        {
            Name = local.private_subnet_rtb_name_resolver
        },
        local.common_tags
    )
}

resource "aws_route_table_association" "private_resolver_rt_assoc" {
    count   = length(local.private_subnet_list_resolver)
    subnet_id = element(aws_subnet.private_resolver_subnet.*.id, count.index)
    route_table_id = aws_route_table.private_resolver_rt.id

    depends_on = [
        aws_route_table.private_resolver_rt
    ]
}

resource "aws_route" "private_resolver_route" {
    count   = length(local.private_subnet_list_resolver)
    route_table_id  = aws_route_table.private_resolver_rt.id
    destination_cidr_block = "0.0.0.0/0"
    transit_gateway_id = local.network_tgw.id

    timeouts {
        create = "5m"
    }

    depends_on = [
        aws_route_table.private_resolver_rt
    ]
}

#---------------------------------------------------------------------
#PRivate Subnet and route table assocuation for resolver 

resource "aws_subnet" "private_vpcendpoint_subnet" {
    count   = length(local.private_subnet_list_vpcendpoint)
    vpc_id  = aws_vpc.comsrv_vpc.id
    cidr_block = local.private_subnet_list_vpcendpoint[count.index]
    availability_zone = local.availability_zones[count.index]


      tags = merge(
    {
      Name = try(
        local.private_subnet_name_vpcendpoint[count.index],
        format("${local.primary_vpc_name}-private-%s", element(local.availability_zones, count.index))
      )
    },
    local.common_tags
  )
}

resource "aws_route_table" "private_vpcendpoint_rt" {
    vpc_id = aws_vpc.comsrv_vpc.id
    tags = merge(
        {
            Name = local.private_subnet_rtb_name_vpcendpoint
        },
        local.common_tags
    )
}

resource "aws_route_table_association" "private_vpcendpoint_rt_assoc" {
    count   = length(local.private_subnet_list_vpcendpoint)
    subnet_id = element(aws_subnet.private_tgw_subnet.*.id, count.index)
    route_table_id = aws_route_table.private_vpcendpoint_rt.id

    depends_on = [
        aws_route_table.private_vpcendpoint_rt
    ]
}

resource "aws_route" "private_vpcendpoint_route" {
    count   = length(local.private_subnet_list_vpcendpoint)
    route_table_id  = aws_route_table.private_vpcendpoint_rt.id
    destination_cidr_block = "0.0.0.0/0"
    transit_gateway_id = local.network_tgw.id

    timeouts {
        create = "5m"
    }

    depends_on = [
        aws_route_table.private_vpcendpoint_rt
    ]
}




