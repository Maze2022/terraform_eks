# ------- eks/main.tf

# IAM role for cluster
resource "aws_iam_role" "project_cluster" {
  name = "tf-eks-project-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "luit-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.project_cluster.name
}

resource "aws_iam_role_policy_attachment" "luit-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.project_cluster.name
}

#EKS-WORKER-NODES

# IAM role for worker nodes
resource "aws_iam_role" "project_node" {
  name = "tf-eks-project-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "luit-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.project_node.name
}

resource "aws_iam_role_policy_attachment" "luit-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.project_node.name
}

resource "aws_iam_role_policy_attachment" "luit-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.project_node.name
}


# EKS Cluster

resource "random_string" "random" {
  length           = 5
  special          = true
}

resource "aws_eks_cluster" "wk22_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.project_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_sg.id]
    subnet_ids = aws_subnet.eks_public_subnets[*].id[count.index]
  }

  depends_on = [
    aws_iam_role_policy_attachment.luit-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.luit-AmazonEKSVPCResourceController,
  ]
  
  tags = {
    Name = "Week21_vpc-${random_string.random.id}"
}

#EKS-worker-nodes

resource "aws_eks_node_group" "wk22_node" {
  cluster_name    = var.cluster_name
  node_group_name = "demo"
  node_role_arn   = aws_iam_role.project_node.arn
  subnet_ids      = aws_subnet.eks_public_subnets[*].id

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.luit-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.luit-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.luit-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}


# eks security group
resource "aws_security_group" "eks_sg" {
  name        = "tf_eks_cluster_sg"
  description = ""
  vpc_id      = var.vpc_id

ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_group_id = [aws_security_group.eks_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "tf_eks_cluster_sg"
  }
}


