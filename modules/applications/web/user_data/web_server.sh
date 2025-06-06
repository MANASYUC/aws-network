#!/bin/bash
# ====================================
# WEB TIER BOOTSTRAP SCRIPT
# ====================================

# Update system
yum update -y

# Install Apache web server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create a simple index page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Network Architecture - Web Tier</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #232f3e; color: white; padding: 20px; border-radius: 5px; }
        .content { margin: 20px 0; }
        .info { background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 10px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🌐 AWS Network Architecture</h1>
        <h2>Web Tier - Environment: ${environment}</h2>
    </div>
    
    <div class="content">
        <div class="info">
            <h3>Server Information</h3>
            <p><strong>Instance ID:</strong> <span id="instance-id">Loading...</span></p>
            <p><strong>Availability Zone:</strong> <span id="az">Loading...</span></p>
            <p><strong>Private IP:</strong> <span id="private-ip">Loading...</span></p>
            <p><strong>Timestamp:</strong> <span id="timestamp">$(date)</span></p>
        </div>
        
        <div class="info">
            <h3>Health Check</h3>
            <p>✅ Web server is running and healthy</p>
            <p>✅ Load balancer health check endpoint active</p>
        </div>
    </div>

    <script>
        // Fetch instance metadata
        fetch('/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(() => document.getElementById('instance-id').textContent = 'N/A');
            
        fetch('/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(() => document.getElementById('az').textContent = 'N/A');
            
        fetch('/latest/meta-data/local-ipv4')
            .then(response => response.text())
            .then(data => document.getElementById('private-ip').textContent = data)
            .catch(() => document.getElementById('private-ip').textContent = 'N/A');
    </script>
</body>
</html>
EOF

# Set proper permissions
chown -R apache:apache /var/www/html/
chmod -R 755 /var/www/html/

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

# Log deployment
echo "$(date): Web tier instance deployed in ${environment} environment" >> /var/log/deployment.log 