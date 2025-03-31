locals {
  account_name      = "account-lz2-network"
  primary_vpc_name  = "vpc-network-mum-01"
  primary_region    = "ap-south-1"
  availability_zones = ["${local.primary_region}a", "${local.primary_region}b"]

primary_vpc_cidr   = "10.1.0.0/16"

private_subnet_list    = ["10.1.0.0/17", "10.1.128.0/17"]
private_subnet_name    = ["snt-comsrv-tgwattach-mum-a01", "snt-comsrv-tgwattach-mum-b01"]
private_subnet_routetable = ["rtb-comsrv-tgwattach-mum-01"]

private_subnet_list    = ["10.1.0.0/17", "10.1.128.0/17"]
private_subnet_name    = ["snt-comsrv-bastion-mum-a01", "snt-comsrv-bastion-mum-b01"]
private_subnet_routetable = ["rtb-comsrv-bastion-private-mum-01"]

private_subnet_list    = ["10.1.0.0/17", "10.1.128.0/17"]
private_subnet_name    = ["snt-comsrv-resolvr-mum-a01", "snt-comsrv-resolvr-mum-b01"]
private_subnet_routetable = ["rtb-comsrv-resolvr-private-mum-01"]

private_subnet_list    = ["10.1.0.0/17", "10.1.128.0/17"]
private_subnet_name    = ["snt-comsrv-vpcendpoint-mum-a01", "snt-comsrv-vpcendpoint-mum-b01"]
private_subnet_routetable = ["rtb-comsrv-vpcendpoint-private-mum-01"]

#Shared IDs 
network_account_id = module.aft_account_list.param_name_values["${local.ssm_parameter_path_account_list}account-lz2.0-network"]
network_tgw_id = data.aws_ec2_transit_gateway.primary_network_tgw.id

#vpc cidr for sg_comsrv_endpoint, which want to use vpc endpoints for session manager
#Security group settings
inbound_ports - [443]

rules = [
    {
        cidr_blocks = module.aft_accounts_info.param_name_values[${local.ssm_parameter_path}account-lz2.0-shared-dev/vpc_cidr]
    }
]
}

#Primary Network Details
primary_igw_name = "igw_commsrv_mum-01"
public_nat_rt_name = "rtb-comsrv-publicnat-mum01"
private_tgw_rt_name = "rtb-comsrv-privatetgw-mum01"
private_fw_rt_name = "rtb-comsrc-privatefw-mum01"
tgw-attachment-name = "tgw-comsrv-tgwattach-mum01"
appliance_mode_support = "enable"
tgw_default_rt_association - false

#Shared-Route 53 settings
private_r53_zone_name = "shared.aws.m-cloud.com
private_network_range = ["", ""]
onprem_private_network_range = ["", ""]
account_list = ["", ""]

#--Account Number list contain shared and dev account Number

account_number_list = ["", ""]
rslr_rule_name = "aws.m-cloud.com"
rslr_onprem_rule_name = "corp.ma.com"

# Dev Route 53 settings
private_r53_zone_name_dev = "dev.aws.m-cloud.com"
account_list_dev          = ["Account Name]

# UAT Route 53 settings
private_r53_zone_name_uat = "uat.aws.m-cloud.com"
account_list_dev          = ["Account Name"]

# Prd Route 53 settings
private_r53_zone_name_prd = "prd.aws.m-cloud.com"
account_list_dev          = ["Account Name"]

# ssm.ap-south-1.amazonaws.com Endpoint route 53 setting
private_r53_zone_ssm_endpoint = "ssm.ap-south-1.amazonaws.com"
account_list_endpoint         = ["account"]

# ec2messages.ap-south-1.amazonaws.com Endpoint route r53 setting
private_r53_zone_ec2messages_endpoint = "ec2messages.ap-south-1.amazonaws.com"

# s3 endpoint route 53 setting

private_r53_zone_s3_endpoint = "s3.ap-south-1.amazonaws.com"
s3_account_list_endpoint     = ["accountname"]

#All Oother VPC endpoints 
names of service = ["sns", "sqs", "rds", "elasticache", "backup", "ecr.dkr", "eks", "ecs", "glue", "elasticbeanstalk", "email-smpt"]
all_account_list_vpc = ["account-lz2.0-shared-dev"]
vpc_endpoint_authorization_list = flatten(
    [
        for account_name in local.all_account_list_vpc : [
            for endpoint_name in local.names_of_service : {
                account_name = account_name
                endpoint_hz_id = aws_route53_zone.all_endpoint_route53_zone[endpoint_name].id
            }
        ]
    ]
)

instance_tenancy        = "default"
enable_dns_support      = true
enable_dns_hostnames    = true
assign_generated_ipv6_cidr_block = false

common_tags = {
    application-owner  = "vikas_dubey"
}

ssm_parameter_path        = "/nm/aft/account_customization/output/"
ssm_parameter_path_org_id = "/nm/static/master/org-id"
ssm_parameter_path_account_list  = "/nm/aft/account_id/"

#export outputs of type string

export_output = {
    vpc_id      = aws_vpc.comsrv_vpc.id
    vpc_cidr    = aws_vpc.comsr_vpc.cidr_block
    tgw_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.tgw_network.id 
    ssm_endpoint_id     = aws_route53_zone.ssm_endpoint_route53_zone.id
    ssmmessages_endpoint_id = aws_route53_zone.ssmmessages_endpoint_route53_zone.id
    ec2messages_endpoint_id = aws_route53_zone.ec2messages_endpoint_route53_zone.id
    s3_endpoint_id      = aws_route53_zone.s3_endpoint_id_route53_zone.id
    sns_zone_id     = aws_route53_zone.all_endpoint_route53_zone["sns"].id
    sqs_zone_id     = aws_route53_zone.all_endpoint_route53_zone["sqs"].id
    rds_zone_id = aws_route53_zone.all_endpoint_route53_zone["rds"].id
    elasticache_zone_id = aws_route53_zone.all_endpoint_route53_zone["elasticache"].id
    backup_zone_id = aws_route53_zone.all_endpoint_route53_zone["backup"].id
    ecr_dkr_zone_id = aws_route53_zone.all_endpoint_route53_zone["ecr_dkr"].id
    eks_zone_id = aws_route53_zone.all_endpoint_route53_zone["eks"].id
    ecs_zone_id = aws_route53_zone.all_endpoint_route53_zone["ecs"].id
    glue_zone_id = aws_route53_zone.all_endpoint_route53_zone["glue"].id
    elasticbeanstalk_zone_id = aws_route53_zone.all_endpoint_route53_zone["elasticbeanstalk"].id
    email_smtp_zone_id = aws_route53_zone.all_endpoint_route53_zone["email-smtp"].id
}

#Export outputs of type list
export_list_output = {

}