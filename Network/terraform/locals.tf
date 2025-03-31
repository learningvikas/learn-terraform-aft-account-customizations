locals {
  account_name      = "account-lz2-network"
  primary_vpc_name  = "vpc-network-mum-01"
  primary_region    = "ap-south-1"
  availability_zones = ["${local.primary_region}a", "${local.primary_region}b"]
  
  primary_vpc_cidr   = "10.1.0.0/16"

#shared_dev_vpc_cidr = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path}account-lz2.0-shared-dev/vpc_cidr"]
	
#otherofc_s2s_route = "CIDR Range of OtherOfc"
#otherofc2_s2s_route = "CIDR Range of OtherOfc"
#vpn_log_retention_days = 1
#cloudwatch_logs_export_bucket = "s3-network-vpn-logs"
#log_archive_account_id = module.aft_accounts_info.param_name_values["${local.ssm_parameter_path_account_list}account-lz2.0-log_archive]
#vpn_log_export_rate = "rate(4 hours)"
#enable_vpn_log_export = true
#otherofc_vpntgw_attachment_id = 
#otherofc2_vpntgw_attachment_id = 
#dx_pri_vpntgw_attachment_id = 
#dx_sec_vpntgw_attachment_id = 
#azure_vpntgw_attachment_id = 
#gcp_vpntgw_attachment_id = 

#azure_a_cidr = "Azure CIDR Range"
#azure_b_cidr = "Azure CIDR Range"
#azure_c_cidr = "Azure CIDR Range"
#gcp_a_cidr = "gcp CIDR Range"
#dms_dev_a_cidr = "DMS Dev CIDR Range"
#dms_uat_a_cidr = "DMS Uat CIDR Range"
#dms_prd_a_cidr = "DMS Prd CIDR Range"

#Other Endpoint association

#names_of_asso_service = [
#  "sns_zone_id",
#  "sqs_zpne_id",
#  "rds_zone_id",
#  "elasticache_zone_id",
#  "backup_zone_id",
#  "ecr_dkr_zone_id",
#  "eks_zone_id",
#  "ecs_zone_id",
#  "glue_zone_id",
#  "elasticbeanstalk_zone_id",
#  "email_smtp_zone_id"
#]

#vpc_endpoint_ssm_parameter_path = "/nm/aft/account_customization/output/account-lz2-common/"

  
  private_subnet_list    = ["10.1.0.0/17", "10.1.128.0/17"]
  private_subnet_name    = ["snt-nw-tgwattach-mum-a01", "snt-nw-tgwattach-mum-b01"]
  private_subnet_routetable = ["rtb-nw-private-mum-a01", "rtb-nw-private-mum-b01"]
  
  instance_tenancy             = "default"
  enable_dns_support           = true
  enable_dns_hostnames         = true
  assign_generated_ipv6_cidr_block = false
  
  tgw_name       = "tgw-network-mum-01"
  tgw_aws_asn    = 65532
  root_ou_arn    = "arn:aws:organizations::${module.aft_account_list.param_name_values["${local.ssm_parameter_path_account_list}awscontroltower]}:organization/${data.aws_ssm_parameter.master_org_id.value}"
  
  common-tags = {
     requester-name         = "vikas dubey"
	 }
  ssm_parameter_path        = "/nm/aft/account_customization/output/"
  ssm_parameter_path_org_id = "/nm/static/master/org-id"
  ssm_parameter_path_account_list  = "/nm/aft/account_id/"
  
  #export outputs of type string
  export_output = {
         vpc_id            = aws_vpc.network_vpc.id
	       vpc_cidr          = aws_vpc.network_vpc.cidr_block
         tgw_id            = module.transit_gateway.ec2_transit_gateway_id
         tgw_attachment_id = aws_ec2_transit_gateway_vpc_attachment.network_vpc.id
  }  
  #export outputs of type list
  export_list_output = {
  
  }
}