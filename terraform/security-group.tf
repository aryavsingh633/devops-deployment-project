resource "aws_security_group" "web_sg" {
  name        = "devops-web-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main.id

  # SSH access - only from your IP
  ingress {
    description = "SSH access from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["49.43.118.21/32"]
  }

  # HTTP access - public website
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-web-security-group"
  }
}