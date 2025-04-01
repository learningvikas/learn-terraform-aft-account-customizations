locals {
  account_name      = "account-lz2-common_02"
  primary_vpc_name  = "vpc-comsrv-mum-01"
  primary_region    = "ap-south-1"
  availability_zones = ["${local.primary_region}a", "${local.primary_region}b"]

  primary_vpc_cidr   = "10.166.0.0/16"

  private_tgw_subnet_list    = ["10.166.0.0/28", "10.166.0.16/28"]
  private_tgw_subnet_name    = ["snt-comsrv-tgwattach-mum-a01", "snt-comsrv-tgwattach-mum-b01"]
  private_tgw_rtb_name       = "rtb-comsrv-tgwattach-mum-01"

  private_subnet_list_bastion    = ["10.166.0.32/28", "10.166.0.48/28"]
  private_subnet_name_bastion    = ["snt-comsrv-bastion-mum-a01", "snt-comsrv-bastion-mum-b01"]
  private_subnet_rtb_name_bastion = "rtb-comsrv-bastion-private-mum-01"

  private_subnet_list_resolver    = ["10.166.0.64/28", "10.166.0.80/28"]
  private_subnet_name_resolver    = ["snt-comsrv-resolvr-mum-a01", "snt-comsrv-resolvr-mum-b01"]
  private_subnet_rtb_name_resolver = "rtb-comsrv-resolvr-private-mum-01"

  private_subnet_list_vpcendpoint    = ["10.166.0.128/26", "10.166.0.192/26"]
  private_subnet_name_vpcendpoint    = ["snt-comsrv-vpcendpoint-mum-a01", "snt-comsrv-vpcendpoint-mum-b01"]
  private_subnet_rtb_name_vpcendpoint = "rtb-comsrv-vpcendpoint-private-mum-01"

  # Shared IDs 
  network_tgw_id = data.aws_ec2_transit_gateway.primary_network_tgw.id
  network_account_id  = "155072754388"

  # Security group settings
  inbound_ports = [443]

  rules = [
    {
      cidr_blocks = [module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}account-lz2.0-shared-dev-01/vpc_cidr"]]
    }
  ]

  # Shared-Route 53 settings
  private_r53_zone_name = "shared.aws.m-cloud.com"
  private_network_range = ["10.3.0.0/16"]
  onprem_private_network_range = ["10.164.0.0/16"]
  account_list = ["account-lz2-shared-dev-01"]

  # Dev Route 53 settings
  private_r53_zone_name_dev = "dev.aws.m-cloud.com"
  account_list_dev          = ["account-lz2-shared-dev-01"]

  # ssm.ap-south-1.amazonaws.com Endpoint route 53 setting
  private_r53_zone_ssm_endpoint = "ssm.ap-south-1.amazonaws.com"
  account_list_endpoint         = ["account-lz2-shared-dev-01"]

  # ec2messages.ap-south-1.amazonaws.com Endpoint route r53 setting
  private_r53_zone_ec2messages_endpoint = "ec2messages.ap-south-1.amazonaws.com"

  # VPC endpoints
  names_of_service = ["sns", "sqs", "rds", "elasticache", "backup", "ecr.dkr", "eks", "ecs", "glue", "elasticbeanstalk", "email-smtp"]
  all_account_list_vpc = ["account-lz2.0-shared-dev-01"]
  
  vpc_endpoint_authorization_list = flatten(
    [
      for account_name in local.all_account_list_vpc : [
        for endpoint_name in local.names_of_service : {
          account_name  = account_name
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

  # Export outputs of type string
  export_output = {
    vpc_id      = aws_vpc.comsrv_vpc.id
    vpc_cidr    = aws_vpc.comsrv_vpc.cidr_block
    tgw_attachment_id   = aws_ec2_transit_gateway_vpc_attachment.tgw_network.id 
    ssm_endpoint_id     = aws_route53_zone.ssm_endpoint_route53_zone.id
    ssmmessages_endpoint_id = aws_route53_zone.ssmmessages_endpoint_route53_zone.id
    ec2messages_endpoint_id = aws_route53_zone.ec2messages_endpoint_route53_zone.id
    sns_zone_id     = aws_route53_zone.all_endpoint_route53_zone["sns"].id
    sqs_zone_id     = aws_route53_zone.all_endpoint_route53_zone["sqs"].id
    rds_zone_id = aws_route53_zone.all_endpoint_route53_zone["rds"].id
    elasticache_zone_id = aws_route53_zone.all_endpoint_route53_zone["elasticache"].id
    backup_zone_id = aws_route53_zone.all_endpoint_route53_zone["backup"].id
    ecr_dkr_zone_id = aws_route53_zone.all_endpoint_route53_zone["ecr.dkr"].id
    eks_zone_id = aws_route53_zone.all_endpoint_route53_zone["eks"].id
    ecs_zone_id = aws_route53_zone.all_endpoint_route53_zone["ecs"].id
    glue_zone_id = aws_route53_zone.all_endpoint_route53_zone["glue"].id
    elasticbeanstalk_zone_id = aws_route53_zone.all_endpoint_route53_zone["elasticbeanstalk"].id
    email_smtp_zone_id = aws_route53_zone.all_endpoint_route53_zone["email-smtp"].id
  }

  # Export outputs of type list
  export_list_output = {}
}
