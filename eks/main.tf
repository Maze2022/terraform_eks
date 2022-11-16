# ------- eks/main.tf

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



resource "random_string" "random" {
  length           = 5
  special          = true
}

resource "aws_eks_cluster" "wk22_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.project_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_sg.id]
    subnet_ids = aws_subnet.eks_public_subnets.*.id[count.index]
  }

  depends_on = [
    aws_iam_role_policy_attachment.luit-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.luit-AmazonEKSVPCResourceController,
  ]
}

# eks security group
resource "aws_security_group" "eks_sg" {
  name        = "tf_eks_cluster_sg"
  description = ""
  vpc_id      = aaws_vpc.eks_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
