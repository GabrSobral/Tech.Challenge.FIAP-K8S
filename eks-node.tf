# 1. Launch Template: A peça que falta para corrigir o erro de Metadata
resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = "" # Deixe vazio, o EKS preenche automaticamente com a AMI correta
  instance_type = var.instance_type

  # --- A CORREÇÃO CRÍTICA ESTÁ AQUI ---
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Força IMDSv2 (Segurança)
    http_put_response_hop_limit = 2          # Aumenta o limite de saltos para que os Pods alcancem o metadata
    instance_metadata_tags      = "enabled"
  }
  # ------------------------------------

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 2. O Node Group Atualizado
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project_name}-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_subnet.subnet_public[*].id
  
  # removemos instance_types direto daqui, pois definimos no launch_template
  # disk_size também é controlado melhor pelo template, mas o padrão é 20GB. 
  # Se precisar de 50GB, adicione um bloco 'block_device_mappings' no template acima.

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Conecta o Node Group ao Template criado acima
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy
  ]
}

# 3. IAM Role (Mantive a sua, apenas removi o sts:TagSession que é desnecessário aqui)
resource "aws_iam_role" "node_role" {
  name = "${var.project_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 4. Policies (Permanecem iguais)
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}