resource "aws_route_table" "route_table_tech_challenge" {
  vpc_id = aws_vpc.vpc_tech_challenge.id

  # --- REMOVA O BLOCO DO GATEWAY "local" ---
  # A AWS cria isso automaticamente e não deixa o Terraform gerenciar.

  # Mantenha apenas a rota para a Internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_tech_challenge.id
  }

  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.route_table_tech_challenge.id
}