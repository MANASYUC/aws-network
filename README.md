# AWS Network Infrastructure - Improved Architecture

This Terraform configuration creates a scalable, secure AWS network infrastructure using a layered architectural approach.

## 🏗️ Architecture Overview

The infrastructure is organized into **three distinct layers**:

### **Layer 1: Foundation (Network Infrastructure)**
- **Purpose**: Core network components
- **Components**: VPC, Subnets, Internet Gateway, NAT Gateway, Route Tables
- **Module**: `modules/foundation/`

### **Layer 2: Platform (Security & Management)**
- **Purpose**: Security groups, access control, management services
- **Components**: Security Groups, Bastion Host, Network ACLs, Logging
- **Module**: `modules/platform/`

### **Layer 3: Applications (Workloads)**
- **Purpose**: Application workloads and services
- **Components**: Web servers, App servers, Databases, Load balancers
- **Modules**: `modules/applications/`

## 🎯 Key Improvements Over Previous Version

### ✅ **Fixed Issues**
- **Eliminated Duplicate Resources**: Removed duplicate VPC and subnet creation
- **Clear Separation of Concerns**: Each layer has a single responsibility  
- **Loose Coupling**: Layers communicate through well-defined interfaces
- **Consolidated Security**: All security groups managed in one place

### ✅ **New Benefits**
- **Layered Deployment**: Deploy only what you need
- **Environment Scalability**: Easy to replicate across dev/staging/prod
- **Maintainable Code**: Clear module organization and responsibilities
- **Flexible Configuration**: Enable/disable components as needed

## 🚀 Quick Start

### **1. Minimal Setup (Foundation + Platform Only)**
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and set:
environment = "dev"
enable_bastion = true
# All application tiers disabled by default

# Deploy
terraform init
terraform plan
terraform apply
```

This creates:
- VPC with public/private subnets
- Internet Gateway and NAT Gateway
- Security groups for all tiers
- Bastion host for secure access

### **2. Full 3-Tier Architecture**
```bash
# In terraform.tfvars, enable application tiers:
enable_web_tier = true
enable_app_tier = true
enable_data_tier = true

terraform apply
```

## 📁 Project Structure

```
aws-network/
├── main.tf                     # Main orchestration
├── variables.tf               # Input variables
├── outputs.tf                # Output values
├── providers.tf              # Provider configuration
├── terraform.tfvars.example  # Example configuration
├── terraform.tfvars          # Your configuration
│
├── modules/
│   ├── foundation/           # Layer 1: Network Infrastructure
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── platform/            # Layer 2: Security & Management
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data/
│   │       └── bastion_setup.sh
│   │
│   └── applications/        # Layer 3: Workloads (Future)
│       ├── web-tier/
│       ├── app-tier/
│       └── data-tier/
```

## ⚙️ Configuration

### **Required Variables**
```hcl
environment = "dev"                              # Environment name
admin_cidr_blocks = ["YOUR_IP_ADDRESS/32"]      # Your IP for SSH access
existing_key_name = "your-existing-key-name"    # SSH key pair name
```

### **Optional Features**
```hcl
# Network features
enable_nat_gateway = true    # Enable internet access for private subnets
enable_flow_logs = false     # Enable VPC flow logs (additional cost)

# Platform features  
enable_bastion = true        # Enable bastion host
enable_logging = true        # Enable CloudWatch logging

# Application tiers
enable_web_tier = false      # Public web servers
enable_app_tier = false      # Private application servers
enable_data_tier = false     # Database servers
```

## 🔒 Security Architecture

### **Security Groups (Managed in Platform Layer)**
- **Bastion SG**: SSH from admin IPs only
- **Web Tier SG**: HTTP/HTTPS from internet, SSH from bastion
- **App Tier SG**: App port from web tier, SSH from bastion
- **DB Tier SG**: DB port from app tier, SSH from bastion

### **Network Security**
- **Private Subnets**: No direct internet access
- **NAT Gateway**: Controlled outbound internet access
- **Network ACLs**: Optional additional security layer
- **Flow Logs**: Optional network traffic monitoring

## 🔧 Common Operations

### **Connect to Bastion Host**
```bash
# Get connection details
terraform output bastion_connection_info

# Connect via SSH
ssh -i your-key.pem ec2-user@BASTION_PUBLIC_IP
```

### **View Infrastructure**
```bash
# Get complete summary
terraform output deployment_summary

# Get quick reference commands
terraform output quick_reference
```

### **Add Application Tiers**
```bash
# Enable web tier
terraform apply -var="enable_web_tier=true"

# Enable all tiers
terraform apply -var="enable_web_tier=true" -var="enable_app_tier=true" -var="enable_data_tier=true"
```

## 🌍 Environment Management

### **Multiple Environments**
Create separate `.tfvars` files for each environment:

```bash
# Development
terraform apply -var-file="environments/dev.tfvars"

# Staging  
terraform apply -var-file="environments/staging.tfvars"

# Production
terraform apply -var-file="environments/prod.tfvars"
```

### **Environment-Specific Configuration**
```hcl
# environments/dev.tfvars
environment = "dev"
bastion_instance_type = "t3.micro"
enable_nat_gateway = false  # Cost optimization

# environments/prod.tfvars  
environment = "prod"
bastion_instance_type = "t3.small"
enable_nat_gateway = true
enable_flow_logs = true     # Enhanced monitoring
```

## 🏷️ Resource Tagging

All resources are automatically tagged with:
- **Environment**: dev/staging/prod
- **Project**: Your project name
- **ManagedBy**: Terraform
- **CreatedDate**: Creation timestamp
- **Custom tags**: From `common_tags` variable

## 💰 Cost Optimization

### **Development Environment**
```hcl
enable_nat_gateway = false           # Save ~$45/month per AZ
enable_flow_logs = false            # Save flow log storage costs
bastion_instance_type = "t3.micro"  # Use smallest instance
```

### **Production Environment**
```hcl
enable_nat_gateway = true           # Required for private subnet internet access
enable_flow_logs = true             # Important for security monitoring
enable_detailed_monitoring = true   # Enhanced monitoring
```

## 🛠️ Troubleshooting

### **Common Issues**

1. **"Duplicate resource" errors**
   - Old infrastructure has been removed
   - Run `terraform state list` to check for conflicting resources

2. **SSH key not found**
   - Ensure your SSH key pair exists in AWS
   - Update `existing_key_name` in terraform.tfvars

3. **Access denied to bastion**
   - Check your IP address in `admin_cidr_blocks`
   - Verify security group rules

### **Validation Commands**
```bash
# Validate configuration
terraform validate

# Check what will be created
terraform plan

# Format code
terraform fmt -recursive
```

## 📚 Next Steps

1. **Deploy Foundation + Platform**: Start with basic networking and security
2. **Add Application Tiers**: Enable workloads as needed
3. **Configure Monitoring**: Set up CloudWatch dashboards
4. **Implement CI/CD**: Automate deployments
5. **Add Custom Modules**: Extend with organization-specific modules

## 🤝 Contributing

When extending this architecture:
1. Follow the layered approach
2. Keep modules focused on single responsibilities  
3. Use clear variable naming and descriptions
4. Add comprehensive outputs for integration
5. Include proper tagging for all resources

---

**Architecture designed for**: Scalability, Security, Maintainability, Cost-effectiveness 