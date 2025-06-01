resource "aws_instance" "traffic_client" {
  ami           = var.ami_id
  instance_type = var.instance_type   # default t2.micro in variables.tf
  subnet_id     = var.subnet_id       # private or public subnet in your VPC
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              pip3 install requests

              cat << 'EOPY' > /home/ec2-user/traffic_client.py
import requests
import time

target_url = "${var.target_url}"
delay = 2  # seconds

while True:
    try:
        response = requests.get(target_url)
        print(f"Sent request to {target_url}, status code: {response.status_code}")
    except Exception as e:
        print(f"Error: {e}")
    time.sleep(delay)
EOPY

              python3 /home/ec2-user/traffic_client.py
              EOF

  tags = {
    Name = "traffic-client"
  }
}
