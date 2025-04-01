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