#!/bin/bash
# ====================================
# BASTION HOST SETUP SCRIPT
# ====================================

# Update system packages
yum update -y

# Install essential packages
yum install -y \
    aws-cli \
    htop \
    git \
    vim \
    curl \
    wget \
    unzip \
    jq

# Install CloudWatch agent if logging is enabled
%{ if log_group != "" }
# Download and install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "${log_group}",
                        "log_stream_name": "{instance_id}/messages"
                    },
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "${log_group}",
                        "log_stream_name": "{instance_id}/secure"
                    }
                ]
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s
%{ endif }

# Configure SSH security
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Create motd
cat > /etc/motd << EOF
=====================================
    ${environment} Environment
    Bastion Host - Secure Access Point
=====================================

This is a bastion host for secure access to private resources.
All activities on this system are logged and monitored.

Environment: ${environment}
Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
Local IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

=====================================
EOF

# Set up user aliases for convenience
cat >> /home/ec2-user/.bashrc << EOF

# Custom aliases for bastion host
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias instances='aws ec2 describe-instances --region \$(curl -s http://169.254.169.254/latest/meta-data/placement/region) --query "Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress,Tags[?Key==\`Name\`].Value|[0]]" --output table'

# Environment info
echo "Environment: ${environment}"
echo "Instance ID: \$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
EOF

# Create log directory
mkdir -p /var/log/bastion

# Log the setup completion
echo "$(date): Bastion host setup completed for ${environment} environment" >> /var/log/bastion/setup.log

# Signal that setup is complete
/opt/aws/bin/cfn-signal -e $? --stack ${environment}-bastion --resource BastionHost --region \$(curl -s http://169.254.169.254/latest/meta-data/placement/region) || true 