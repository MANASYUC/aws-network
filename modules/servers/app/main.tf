resource "aws_instance" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y python3-pip
              pip3 install Flask==2.3.3
              mkdir -p /opt/test-app
              cd /opt/test-app
              nohup python3 app.py > /opt/test-app/app.log 2>&1 &
              EOF


  tags = {
    Name = "AppServer"
  }
}
