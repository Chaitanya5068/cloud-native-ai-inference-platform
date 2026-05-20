# Data source to get latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = [var.ubuntu_ami]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair for SSH Access
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file("../distributed-ai-inference-platform.pub")

  tags = {
    Name = "${var.project_name}-key-pair"
  }
}

# API Server (Public EC2)
resource "aws_instance" "api_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.api_sg.id]

  # Enable Public IP
  associate_public_ip_address = true

  # SSH Key Pair
  key_name = aws_key_pair.main.key_name

  # Install Docker automatically
  user_data = base64encode(file("${path.module}/../scripts/install_docker.sh"))

  tags = {
    Name = "${var.project_name}-api-server"
  }

  depends_on = [aws_internet_gateway.main]
}

# Worker Server (Private EC2)
resource "aws_instance" "worker_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.worker_sg.id]

  # No Public IP
  associate_public_ip_address = false

  # SSH Key Pair
  key_name = aws_key_pair.main.key_name

  # Install Docker automatically
  user_data = base64encode(file("${path.module}/../scripts/install_docker.sh"))

  tags = {
    Name = "${var.project_name}-worker-server"
  }

  depends_on = [aws_nat_gateway.main]
}