#!/bin/bash
# ====================================
# ML WEB SERVER SETUP SCRIPT
# ====================================
# Sets up Apache web server and custom ML data endpoints
# Environment: ${environment}
# ====================================

# Update system
yum update -y

# Install Apache web server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create simple web pages
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>ML Training Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>ML Network Anomaly Detection - Web Server</h1>
        <p>Environment: ${environment}</p>
        <p>This server generates data for ML training purposes.</p>
    </div>
    <h2>Available Endpoints:</h2>
    <ul>
        <li><a href="/api/users">GET /api/users</a> - User data API</li>
        <li><a href="/api/login">POST /api/login</a> - Authentication endpoint</li>
        <li><a href="/api/status">GET /api/status</a> - System status</li>
    </ul>
</body>
</html>
EOF

# Install Node.js for API endpoints
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs

# Create API server directory
mkdir -p /opt/api-server

# Create API server application
cat > /opt/api-server/server.js << 'EOF'
const http = require('http');
const url = require('url');

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const path = parsedUrl.pathname;
    
    // Set CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Content-Type', 'application/json');
    
    if (path === '/api/users') {
        res.writeHead(200);
        res.end(JSON.stringify({
            users: [
                { id: 1, name: "Alice", role: "admin", login_time: new Date() },
                { id: 2, name: "Bob", role: "user", login_time: new Date() },
                { id: 3, name: "Charlie", role: "guest", login_time: new Date() }
            ],
            timestamp: new Date(),
            server: "ml-web-server",
            environment: "${environment}"
        }));
    } else if (path === '/api/status') {
        res.writeHead(200);
        res.end(JSON.stringify({
            status: "healthy",
            uptime: process.uptime(),
            memory: process.memoryUsage(),
            timestamp: new Date(),
            environment: "${environment}"
        }));
    } else {
        res.writeHead(404);
        res.end(JSON.stringify({ error: "Not found" }));
    }
});

server.listen(8080, () => {
    console.log('API server running on port 8080');
});
EOF

# Create systemd service for API server
cat > /etc/systemd/system/api-server.service << 'EOF'
[Unit]
Description=ML API Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/api-server
ExecStart=/usr/bin/node server.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Set permissions
chown -R ec2-user:ec2-user /opt/api-server

# Start services
systemctl daemon-reload
systemctl start api-server
systemctl enable api-server

# Create log rotation for web server
cat > /etc/logrotate.d/httpd-ml << 'EOF'
/var/log/httpd/*log {
    daily
    rotate 7
    missingok
    compress
    notifempty
    postrotate
        systemctl reload httpd > /dev/null 2>/dev/null || true
    endscript
}
EOF

echo "ML Web Server setup complete for environment: ${environment}" 