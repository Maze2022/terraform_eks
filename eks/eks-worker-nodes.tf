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


#Worker-nodes

resource "aws_eks_node_group" "wk22_node" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "worker_nodes"
  node_role_arn   = aws_iam_role.project_node.arn
  subnet_ids      = var.public_subnets

  remote_access {
    ec2_ssh_key               = var.key_pair
    source_security_group_ids = [aws_security_group.eks_sg.id]
  }

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

