resource "aws_cloudwatch_log_group" "azure_s2s_vpn" {
    name        = "/nm/aws/otherofc_s2s_vpn"
    retention_in_days = local.vpn_log_retention_days
    tags        = merge(local.common_tags, {ExportToS3} = "true")
}

resource "aws_cloudwatch_log_group" "gcp_s2s_vpn" {
    name        = "/nm/aws/otherofc_s2s_vpn"
    retention_in_days = local.vpn_log_retention_days
    tags        = merge(local.common_tags, {ExportToS3} = "true")
}

resource "aws_cloudwatch_log_group" "azure_s2s_vpn1" {
    name        = "/nm/aws/otherofc_s2s_vpn"
    retention_in_days = local.vpn_log_retention_days
    tags        = merge(local.common_tags, {ExportToS3} = "true")
}

resource "aws_cloudwatch_log_group" "gcp_delhi_s2s_vpn" {
    name        = "/nm/aws/otherofc_s2s_vpn"
    retention_in_days = local.vpn_log_retention_days
    tags        = merge(local.common_tags, {ExportToS3} = "true")
}

module "azure_s2s_vpn" {
    source = "../../modules/vpn"

    cgw_bgp_asn     = 65000
    cgw_public_ip   = { "nm_cgw_azure : customer side ip}
    cgw_tags        = merge(local.common_tags, { "gateway-routing" = "static" })
    cgw_vpn_association = "nm_cgw_otherofc1"
    enable_static_routing = true
    tgw_id              = module.transit_gateway.ec2-transit_gateway.id
    vpn_tags            = merge(local.common_tags, { Name = "nm-s2s-azure" })
    enable_vpn_logging  = true
    vpn_log_format      = "json"
    cloudwatch_group_vpn_log = aws_cloudwatch_log_group.azure_s2s_vpn.arn
}

module "gcp_s2s_vpn" {
    source = "../../modules/vpn"

    cgw_bgp_asn     = 65000
    cgw_public_ip   = { "nm_cgw_azure : customer side ip}
    cgw_tags        = merge(local.common_tags, { "gateway-routing" = "static" })
    cgw_vpn_association = "nm_cgw_otherofc1"
    enable_static_routing = true
    tgw_id              = module.transit_gateway.ec2-transit_gateway.id
    vpn_tags            = merge(local.common_tags, { Name = "nm-s2s-gcp" })
    enable_vpn_logging  = true
    vpn_log_format      = "json"
    cloudwatch_group_vpn_log = aws_cloudwatch_log_group.gcp_s2s_vpn.arn
}

module "azure_s2s_vpn1" {
    source = "../../modules/vpn"

    cgw_bgp_asn     = 65000
    cgw_public_ip   = { "nm_cgw_azure : customer side ip}
    cgw_tags        = merge(local.common_tags, { "gateway-routing" = "static" })
    cgw_vpn_association = "nm_cgw_otherofc1"
    enable_static_routing = true
    tgw_id              = module.transit_gateway.ec2-transit_gateway.id
    vpn_tags            = merge(local.common_tags, { Name = "nm-s2s-azure1" })
    enable_vpn_logging  = true
    vpn_log_format      = "json"
    cloudwatch_group_vpn_log = aws_cloudwatch_log_group.azure_s2s_vpn1.arn
}

module "gcp_delhi_s2s_vpn" {
    source = "../../modules/vpn"

    cgw_bgp_asn     = 65000
    cgw_public_ip   = { "nm_cgw_azure : customer side ip}
    cgw_tags        = merge(local.common_tags, { "gateway-routing" = "static" })
    cgw_vpn_association = "nm_cgw_otherofc1"
    enable_static_routing = true
    tgw_id              = module.transit_gateway.ec2-transit_gateway.id
    vpn_tags            = merge(local.common_tags, { Name = "nm-s2s-gcp_delhi1" })
    enable_vpn_logging  = true
    vpn_log_format      = "json"
    cloudwatch_group_vpn_log = aws_cloudwatch_log_group.gcp_delhi_s2s_vpn.arn
}