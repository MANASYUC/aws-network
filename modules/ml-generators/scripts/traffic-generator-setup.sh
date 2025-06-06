#!/bin/bash
# ====================================
# ML TRAFFIC GENERATOR SETUP SCRIPT
# ====================================
# Sets up automated traffic generation for ML training data
# Target: ${target_web_server}
# Environment: ${environment}
# ====================================

# Update system
yum update -y

# Install required packages
yum install -y curl wget jq htop

# Install Python for traffic generation scripts
yum install -y python3 python3-pip

# Create traffic generation directory
mkdir -p /opt/ml-traffic-gen

# Create traffic generation script
cat > /opt/ml-traffic-gen/generate_traffic.py << 'EOF'
#!/usr/bin/env python3
import requests
import time
import random
import json
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/traffic_generator.log'),
        logging.StreamHandler()
    ]
)

TARGET_SERVER = "${target_web_server}"
ENVIRONMENT = "${environment}"

def generate_normal_traffic():
    """Generate normal user traffic patterns"""
    endpoints = [
        f"http://{TARGET_SERVER}/",
        f"http://{TARGET_SERVER}:8080/api/users", 
        f"http://{TARGET_SERVER}:8080/api/status"
    ]
    
    try:
        endpoint = random.choice(endpoints)
        response = requests.get(endpoint, timeout=5)
        logging.info(f"Normal request to {endpoint} - Status: {response.status_code}")
        
        # Log to separate file for ML training
        with open('/var/log/normal_traffic.log', 'a') as f:
            log_entry = {
                "timestamp": datetime.now().isoformat(),
                "type": "normal",
                "endpoint": endpoint,
                "status_code": response.status_code,
                "response_time": response.elapsed.total_seconds(),
                "user_agent": "ML-TrafficGen/1.0",
                "environment": ENVIRONMENT
            }
            f.write(json.dumps(log_entry) + "\n")
            
    except Exception as e:
        logging.error(f"Error in normal traffic: {e}")

def generate_anomaly_traffic():
    """Generate anomalous traffic patterns for ML training"""
    anomaly_patterns = [
        f"http://{TARGET_SERVER}/admin/secret",
        f"http://{TARGET_SERVER}/../../etc/passwd",
        f"http://{TARGET_SERVER}:8080/api/users?id=1' OR '1'='1",
        f"http://{TARGET_SERVER}/wp-admin/",
        f"http://{TARGET_SERVER}/.env",
        f"http://{TARGET_SERVER}/api/users" + "A" * 1000  # Buffer overflow attempt
    ]
    
    try:
        endpoint = random.choice(anomaly_patterns)
        response = requests.get(endpoint, timeout=5)
        logging.warning(f"Anomaly request to {endpoint} - Status: {response.status_code}")
        
        # Log to separate file for ML training
        with open('/var/log/attack_patterns.log', 'a') as f:
            log_entry = {
                "timestamp": datetime.now().isoformat(),
                "type": "anomaly",
                "endpoint": endpoint,
                "status_code": response.status_code,
                "response_time": response.elapsed.total_seconds(),
                "attack_type": "unknown_probe",
                "environment": ENVIRONMENT
            }
            f.write(json.dumps(log_entry) + "\n")
            
    except Exception as e:
        logging.error(f"Error in anomaly traffic: {e}")

def main():
    logging.info(f"Starting ML traffic generator for environment: {ENVIRONMENT}")
    logging.info(f"Target server: {TARGET_SERVER}")
    
    while True:
        # Generate mostly normal traffic (80%)
        if random.random() < 0.8:
            generate_normal_traffic()
        else:
            # Generate anomaly traffic (20%)
            generate_anomaly_traffic()
        
        # Random delay between requests (1-10 seconds)
        time.sleep(random.uniform(1, 10))

if __name__ == "__main__":
    main()
EOF

# Create control script
cat > /opt/ml-traffic-gen/control.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Starting ML traffic generator..."
        nohup python3 /opt/ml-traffic-gen/generate_traffic.py > /var/log/traffic_generator_control.log 2>&1 &
        echo $! > /var/run/traffic_generator.pid
        echo "Traffic generator started with PID $(cat /var/run/traffic_generator.pid)"
        ;;
    stop)
        echo "Stopping ML traffic generator..."
        if [ -f /var/run/traffic_generator.pid ]; then
            kill $(cat /var/run/traffic_generator.pid)
            rm /var/run/traffic_generator.pid
            echo "Traffic generator stopped"
        else
            echo "Traffic generator not running"
        fi
        ;;
    status)
        if [ -f /var/run/traffic_generator.pid ] && ps -p $(cat /var/run/traffic_generator.pid) > /dev/null; then
            echo "Traffic generator is running (PID: $(cat /var/run/traffic_generator.pid))"
        else
            echo "Traffic generator is not running"
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
EOF

# Set permissions
chmod +x /opt/ml-traffic-gen/generate_traffic.py
chmod +x /opt/ml-traffic-gen/control.sh
chown -R ec2-user:ec2-user /opt/ml-traffic-gen

# Install Python dependencies
pip3 install requests

# Create systemd service
cat > /etc/systemd/system/ml-traffic-generator.service << 'EOF'
[Unit]
Description=ML Traffic Generator
After=network.target

[Service]
Type=forking
User=ec2-user
ExecStart=/opt/ml-traffic-gen/control.sh start
ExecStop=/opt/ml-traffic-gen/control.sh stop
PIDFile=/var/run/traffic_generator.pid
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Create log rotation
cat > /etc/logrotate.d/ml-traffic << 'EOF'
/var/log/normal_traffic.log /var/log/attack_patterns.log /var/log/traffic_generator.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    copytruncate
}
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable ml-traffic-generator
systemctl start ml-traffic-generator

echo "ML Traffic Generator setup complete for environment: ${environment}"
echo "Target server: ${target_web_server}"
echo "Control commands:"
echo "  sudo /opt/ml-traffic-gen/control.sh start"
echo "  sudo /opt/ml-traffic-gen/control.sh stop" 
echo "  sudo /opt/ml-traffic-gen/control.sh status" 