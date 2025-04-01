#--------------------------------------------------------------------------------------
#Shared Route 53 setting
resource "aws_route53_zone" "shared_route53_zone" {
    name  = local.private_r53_zone_name
    comment = "Private hosted Zone for AWS Lz in common service account for shared services accounts"
    force_destroy = false
    tags = local.common_tags
    vpc {
        vpc_id = aws_vpc.comsrv_vpc.id
        vpc_region = local.primary_region
    }

    lifecycle {
        ignore_changes = all
    }

    depends_on = [
        aws_vpc.comsrv_vpc
    ]
}

#Authorize application vpcs to be associated with core private hosted zone
resource "aws_route53_vpc_association_authorization" "private_shared_r53_zone" {
    count = length(local.account_list)
    vpc_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
    zone_id = aws_route53_zone.shared_route53_zone.id
}

####

resource "aws_security_group" "sg_comsrv_resep_mum_01" {
    name = "sg_comsrv_resep_mum_01"
    description = "Security Group To Be assocaited with r53 resolver"
    vpc_id = aws_vpc.comsrv_vpc.id

    ingress {
    description = "DNS port"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = local.private_network_range
    }

    ingress {
    description = "DNS port"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = local.private_network_range
    }

    egress {
    description = "DNS port"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    }
}

## Inbound endpoints
resource "aws_route53_resolver_endpoint" "resolver_inbount_endpoint" {
    name = "resep-comsrv-inbound-ept-mum-01"
    direction = "INBOUND"

    security_group_ids = [
        aws_security_group.sg_comsrv_resep_mum_01.id
    ]

    ip_address {
        subnet_id = "subnet-0e612ad1f9fcc51d8" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    ip_address {
        subnet_id = "subnet-0a8a15bf513f4b078" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    tags = local.common_tags
    
    depends_on = [
        aws_security_group.sg_comsrv_resep_mum_01
    ]
}

resource "aws_route53_resolver_endpoint" "resolver_outbound_endpoint" {
    name = "resep-comsrv-outbound-ept-mum-01"
    direction = "OUTBOUND"

    security_group_ids = [
        aws_security_group.sg_comsrv_resep_mum_01.id
    ]

     ip_address {
        subnet_id = "subnet-00d53e776165ce0c8" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    ip_address {
        subnet_id = "subnet-04dc93d321d8bb94e" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    tags = local.common_tags
    
    depends_on = [
        aws_security_group.sg_comsrv_resep_mum_01
    ]
}