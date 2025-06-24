# 📊 ML Data Access and Processing Guide

## 🎯 **Data Location and Access**

### **S3 Bucket Access**
After deployment, your data will be in:
```
s3://ml-network-anomaly-data-app-storage-ml-dev-XXXXXXXX/
```

### **Download Data to Local Machine**

#### **Option 1: AWS CLI**
```bash
# List all datasets
aws s3 ls s3://your-bucket-name/ml-datasets/anomaly-detection/ --recursive

# Download latest dataset
aws s3 cp s3://your-bucket-name/ml-datasets/anomaly-detection/2024/12/01/ml_anomaly_dataset_20241201_1500.tar.gz ./

# Download all datasets for a day
aws s3 sync s3://your-bucket-name/ml-datasets/anomaly-detection/2024/12/01/ ./datasets/
```

#### **Option 2: AWS Console**
1. Go to S3 Console
2. Navigate to your bucket
3. Browse to `ml-datasets/anomaly-detection/`
4. Download `.tar.gz` files

### **Extract and Process Data**

#### **Extract Dataset**
```bash
# Extract the compressed dataset
tar -xzf ml_anomaly_dataset_20241201_1500.tar.gz

# This creates a directory structure:
ml_samples/
├── normal_http_patterns.log
├── attack_patterns.log
├── connection_patterns.log
├── normal_auth.log
├── anomalous_auth.log
├── process_patterns.log
├── resource_usage.log
├── system_errors.log
├── api_responses.log
├── request_frequency.log
├── user_agents.log
├── hourly_patterns.log
├── performance_trends.log
└── ml_feature_set.json
```

## 🔄 **Convert to CSV for ML Models**

### **Python Script to Convert Data to CSV**

```python
import json
import pandas as pd
import re
from datetime import datetime

def parse_log_to_csv(log_file, output_csv):
    """Convert log files to CSV format"""
    data = []
    
    with open(log_file, 'r') as f:
        for line in f:
            try:
                # Parse JSON log entries
                if line.strip().startswith('{'):
                    entry = json.loads(line.strip())
                    data.append(entry)
                else:
                    # Parse traditional log format
                    parts = line.strip().split()
                    if len(parts) >= 4:
                        data.append({
                            'timestamp': f"{parts[0]} {parts[1]} {parts[2]}",
                            'raw_log': line.strip(),
                            'log_type': 'traditional'
                        })
            except:
                continue
    
    df = pd.DataFrame(data)
    df.to_csv(output_csv, index=False)
    return df

def create_ml_dataset():
    """Create comprehensive ML dataset from all log files"""
    
    # Convert each log type to CSV
    datasets = {}
    
    # Network patterns
    if os.path.exists('normal_http_patterns.log'):
        datasets['normal_traffic'] = parse_log_to_csv('normal_http_patterns.log', 'normal_traffic.csv')
    
    if os.path.exists('attack_patterns.log'):
        datasets['attack_traffic'] = parse_log_to_csv('attack_patterns.log', 'attack_traffic.csv')
    
    # Authentication patterns
    if os.path.exists('normal_auth.log'):
        datasets['normal_auth'] = parse_log_to_csv('normal_auth.log', 'normal_auth.csv')
    
    if os.path.exists('anomalous_auth.log'):
        datasets['anomalous_auth'] = parse_log_to_csv('anomalous_auth.log', 'anomalous_auth.csv')
    
    # System metrics
    if os.path.exists('resource_usage.log'):
        datasets['system_metrics'] = parse_log_to_csv('resource_usage.log', 'system_metrics.csv')
    
    # Create combined dataset
    combined_data = []
    
    for dataset_name, df in datasets.items():
        for _, row in df.iterrows():
            combined_data.append({
                'dataset_type': dataset_name,
                'timestamp': row.get('timestamp', ''),
                'data': row.to_dict()
            })
    
    combined_df = pd.DataFrame(combined_data)
    combined_df.to_csv('ml_combined_dataset.csv', index=False)
    
    return combined_df

# Run the conversion
if __name__ == "__main__":
    create_ml_dataset()
    print("CSV files created successfully!")
```

### **Quick CSV Conversion Commands**

#### **Convert JSON Logs to CSV**
```bash
# Convert normal traffic logs
jq -r '[.timestamp, .type, .endpoint, .status_code, .response_time] | @csv' normal_http_patterns.log > normal_traffic.csv

# Convert attack logs
jq -r '[.timestamp, .type, .endpoint, .status_code, .attack_type] | @csv' attack_patterns.log > attack_traffic.csv

# Convert auth logs
jq -r '[.timestamp, .type, .endpoint, .status_code] | @csv' normal_auth.log > normal_auth.csv
```

## 📈 **Data Volume and Collection Time**

### **Expected Data Volume**
- **Per hour**: ~2-5 MB of compressed data
- **Per day**: ~50-100 MB of compressed data
- **Per week**: ~350-700 MB of compressed data

### **Recommended Collection Time**

#### **Minimum Viable Dataset: 24-48 hours**
- **Why**: Establish baseline patterns and capture daily cycles
- **Data points**: ~1,000-2,000 normal requests, ~200-400 anomalies
- **Good for**: Basic anomaly detection models

#### **Optimal Dataset: 1 week (168 hours)**
- **Why**: Capture weekly patterns, multiple anomaly types
- **Data points**: ~7,000-14,000 normal requests, ~1,400-2,800 anomalies
- **Good for**: Robust ML models with good accuracy

#### **Comprehensive Dataset: 2-4 weeks**
- **Why**: Seasonal patterns, rare anomaly types, model validation
- **Data points**: ~14,000-56,000 normal requests, ~2,800-11,200 anomalies
- **Good for**: Production-ready models

### **Free Tier Hours Calculation**
With 664 hours remaining:
- **24 hours**: 664 - 24 = 640 hours remaining
- **1 week**: 664 - 168 = 496 hours remaining  
- **2 weeks**: 664 - 336 = 328 hours remaining
- **4 weeks**: 664 - 672 = -8 hours (exceeds free tier)

**Recommendation**: Collect for **1-2 weeks** for optimal results within free tier.

## 🎯 **ML Model Training Data Structure**

### **Feature Vectors Created**
The system automatically creates structured feature vectors:

```json
{
  "timestamp": "2024-12-01T15:00:00Z",
  "environment": "ml-dev",
  "features": {
    "network": {
      "normal_requests": 150,
      "attack_attempts": 30,
      "connection_events": 25
    },
    "authentication": {
      "successful_logins": 5,
      "failed_attempts": 12
    },
    "system": {
      "cpu_usage": 45.2,
      "memory_usage": 67.8,
      "error_count": 3
    },
    "application": {
      "request_rate": 180,
      "avg_response_time": 0.023
    }
  }
}
```

### **ML Algorithms Supported**
- **Isolation Forest**: For unsupervised anomaly detection
- **One-Class SVM**: For novelty detection
- **Autoencoders**: For deep learning anomaly detection
- **LSTM Networks**: For time-series anomaly detection
- **Random Forest**: For supervised classification

## 🚀 **Next Steps After Data Collection**

1. **Download datasets** from S3 bucket
2. **Extract and convert** to CSV format
3. **Train ML models** using the structured data
4. **Validate models** on test datasets
5. **Deploy anomaly detection** in production

## 💡 **Pro Tips**

- **Start with 24 hours** to validate the setup
- **Monitor S3 costs** (should stay under free tier)
- **Use the feature vectors** for quick ML prototyping
- **Combine multiple days** for better model accuracy
- **Keep the infrastructure running** for continuous data collection 