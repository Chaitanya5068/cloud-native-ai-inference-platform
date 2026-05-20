# Security Group for API Server (Public)
resource "aws_security_group" "api_sg" {
  name        = "${var.project_name}-api-sg"
  description = "Security group for API server in public subnet"
  vpc_id      = aws_vpc.main.id

  # SSH Access (from your IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  # HTTP Access (from anywhere)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Access (from anywhere)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-api-sg"
  }
}

# Security Group for Worker Server (Private)
resource "aws_security_group" "worker_sg" {
  name        = "${var.project_name}-worker-sg"
  description = "Security group for worker server in private subnet"
  vpc_id      = aws_vpc.main.id

  # Allow all traffic from VPC (internal communication)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow ICMP for ping
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Outbound traffic (allow all)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-worker-sg"
  }
}

# Allow API to communicate with Worker
resource "aws_security_group_rule" "api_to_worker" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 9000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker_sg.id
  source_security_group_id = aws_security_group.api_sg.id

  lifecycle {
    create_before_destroy = true
  }
}
