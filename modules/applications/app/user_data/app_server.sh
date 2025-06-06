#!/bin/bash
# ====================================
# APPLICATION TIER BOOTSTRAP SCRIPT
# ====================================

# Update system
yum update -y

# Install Java and development tools
yum install -y java-11-openjdk java-11-openjdk-devel
yum groupinstall -y "Development Tools"

# Install Node.js (alternative runtime)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Create application user
useradd -m -s /bin/bash appuser

# Create application directory
mkdir -p /opt/app
chown appuser:appuser /opt/app

# Create a simple application
cat > /opt/app/app.js << 'EOF'
const http = require('http');
const os = require('os');

const port = ${app_port};
const hostname = '0.0.0.0';

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'application/json');
  
  const response = {
    message: 'AWS Network Architecture - Application Tier',
    environment: '${environment}',
    hostname: os.hostname(),
    timestamp: new Date().toISOString(),
    port: port,
    status: 'healthy'
  };
  
  res.end(JSON.stringify(response, null, 2));
});

server.listen(port, hostname, () => {
  console.log(`App server running at http://$${hostname}:$${port}/`);
  console.log(`Environment: ${environment}`);
});
EOF

# Set permissions
chown appuser:appuser /opt/app/app.js

# Create systemd service
cat > /etc/systemd/system/appserver.service << 'EOF'
[Unit]
Description=Application Server
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the application service
systemctl daemon-reload
systemctl start appserver
systemctl enable appserver

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-port=${app_port}/tcp
firewall-cmd --reload

# Log deployment
echo "$(date): App tier instance deployed in ${environment} environment on port ${app_port}" >> /var/log/deployment.log 