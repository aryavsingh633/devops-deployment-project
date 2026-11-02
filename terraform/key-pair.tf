resource "aws_key_pair" "deployer" {
  key_name   = "devops-project-key"
  public_key = file(pathexpand("~/.ssh/devops-project-key.pub"))

  tags = {
    Name = "devops-project-key"
  }
}