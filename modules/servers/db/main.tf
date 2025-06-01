resource "aws_instance" "db" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y mysql-server
              sudo systemctl start mysql
              sudo mysql -e "CREATE DATABASE myapp;"
              sudo mysql -e "CREATE USER 'appuser'@'%' IDENTIFIED BY 'password';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON myapp.* TO 'appuser'@'%';"
              sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
              sudo systemctl restart mysql
              EOF

  tags = {
    Name = "DBServer"
  }
}
