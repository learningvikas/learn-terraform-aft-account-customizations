resource "aws_customer_gateway" "cust_gateway {
    for_each = var.cgw_public_ip
    bgp_asn = var.cgw_bgp_asn
    ip_address = each.value
    type = "ipsec.1"

    tags = merge(
        {
            "Name" = "${each.key}
        },
        var.cgw_tags
    )
}

resource "aws_vpn_connection" "s2s_vpngateway" {
    customer_gateway_id = aws_customer_gateway.cust_gateway[var.cgw_vpn_association].id
    transit_gateway.id = var.tgw_id
    static_routes_only = var.enable_static_routing
    type = "ipsec.1"

    tunnel1_log_options {
        cloudwatch_log_options {
            log_enabled = var.enable_vpn_logging
            log_group_arn = var.cloudwatch_group_vpn_log
            log_output_format = var.vpn_log_format
        }
    }

    tunnel2_log_options {
        cloudwatch_log_options {
            log_enabled = var.enable_vpn_logging
            log_group_arn = var.cloudwatch_group_vpn_log
            log_output_format = var.vpn_log_format
        }
    }

    tags = var.vpn_tags

    depends_on = [
        aws_customer_gateway.cust_gateway
    ]

    lifecycle {
        ignore_changes = all
    }
}

resource "aws_ec2_tag" "tgw_vpn_attachment" {
    resource_id = aws_vpn_connection.s2s_vpngateway.transit_gateway_attachment_id
    key = "Name"
    value = var.vpn_tags["Name"]
}

