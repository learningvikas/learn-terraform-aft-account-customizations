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
}

ingress {
    description = "DNS port"
    from_port   = 53
    tp_port     = 53
    protocol    = "tcp"
    cidr_blocks = local.private_network_range
}

ingress {
    description = "DNS port"
    from_port   = 53
    tp_port     = 53
    protocol    = "udp"
    cidr_blocks = local.private_network_range
}

egress {
    description = "DNS port"
    from_port   = 0
    tp_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
    ipv6_cidr_blocks = ["::/0"]
}

## Inbound endpoints
resource "aws_route53_resolver_endpoint" "resolver_inbount_endpoint" {
    name = "resep-comsrv-inbound-ept-mum-01"
    direction = "INBOUND"

    security_group_ids = [
        aws_security_group.sg_comsrv_resep_mum_01.id
    ]

    ip_address {
        subnet_id = "" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    ip_address {
        subnet_id = "" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
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
        subnet_id = "" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    ip_address {
        subnet_id = "" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    tags = local.common_tags
    
    depends_on = [
        aws_security_group.sg_comsrv_resep_mum_01
    ]
}

resource "aws_route53_resolver_rule" "aws_res_rule_01" {
    domain_name = local.rslr_rule_name
    name = "aws_res_rule_01"
    rule_type = "FORWARD"
    resolver_endpoint_id = aws_route53_resolver_endpoint.resolver_outbound_endpoint.id

    target_ip {
        ip = aws_route53_resolver_endpoint.resolver_inbound_endpoint.ip_address.*.ip[0]
        port = 53
    }

    target_ip {
        ip = aws_route53_resolver_endpoint.resolver_inbound_endpoint.ip_address.*.ip[1]
        port = 53
    }

    tags = local.common_tags
    
    depends_on = [
        aws_route53_resolver_endpoint.resolver_inbound_endpoint,
        aws_route53_resolver_endpoint.resolver_outbound_endpoint,
    ]
}

# aws res_rule_01 sharing with private shared hosted zone accounts
resource "aws_ram_resource_share" "resolver-rule-shared-mum" {
    name  = "resolver-rule-shared_mum"
    allow_external_principals = false
    tags = local.common_tags
    depends_on = [aws_route53_resolver_rule.aws_res_rule_01]
}

resouce "aws_ram_resource_association" "resolver-rule-shared_mum_assoc" {
    resource_arn = aws_route53_resolver_rule.aws_res_rule_01.arn
    resource_share_arn = aws_ram_resource_share.resolver-rule-shared_mum.arn
}

resource "aws_ram_principal_association" "resolver_rule_aws_nm_cloud_ou" {
    count = length(local.account_number_list)
    principal = local.account_number_list[count.index]
    resource_share_arn = aws_ram_resource_share.resolver-rule-shared_mum.arn
}

#-------Onprem Route 53 settings-------
resource "aws_security_group" "sg_onprem_comsrv_resep_mum_01" {
    name = "sg_onprem_comsrv_resep_mum_01"
    description = "Security Group to be associated with r53 resolver"
    vpc_id = aws_vpc.comsrv_vpc.id

    ingress {
    description = "DNS port"
    from_port   = 53
    tp_port     = 53
    protocol    = "tcp"
    cidr_blocks = local.private_network_range
}

ingress {
    description = "DNS port"
    from_port   = 53
    tp_port     = 53
    protocol    = "udp"
    cidr_blocks = local.private_network_range
}

egress {
    description = "DNS port"
    from_port   = 0
    tp_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
    ipv6_cidr_blocks = ["::/0"]
}
}

resource "aws_route53_resolver_endpoint" "resolver_onprem_outbound_endpoint" {
    name = "resep-comsrv-outbound-ept-mum-01"
    direction = "OUTBOUND"

    security_group_ids = [
        aws_security_group.sg_onprem_comsrv_resep_mum_01.id
    ]

     ip_address {
        subnet_id = "" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    ip_address {
        subnet_id = "" #sns-comsrv-resolver-mum-a01 #data.aws_subnet.private_subnet_aza.id
    }

    tags = local.common_tags
    
    depends_on = [
        aws_security_group.sg_onprem_comsrv_resep_mum_01
    ]
}

resource "aws_route53_resolver_rule" "aws_res_rule_01" {
    domain_name = local.rslr_rule_name
    name = "onprem_res_rule_01"
    rule_type = "FORWARD"
    resolver_endpoint_id = aws_route53_resolver_endpoint.resolver_onprem_outbound_endpoint.id

    target_ip {
        ip = IP Address1
        port = 53
    }

    target_ip {
        ip = IP Address2
        port = 53
    }

    tags = local.common_tags
    
}

# aws res_rule_01 sharing with private shared hosted zone accounts
resource "aws_ram_resource_share" "resolver-rule-onprem-mum" {
    name  = "resolver-rule-onprem_mum"
    allow_external_principals = false
    tags = local.common_tags
    depends_on = [aws_route53_resolver_rule.onprem_res_rule_01]
}

resouce "aws_ram_resource_association" "resolver-rule-onprem_mum_assoc" {
    resource_arn = aws_route53_resolver_rule.onprem_res_rule_01.arn
    resource_share_arn = aws_ram_resource_share.resolver-rule-onprem_mum.arn
}

resource "aws_ram_principal_association" "resolver_rule_aws_nm_cloud_onprem" {
    count = length(local.account_number_list)
    principal = local.account_number_list[count.index]
    resource_share_arn = aws_ram_resource_share.resolver-rule-onprem_mum.arn
}

# Dev Route 53 settings
resource "aws_route53_zone" "dev_route53_zone" {
    name  = local.private_r53_zone_name_dev
    comment = "Private hosted Zone for AWS Lz in common service account for dev accounts"
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

# UAT Route 53 settings
resource "aws_route53_zone" "UAT_route53_zone" {
    name  = local.private_r53_zone_name_uat
    comment = "Private hosted Zone for AWS Lz in common service account for UAT accounts"
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

# PRD Route 53 settings
resource "aws_route53_zone" "prd_route53_zone" {
    name  = local.private_r53_zone_name_prd
    comment = "Private hosted Zone for AWS Lz in common service account for prd accounts"
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

# ssm vpc endpoint Route 53 settings
resource "aws_route53_zone" "ssm_endpoint_route53_zone" {
    name  = local.private_r53_zone_ssm_endpoint
    comment = "Private hosted Zone for AWS Lz in common service account for prd accounts"
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
resource "aws_route53_vpc_association_authorization" "private_amazon_r53_zone_ssm_endpoint" {
    count = length(local.account_list)
    vpc_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
    zone_id = aws_route53_zone.ssm_endpoint_route53_zone.id
}

resource "aws_route53_vpc_association_authorization" "private_amazon_r53_zone_ssm_endpoint" {
    count = length(local.account_list)
    vpc_id = ""
    zone_id = aws_route53_zone.ssm_endpoint_route53_zone.id
}

# ssmmessages vpc endpoint route 53 settoing

resource "aws_route53_zone" "ssmmessages_endpoint_route53_zone" {
    name  = local.private_r53_zone_ssm_endpoint
    comment = "Private hosted Zone for AWS Lz in common service account for prd accounts"
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
resource "aws_route53_vpc_association_authorization" "private_amazon_r53_zone_ssmmessages_endpoint" {
    count = length(local.account_list)
    vpc_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
    zone_id = aws_route53_zone.ssmmessages_endpoint_route53_zone.id
}

# ec2messages vpc endpoint route 53 settoing

resource "aws_route53_zone" "ec2messages_endpoint_route53_zone" {
    name  = local.private_r53_zone_ec2messages_endpoint
    comment = "Private hosted Zone for AWS Lz in common service account for prd accounts"
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
resource "aws_route53_vpc_association_authorization" "private_amazon_r53_zone_ec2messages_endpoint" {
    count = length(local.account_list)
    vpc_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
    zone_id = aws_route53_zone.ec2messages_endpoint_route53_zone.id
}

#----------------------------------------------------------
# VPC Endpoint security group creation for ssm, ssmmessages, and ec2messages

resource "aws_security_group" allow_endpoints" {
    name = "sg_comsrv_endpoint"
    description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
    vpc_id = aws_vpc.comsrv_vpc.id

    dynamic "ingress" {
        for_each = local.rules 
        content {
            description = "allow for all"
            from_port = 443
            to_port = 443
            protocol = "tcp"
            cidr_blocks = ingress.value.cidr_blocks
        }
    }

    ingress {
        description = "allow for ssm, ssmmessages and ec2messages vpc endpoint"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = [local.primary_vpc_cidr]
    }

    tags = merge(
        {
            "Name" : "sg-comsrv-endpoint"
        },
        
        local.common_tags
    )
}

#------------------------------------------------------------------------
SSM Endppoint creation of ssm

resource "aws_vpc_endpoint" "ssm_endpoint_service" {
    vpc_id = aws_vpc.comsrv_vpc.id
    service_name = "com.amazonaws.ap-south-1.ssm"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.allow_endpoints.id,
    ]

    subnet_ids  = [data.aws_subnet.private_subnet_aza.id, data.aws_subnet.private_subnet_azb.id]
    private_dns_enabled = false

    depends_on = [
        aws_security_group.allow_endpoints
    ]

    tags = merge(
        {
            "Name" : "ssm_endpoint_service"
        }
    )
}

#SSM Endppoint creation of ssm messages

resource "aws_vpc_endpoint" "ssmmessages_endpoint_service" {
    vpc_id = aws_vpc.comsrv_vpc.id
    service_name = "com.amazonaws.ap-south-1.ssmmessages"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.allow_endpoints.id,
    ]

    subnet_ids  = [data.aws_subnet.private_subnet_aza.id, data.aws_subnet.private_subnet_azb.id]
    private_dns_enabled = false

    depends_on = [
        aws_security_group.allow_endpoints
    ]

    tags = merge(
        {
            "Name" : "ssmmessages_endpoint_service"
        }
    )
}

#SSM Endppoint creation of ec2 messages

resource "aws_vpc_endpoint" "ec2messages_endpoint_service" {
    vpc_id = aws_vpc.comsrv_vpc.id
    service_name = "com.amazonaws.ap-south-1.ec2messages"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.allow_endpoints.id,
    ]

    subnet_ids  = [data.aws_subnet.private_subnet_aza.id, data.aws_subnet.private_subnet_azb.id]
    private_dns_enabled = false

    depends_on = [
        aws_security_group.allow_endpoints
    ]

    tags = merge(
        {
            "Name" : "ec2messages_endpoint_service"
        }
    )
}

#----------------------------------------------------------
#commit to create the ssmmessages Record 
resource "aws_route53_record" "private_r53_ssmmessages_a_record" {
    zone_id = aws_route53_zone.ssmmessages_endpoint_route53_zone.id 
    name = local.private_amazon_r53_zone_ssmmessages_endpoint
    type = "A"

    alias {
        name = aws_vpc_endpoint.ssmmessages_endpoint_service.dns_entry[0].dns_name 
        zone_id = aws_vpc_endpoint.ssmmessages_endpoint_service.dns_entry[0].hosted_zone.id
        evaluate_target_health = true
    }

    depends_on = [
        aws_vpc_endpoint.ssmmessages_endpoint_service
    ]
}

#commit to create the ec2messages Record 
resource "aws_route53_record" "private_r53_ec2messages_a_record" {
    zone_id = aws_route53_zone.ec2messages_endpoint_route53_zone.id 
    name = local.private_amazon_r53_zone_ssmmessages_endpoint
    type = "A"

    alias {
        name = aws_vpc_endpoint.ec2messages_endpoint_service.dns_entry[0].dns_name 
        zone_id = aws_vpc_endpoint.ec2messages_endpoint_service.dns_entry[0].hosted_zone.id
        evaluate_target_health = true
    }

    depends_on = [
        aws_vpc_endpoint.ec2messages_endpoint_service
    ]
}

#-----------------------------------------------------------------
# s3 Vpc endpoint route 53 setting to shared with shared-dev vpc

resource "aws_route53_zone" "s3_endpoint_route53_zone" {
    name  = local.private_r53_zone_s3_endpoint
    comment = "Private hosted Zone for AWS Lz in common service account for all accounts"
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
resource "aws_route53_vpc_association_authorization" "private_amazon_r53_zone_s3_endpoint" {
    count = length(local.account_list)
    vpc_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
    zone_id = aws_route53_zone.s3_endpoint_route53_zone.id
}

#s3 Endppoint creation of ec2 messages

resource "aws_vpc_endpoint" "s3_endpoint_service" {
    vpc_id = aws_vpc.comsrv_vpc.id
    service_name = "com.amazonaws.ap-south-1.s3"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.allow_endpoints.id,
    ]

    subnet_ids  = [data.aws_subnet.private_subnet_aza.id, data.aws_subnet.private_subnet_azb.id]
    private_dns_enabled = false

    depends_on = [
        aws_security_group.allow_endpoints
    ]

    tags = merge(
        {
            "Name" : "s3_endpoint_service"
        }
    )
}

#commit to create the ssmmessages Record 
resource "aws_route53_record" "private_r53_s3_a_record" {
    zone_id = aws_route53_zone.s3_endpoint_route53_zone.id 
    name = local.private_amazon_r53_zone_s3_endpoint
    type = "A"

    alias {
        name = aws_vpc_endpoint.s3_endpoint_service.dns_entry[0].dns_name 
        zone_id = aws_vpc_endpoint.s3_endpoint_service.dns_entry[0].hosted_zone.id
        evaluate_target_health = true
    }

    depends_on = [
        aws_vpc_endpoint.s3_endpoint_service
    ]
}

#--------------------------------------
# Amazon sns, sqs, ses, rds elasticache, backup ecr, ecs, glue, ebs, vpc end point route 53 setting to share with all accounts vpc
resource "aws_route53_zone" "all_endpoint_route53_zone" {
    for_each  = toset(local.names_of_service)
    name  = "${each.key}.ap-south-1.amazonaws.com"
    comment = "Private hosted Zone for AWS Lz in common service account for all accounts"
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
resource "aws_route53_vpc_association_authorization" "all_other_private_amazon_r53_zone_assoc" {
    count = length(local.account_list)
    vpc_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}${local.account_list[count.index]}/vpc_id"]
    zone_id = local.vpc_endpoint_authorization_list[count.index].endpoint_hz_id
}

#commit to create endpoiont for all other services

resource "aws_vpc_endpoint" "all_other_endpoint_service" {
    for_each = toset(local.names_of_service)
    vpc_id = aws_vpc.comsrv_vpc.id
    service_name = "com.amazonaws.ap-south-1.${each.key}"
    vpc_endpoint_type = "Interface"

    security_group_ids = [
        aws_security_group.allow_endpoints.id,
    ]

    subnet_ids  = [data.aws_subnet.private_subnet_aza.id, data.aws_subnet.private_subnet_azb.id]
    private_dns_enabled = false

    depends_on = [
        aws_security_group.allow_endpoints,
        aws_route53_zone.all_endpoint_route53_zone
    ]

    tags = merge(
        {
            "Name" : "${each.key}_endpoint_service"
        }
    )
}

#commit to create the all other Record 
resource "aws_route53_record" "all_other_private_r53_a_record" {
    for_each = toset(local.names_of_service)
    zone_id = aws_route53_zone.all_endpoint_route53_zone[each.key].id
    name = ${each.key}.ap-south-1.amazonaws.com
    type = "A"

    alias {
        name = aws_vpc_endpoint.all_other_endpoint_service[each.key].dns_entry[0].dns_name 
        zone_id = aws_vpc_endpoint.all_other_endpoint_service[each.key].dns_entry[0].hosted_zone.id
        evaluate_target_health = true
    }

    depends_on = [
        aws_vpc_endpoint.all_other_endpoint_service
    ]
}