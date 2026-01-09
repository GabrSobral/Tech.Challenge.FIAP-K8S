resource "aws_subnet" "subnet_public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc_tech_challenge.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_tech_challenge.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "subnet_private" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc_tech_challenge.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_tech_challenge.cidr_block, 4, count.index + 3)
  map_public_ip_on_launch = false
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}
