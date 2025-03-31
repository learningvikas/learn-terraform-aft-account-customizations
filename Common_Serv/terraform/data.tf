#AFT management account id
data "aws_caller_identity" "aft_management_account" {
    provider = aws.aft_management_account
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#Filter Name Reference: https://docs.aws.amazon/AWSEC2/latest/APIReference/API_DescribeSubnets.html

data "aws_subnet" "private_subnet_aza" {
    filter {
        name = "vpc-id"
        values = [aws_vpc.comsrv_vpc.id]
    }

     filter {
        name = "availability_zones"
        values = [local.availability_zones[0]]
    }

      filter {
        name = "availability_zones"
        values = [local.private_subnet_list_vpcendpoint[0]]
    }
}

data "aws_subnet" "private_subnet_azb" {
    filter {
        name = "vpc-id"
        values = [aws_vpc.comsrv_vpc.id]
    }

      filter {
        name = "availability_zones"
        values = [local.availability_zones[1]]
    }

     filter {
        name = "availability_zones"
        values = [local.private_subnet_list_vpcendpoint[1]]
    }
}