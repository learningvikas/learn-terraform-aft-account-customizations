data "aws_ami" "amazon_linux-2" {
    most_recent = true
    owners      = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm*"]
    }
}

#keypair's Are fetched and passed
data "aws_key_pair" "kp-comsrv-linux" {
    key_name = "kp-comsrv-linux"

    filter {
        name = "key-name"
        values = ["kp-comsrv-linux"]
    }
}

data "aws_subnet" "comsrv_private_subnet_aza {
    filter {
        name = "vpc-id"
        values = [aws_vpc.comsrv_vpc.id]
    }

    filter {
        name = "availability-zone"
        values = [local.availability_zones[0]]
    }

     filter {
        name = "cidr-block"
        values = [local.private_subnet_list_bastion[0]]
    }
}

resource "aws_iam_role" "role" {
    name = "bastion_iam_role"
    path = "/"

    assume_role_policy = <<EOF
    {
        "Version" "2012-10-17",
        "Statement": [
            {
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "ec2.amazonaws.com"
                },
                "Effect": "Allow",
                "Sid": ""
            }
        ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test_attach" {
    role        = aws_iam_role.role.name
    policy_arn  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "test_1_profile" {
    name = "comsrv_iam_role_instance_profile"
    role = aws_iam_role.role.name
    depends_on = [
        aws_iam_role.role
    ]
}

resource "aws_security_group" "sgp_comsrv_bastion_linux" {
    name    = "sgp_comsrv_bastion"
    description = "Allow TLS Inbound Traffic"
    vpc_id = "vpc_id"

    tags = {
        Name = "allow_tls"
    }
    depends_on = [
        aws_iam_instance_profile.test_1_profile
    ]
}

resource "aws_instance" "web" {
    ami = data.aws_ami.amazon-linux-2.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sgp_comsrv_bastion_linux.id]

    subnet_id   = data.aws_subnet.comsrv_private_subnet_aza.id
    associate_public_ip_address = false

    iam_instance_profile = aws_iam_instance_profile.test_1_profile.name
    key_name = data.aws_key_pair.kp-comsrv-linux.key_name
    tags    = local.common_tags

    depends_on = [
        aws_security_group.sgp_comsrv_bastion_linux,
        aws_iam_instance_profile.test_1_profile
    ]

}