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
  length  = 5
  special = true
}

resource "aws_eks_cluster" "wk22_cluster" {
  name     = "Wk22-cluster-${random_string.random.id}"
  role_arn = aws_iam_role.project_cluster.arn

  vpc_config {
    security_group_ids      = [aws_security_group.eks_sg.id]
    subnet_ids              = var.public_subnets
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
  }

  depends_on = [
    aws_iam_role_policy_attachment.luit-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.luit-AmazonEKSVPCResourceController,
  ]
}

#EKS-worker-nodes

resource "aws_eks_node_group" "wk22_node" {
  cluster_name    = aws_eks_cluster.wk22_cluster.name
  node_group_name = "worker_nodes"
  node_role_arn   = aws_iam_role.project_node.arn
  subnet_ids      = var.public_subnets

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
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
  description = "Communication with cluster API server & cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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


