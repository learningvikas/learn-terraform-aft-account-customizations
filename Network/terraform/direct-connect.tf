#Direct Connect gateway
resource "aws_dx_gateway" "dxg_network_prd" {
    name        = ""
    amazon_side_asn     = "64513"
}

resource "aws_dx_gateway" "dxg_network_Sec" {
    name        = ""
    amazon_side_asn     ="64513"
}

#---------------------------------------------------------------
#Virtual Interface

resource "aws_dx_transit_virtual_interface" "primary" {
    connection_id = data.aws_dx_connection.pri_connection_id.id

    dx_gateway_id = aws_dx_gateway.dxg_network_pri.id
    name          = "tf-transit-vif"
    vlan          = 1120
    address_family = "ipv4"
    bgp_asn        = 4755
    bg_auth_key    = data.aws_ssm_parameter.dxg_virtual_bgp_auth.value
    amazon_address = "IP of AWS"
    customer_address = "IP of customer"

    depends_on = [
        aws_dx_gateway.dxg_network_pri
    ]
}

resource "aws_dx_transit_virtual_interface" "secondary" {
    connection_id = data.aws_dx_connection.sec_connection_id.id

    dx_gateway_id = aws_dx_gateway.dxg_network_sec.id
    name          = "tf-transit-vif"
    vlan          = 1120
    address_family = "ipv4"
    bgp_asn        = 4755
    bg_auth_key    = data.aws_ssm_parameter.dxg_virtual_bgp_auth.value
    amazon_address = "IP of AWS"
    customer_address = "IP of customer"

    depends_on = [
        aws_dx_gateway.dxg_network_sec
    ]
}

#------------------------------------------------------------------
#DX association with transit gateway

resource "aws_dx_gateway_association" "dx_tgw_association_pri" {
    dx_gateway_id         = aws_dx_gateway.dxg_network_pri.id
    associated_gateway_id = module.transit_gateway.ec2_transit_gateway.id
    allowed_prefixes = [
        "IP",
        "IP2",
        "IP3"
    ]
}

resource "aws_dx_gateway_association" "dx_tgw_association_sec" {
    dx_gateway_id         = aws_dx_gateway.dxg_network_sec.id
    associated_gateway_id = module.transit_gateway.ec2_transit_gateway.id
    allowed_prefixes = [
        "IP",
        "IP2",
        "IP3"
    ]
}