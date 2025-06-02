# AWS Free Tier Compatibility Guide

## 🚨 **Current Default Configuration: NOT Free Tier Friendly**

The default configuration will incur significant monthly costs (~$100-150/month).

## 💰 **Cost Breakdown - Default Configuration**

| Resource | Default Type | Monthly Cost | Free Tier Status |
|----------|-------------|--------------|------------------|
| Bastion Host | t3.micro | FREE ✅ | 750 hours included |
| Web Tier | t3.small | ~$15 ❌ | Not included |
| App Tier | t3.medium | ~$30 ❌ | Not included |
| Data Tier | t3.medium | ~$30 ❌ | Not included |
| Load Balancer | ALB | ~$16 ❌ | Not included |
| NAT Gateway | Standard | ~$45 ❌ | Not included |
| EBS Storage | 20GB extra | ~$2 ❌ | Only 30GB total free |
| **TOTAL** | | **~$138/month** | |

## ✅ **Free Tier Friendly Configuration**

Use the `terraform-free-tier.tfvars` file:

```bash
terraform plan -var-file="terraform-free-tier.tfvars"
terraform apply -var-file="terraform-free-tier.tfvars"
```

## 🆓 **AWS Free Tier Limits (12 months)**

### **EC2 Instances**
- ✅ **750 hours/month** of t2.micro instances
- ✅ **30 GB** of EBS storage (gp2 or gp3)
- ✅ **2 million I/O requests**

### **Networking**
- ✅ **1 GB** of data transfer out per month
- ✅ **Basic monitoring** (5-minute intervals)
- ❌ **NO** NAT Gateway included
- ❌ **NO** Load Balancer included

### **Storage**
- ✅ **5 GB** of S3 standard storage
- ✅ **20,000 GET requests**, 2,000 PUT requests

### **Other Services**
- ✅ **Basic CloudWatch** monitoring
- ❌ **NO** VPC Flow Logs (CloudWatch costs)

## 🛠 **How to Deploy Free Tier Version**

### **Step 1: Minimal Infrastructure Only**
```bash
# Copy the free tier configuration
cp terraform-free-tier.tfvars terraform.tfvars

# Update with your details
# - Replace "your-key-name" with your actual key pair
# - Replace IP addresses with your actual IP
```

### **Step 2: Deploy Foundation + Platform Only**
```bash
terraform init
terraform plan
terraform apply
```

This deploys:
- ✅ VPC with public/private subnets
- ✅ Security groups  
- ✅ Bastion host (t2.micro)
- ❌ NO NAT Gateway (use bastion for private access)
- ❌ NO application tiers

### **Step 3: Optional - Add Single Application Tier**
If you want to test an application tier within free tier:

```hcl
# In terraform.tfvars, enable ONE tier at a time:
enable_web_tier = true
web_instance_count = 1
web_instance_type = "t2.micro"  
enable_web_load_balancer = false  # No load balancer

# OR

enable_app_tier = true
app_instance_count = 1
app_instance_type = "t2.micro"

# OR 

enable_data_tier = true
db_instance_type = "t2.micro"
```

⚠️ **WARNING**: Do NOT enable multiple tiers simultaneously in free tier - you'll exceed 750 hours limit.

## 📊 **Free Tier Resource Usage Calculator**

With the free tier configuration:

### **EC2 Hours Usage**
- Bastion: 24 hours/day × 30 days = **720 hours** ✅
- Web Tier: 24 hours/day × 30 days = **720 hours** ✅  
- **Total**: 720 hours (within 750 hour limit) ✅

### **Storage Usage**
- Root volumes: 8GB each × 2 instances = **16 GB**
- Data tier storage: **10 GB**
- **Total**: 26 GB (within 30 GB limit) ✅

## 🚧 **Architecture Limitations in Free Tier**

### **What You CAN'T Do:**
- ❌ High Availability (multiple AZ deployments cost extra)
- ❌ Load Balancing (ALB costs ~$16/month)
- ❌ Auto Scaling (multiple instances exceed free tier)
- ❌ NAT Gateway (costs ~$45/month)
- ❌ Production workloads (performance limitations)

### **What You CAN Do:**
- ✅ Learn AWS networking concepts
- ✅ Test 3-tier architecture patterns
- ✅ Practice Terraform deployments
- ✅ Develop and test applications
- ✅ Access private resources via bastion

## 🔒 **Access Patterns in Free Tier Setup**

### **Accessing Private Resources:**
Since there's no NAT Gateway:

```bash
# 1. SSH to bastion host
ssh -i your-key.pem ec2-user@<bastion-public-ip>

# 2. From bastion, access private instances
ssh -i your-key.pem ec2-user@<private-instance-ip>
```

### **Internet Access for Private Instances:**
- Use bastion host as NAT instance (requires configuration)
- Or deploy resources in public subnets for testing

## 💡 **Pro Tips for Free Tier**

1. **Stop instances when not in use** to preserve hours
2. **Use CloudWatch billing alerts** (free) to monitor usage
3. **Delete resources** when done testing to avoid accidental charges
4. **Monitor EBS snapshot costs** (not included in free tier)
5. **Use t2.micro only** - other instance types charge immediately

## 🧹 **Cleanup Commands**

```bash
# Always cleanup when done to avoid charges
terraform destroy -var-file="terraform-free-tier.tfvars"

# Verify all resources are deleted in AWS Console
```

## 📚 **Learning Path**

### **Phase 1: Foundation (Free)**
```bash
# Deploy minimal infrastructure
enable_bastion = true
enable_nat_gateway = false
# All tiers = false
```

### **Phase 2: Add One Tier (Free)**
```bash
# Add web tier only
enable_web_tier = true
enable_web_load_balancer = false
```

### **Phase 3: Production Features (Costs Money)**
```bash
# Enable production features (costs apply)
enable_nat_gateway = true
enable_web_load_balancer = true
# Multiple instances per tier
```

---

**Remember**: AWS free tier is for learning and development. For production workloads, you'll need to invest in proper infrastructure sizing and redundancy. 