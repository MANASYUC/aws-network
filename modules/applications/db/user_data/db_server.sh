#!/bin/bash
# ====================================
# DATABASE TIER BOOTSTRAP SCRIPT
# ====================================

# Update system
yum update -y

# Install MySQL
yum install -y mysql-server

# Format and mount additional storage
if [ -e /dev/xvdf ]; then
    mkfs.ext4 /dev/xvdf
    mkdir -p /var/lib/mysql-data
    mount /dev/xvdf /var/lib/mysql-data
    echo '/dev/xvdf /var/lib/mysql-data ext4 defaults 0 0' >> /etc/fstab
    chown mysql:mysql /var/lib/mysql-data
fi

# Configure MySQL
systemctl start mysqld
systemctl enable mysqld

# Get temporary root password
TEMP_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Set root password and secure installation
mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password << 'EOF'
ALTER USER 'root'@'localhost' IDENTIFIED BY 'TempPassword123!';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

# Create application database and user
mysql -u root -p'TempPassword123!' << 'EOF'
CREATE DATABASE appdb;
CREATE USER 'appuser'@'%' IDENTIFIED BY 'AppPassword123!';
GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'%';
FLUSH PRIVILEGES;

USE appdb;
CREATE TABLE health_check (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    environment VARCHAR(50)
);

INSERT INTO health_check (status, environment) VALUES ('healthy', '${environment}');
EOF

# Configure MySQL to listen on all interfaces
sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=${db_port}/tcp
firewall-cmd --reload

# Restart MySQL to apply configuration changes
systemctl restart mysqld

# Log deployment
echo "$(date): Database tier instance deployed in ${environment} environment on port ${db_port}" >> /var/log/deployment.log 