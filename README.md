<<<<<<< Updated upstream
<<<<<<< Updated upstream
# AWS Network Infrastructure - Improved Architecture

This Terraform configuration creates a scalable, secure AWS network infrastructure using a layered architectural approach.

## 🏗️ Architecture Overview

The infrastructure is organized into **four distinct layers**:

### **Layer 0: IAM (Identity and Access Management)**
- **Purpose**: Centralized IAM roles and policies
- **Components**: VPC Flow Logs Role, Future EC2/Lambda/ECS roles
- **Module**: `modules/iam/`

### **Layer 1: Foundation (Network Infrastructure)**
- **Purpose**: Core network components
- **Components**: VPC, Subnets, Internet Gateway, NAT Gateway, Route Tables, VPC Flow Logs
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
=======
=======
>>>>>>> Stashed changes
# AWS Network Infrastructure for ML Training

A comprehensive Terraform project for deploying AWS network infrastructure with three focused deployment modes for different learning goals and budgets.

## 🎯 **Choose Your Deployment Mode**

Navigate to the mode that matches your goals:

### **🚀 [Simplified Mode](modes/simplified/)**
**Free Tier friendly, basic ML data generation**
- Cost: ~$0-15/month
- Perfect for: AWS networking basics, ML data collection
- [View Documentation](modes/simplified/README.md)

### **🧠 [ML-Focused Mode](modes/ml-focused/)** ⭐ **Recommended for ML Learning**
**Enhanced ML training with comprehensive anomaly detection**
- Cost: ~$15-25/month
- Perfect for: Serious ML model training, anomaly detection
- [View Documentation](modes/ml-focused/README.md)

### **🏢 [Full Enterprise Mode](modes/full/)**
**Complete 3-tier architecture for enterprise learning**
- Cost: ~$50-100/month
- Perfect for: Enterprise architecture, DevOps skills
- [View Documentation](modes/full/README.md)

## 🚀 **Quick Start**

### **1. Choose Your Mode:**
```bash
cd modes/simplified/     # Free tier friendly
cd modes/ml-focused/     # ML training focused (RECOMMENDED)
cd modes/full/          # Enterprise learning
```

### **2. Configure and Deploy:**
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

<<<<<<< Updated upstream
<<<<<<< Updated upstream
# Edit terraform.tfvars and set:
environment = "dev"
enable_bastion = true
# All application tiers disabled by default

# Deploy
=======
=======
>>>>>>> Stashed changes
# Edit with your settings (required!)
nano terraform.tfvars

# Deploy infrastructure
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
terraform init
terraform plan
terraform apply
```

<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
│   ├── iam/                 # Layer 0: IAM Resources
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   │
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
=======
=======
>>>>>>> Stashed changes
### **3. Required Configuration:**
Before deploying any mode, you MUST update:
```hcl
existing_key_name = "your-actual-key-pair-name"
admin_cidr_blocks = ["YOUR.ACTUAL.IP.ADDRESS/32"]
```

## 📋 **Prerequisites**

### **Required:**
- AWS Account with Free Tier eligibility
- Terraform installed (v1.0+)
- AWS CLI configured with credentials
- **EC2 Key Pair** created in your target region

### **Create EC2 Key Pair:**
```bash
# Option 1: AWS CLI
aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > my-key-pair.pem
chmod 400 my-key-pair.pem

# Option 2: AWS Console
# Go to EC2 → Key Pairs → Create key pair → Download .pem file
```

## 📁 **Project Structure**

```
aws-network/
├── modes/
│   ├── simplified/          # Free tier ML data generation
│   ├── ml-focused/          # Enhanced ML training (RECOMMENDED)
│   └── full/               # Complete enterprise architecture
├── modules/                 # Shared infrastructure components
│   ├── ml-network/         # Simplified networking
│   ├── ml-generators/      # ML data generation
│   ├── ml-security/        # Basic security
│   ├── foundation/         # Enterprise foundation
│   ├── platform/           # Enterprise platform
│   ├── applications/       # 3-tier applications
│   ├── iam/               # IAM roles and policies
│   └── shared/            # Shared S3 storage
└── scripts/                # Utility scripts
```

## 🎛️ **Mode Comparison**

| Feature | Simplified | ML-Focused | Full |
|---------|-----------|------------|------|
| **Cost/Month** | $0-15 | $15-25 | $50-100 |
| **EC2 Instances** | 3 | 3-4 | 6-10+ |
| **Learning Focus** | AWS Basics | ML Training | Enterprise |
| **ML Data** | Basic | Comprehensive | Optional |
| **Security** | Basic | Enhanced | Enterprise |
| **Complexity** | Low | Medium | High |
| **Bastion Host** | Optional | Optional | Included |
| **3-Tier Apps** | No | No | Yes |
| **Auto Scaling** | No | No | Yes |

## 🤔 **Which Mode Should I Choose?**

### **Choose Simplified if:**
- You're new to AWS networking
- Budget is very tight (Free Tier only)
- You want basic ML data generation
- You prefer minimal complexity

### **Choose ML-Focused if:** ⭐ **RECOMMENDED**
- You want to build serious ML models
- You need comprehensive anomaly detection data
- You can afford ~$20/month
- You want advanced features without enterprise complexity

### **Choose Full if:**
- You want to learn enterprise architecture
- Budget allows $50-100/month
- You need 3-tier application deployment
- You want complete AWS infrastructure experience

## 🛠️ **Common Operations**

### **Switch Between Modes:**
```bash
# Each mode is independent
cd modes/ml-focused/
terraform destroy          # Clean up current mode
cd ../simplified/
terraform apply            # Deploy different mode
```

### **Enable Features:**
```bash
# In ml-focused mode:
echo 'enable_bastion = true' >> terraform.tfvars
echo 'traffic_intensity = "high"' >> terraform.tfvars
terraform apply

# In full mode:
echo 'enable_web_tier = true' >> terraform.tfvars
echo 'web_instance_count = 3' >> terraform.tfvars
terraform apply
```

### **Monitor Your Resources:**
```bash
# Check what's deployed
terraform output

# Monitor costs
terraform output cost_summary

# Get SSH commands
terraform output ssh_commands
```

## 🔧 **Troubleshooting**

### **Common Issues:**

#### **1. Key Pair Error:**
```bash
# Error: InvalidKeyPair.NotFound
aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > my-key-pair.pem
```

#### **2. IP Access Issues:**
```bash
# Update your IP in terraform.tfvars
echo 'admin_cidr_blocks = ["$(curl -s ifconfig.me)/32"]' >> terraform.tfvars
terraform apply
```

#### **3. Module Errors:**
```bash
# Clean and reinitialize
terraform init -upgrade
```

### **Clean Start:**
```bash
terraform destroy
rm -rf .terraform*
terraform init
terraform apply
```

## 💰 **Cost Management**

### **Free Tier Optimization:**
- Use **simplified** mode for minimal costs
- Enable auto-shutdown features
- Monitor usage with AWS Cost Explorer

### **ML-Focused Budget:**
- Expected: ~$15-25/month
- Optimize: 1-day log retention, aggressive S3 lifecycle

### **Enterprise Budget:**
- Expected: ~$50-100/month
- Scale down instance types for learning

## 🧹 **Cleanup**

### **Destroy Resources:**
```bash
# From any mode directory
terraform destroy

# Confirm with "yes"
```

### **Complete Cleanup:**
```bash
# If S3 buckets block deletion
aws s3 rm s3://your-bucket-name --recursive
terraform destroy
```

## 📚 **Learning Path**

### **Week 1-2: Start Simple**
1. Deploy **simplified** mode
2. Learn VPC basics, EC2, S3
3. Understand security groups
4. Monitor basic logs

### **Week 3-6: ML Focus** ⭐
1. Upgrade to **ml-focused** mode
2. Analyze comprehensive ML data
3. Build anomaly detection models
4. Learn advanced AWS features

### **Month 2+: Enterprise Skills**
1. Deploy **full** mode
2. Master bastion hosts, 3-tier apps
3. Learn auto scaling, load balancing
4. Understand enterprise security

## 🎯 **Next Steps**

After choosing and deploying your mode:

1. **Explore**: SSH into instances, examine logs
2. **Learn**: Study the generated data and infrastructure
3. **Build**: Create ML models (ml-focused) or applications (full)
4. **Scale**: Add features and optimize costs
5. **Advance**: Progress to more complex modes

## 📞 **Support**

### **Mode-Specific Help:**
- [Simplified Mode Documentation](modes/simplified/README.md)
- [ML-Focused Mode Documentation](modes/ml-focused/README.md)  
- [Full Mode Documentation](modes/full/README.md)

### **Quick Commands:**
```bash
terraform plan          # Preview changes
terraform apply         # Deploy changes
terraform output        # View deployment info
terraform destroy       # Clean up resources
```

---

**🚀 Ready to start? Choose your mode above and begin your AWS learning journey!**

<<<<<<< Updated upstream
**💡 Not sure? Start with [ML-Focused Mode](modes/ml-focused/) - it's the sweet spot for most learners.** 
>>>>>>> Stashed changes
=======
**💡 Not sure? Start with [ML-Focused Mode](modes/ml-focused/) - it's the sweet spot for most learners.** 
>>>>>>> Stashed changes
