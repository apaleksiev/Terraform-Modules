resource "aws_vpc" "cirrus" {
	cidr_block		= "172.20.0.0/16"
	enable_dns_support	= true
	enable_dns_hostnames	= true

	tags = {
		Name = "${var.app_name}-${var.app_env}-vpc"
	}
}

resource "aws_internet_gateway" "cirrus_igw" {
	vpc_id	= aws_vpc.cirrus.id

	tags = {
		Name = "${var.app_name}-${var.app_env}-igw"
	}
}

resource "aws_subnet" "public" {
	vpc_id			= aws_vpc.cirrus.id
	count			= length(var.public_subnets)
	cidr_block		= var.public_subnets[count.index]
	map_public_ip_on_launch	= true
	availability_zone	= var.availability_zones[count.index]

	tags = {
		Name = "${var.app_name}-${var.app_env}-public-net"
	}
}

resource "aws_subnet" "private" {
	vpc_id			= aws_vpc.cirrus.id
	count			= length(var.public_subnets)
	cidr_block		= var.private_subnets[count.index]
	map_public_ip_on_launch	= true
	availability_zone	= var.availability_zones[count.index]

	tags = {
		Name = "${var.app_name}-${var.app_env}-private-net"
	}
}

resource "aws_default_route_table" "default_rt" {
	default_route_table_id	= aws_vpc.cirrus.main_route_table_id

	tags = {
		Name = "${var.app_name}-${var.app_env}-public"
	}
}

resource "aws_route" "route_igw" {
	count			= length(var.public_subnets)
	route_table_id		= aws_default_route_table.default_rt.id
	destination_cidr_block	= "0.0.0.0/0"
	gateway_id		= aws_internet_gateway.cirrus_igw.id

	timeouts {
		create = "5m"
	}
}

resource "aws_route_table_association" "public_rta" {
	count		= length(var.public_subnets)
	subnet_id	= element(aws_subnet.public.*.id, count.index)
	route_table_id	= aws_default_route_table.default_rt.id
}

resource "aws_route_table" "private_rt" {
	vpc_id	= aws_vpc.cirrus.id

	tags = {
		Name = "${var.app_name}-${var.app_env}-private"
	}
}

resource "aws_route_table_association" "private_rta" {
	count		= length(var.private_subnets)
	subnet_id	= element(aws_subnet.private.*.id, count.index)
	route_table_id	= aws_route_table.private_rt.id
}

resource "aws_eip" "natgw_eip" {
	vpc = true

	tags = {
		Name = "${var.app_name}-${var.app_env}-natgw-eip"
	}
}

resource "aws_nat_gateway" "cirrus_natgw" {
	allocation_id	= aws_eip.natgw_eip.id
	subnet_id	= aws_subnet.public.0.id

	tags = {
		Name = "${var.app_name}-${var.app_env}-natgw"
	}
}

resource "aws_route" "private_nat_gateway" {
	route_table_id		= aws_route_table.private_rt.id
	destination_cidr_block	= "0.0.0.0/0"
	nat_gateway_id		= aws_nat_gateway.cirrus_natgw.id
}
