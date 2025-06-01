resource "aws_instance" "app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y python3 python3-pip
              pip3 install flask mysql-connector-python
              cat <<EOT > /home/ubuntu/app.py
              from flask import Flask
              app = Flask(__name__)
              @app.route('/')
              def hello():
                  return "App Server Running"
              if __name__ == '__main__':
                  app.run(host='0.0.0.0', port=80)
              EOT
              nohup python3 /home/ubuntu/app.py &
              EOF

  tags = {
    Name = "AppServer"
  }
}
