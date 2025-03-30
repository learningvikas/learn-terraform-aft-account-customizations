#AFT Management account id
data "aws_caller_identity" "aft_management_account" {
    provider = aws.aft_management_account
}

data "aws_caller_identity" "current" {}

data "aws_region "current" {}

#data "aws_dx_connection" "sec_connection_id" {
#    name = ""
#}

#data "aws_dx_connection" "pri_connection_id" {
#    name = ""
#}

#data "aws_ssm_parameter" "dxg_virtual_bgp_auth" {
#    name = ""
#}

#data "aws_iam_role" "flow_log" {
#    name = "FlowLogHubAssumeRole"
#}

