#!/bin/bash
# ====================================
# COMPREHENSIVE ANOMALY DETECTION DATA COLLECTION
# ====================================
# This script captures ALL essential data types for ML anomaly detection
# while staying within Free Tier limits through intelligent sampling

LOG_DIR="/var/log"
S3_BUCKET="${s3_bucket_name}"
ENVIRONMENT="${environment}"
SAMPLE_DIR="/tmp/ml_samples"

# Create sampling directory
mkdir -p "$SAMPLE_DIR"

# COMPREHENSIVE DATA COLLECTION for Anomaly Detection
collect_network_patterns() {
    echo "$(date): Collecting network traffic patterns for ML training..."
    
    # NORMAL TRAFFIC PATTERNS (80% of dataset - establish baseline)
    # Sample every 10th normal request to reduce volume but maintain patterns
    grep -E "GET|POST" "$LOG_DIR/httpd/access_log" 2>/dev/null | \
        awk 'NR%10==0' > "$SAMPLE_DIR/normal_http_patterns.log"
    
    # ATTACK PATTERNS (20% of dataset - detect anomalies)
    grep -E "(union.*select|script.*alert|<.*>|['\";\\]|\.\.\/|cmd=|exec)" \
        "$LOG_DIR/httpd/access_log" > "$SAMPLE_DIR/attack_patterns.log" 2>/dev/null
    
    # CONNECTION PATTERNS (timing, frequency, sources)
    grep -E "established|closed|timeout" \
        "$LOG_DIR/messages" > "$SAMPLE_DIR/connection_patterns.log" 2>/dev/null
    
    echo "$(date): Network patterns collected"
}

collect_authentication_patterns() {
    echo "$(date): Collecting authentication patterns..."
    
    # NORMAL AUTH (successful logins - baseline behavior)
    grep -E "Accepted password|Accepted publickey|session opened" \
        "$LOG_DIR/auth.log" > "$SAMPLE_DIR/normal_auth.log" 2>/dev/null
    
    # ANOMALOUS AUTH (failed attempts, unusual patterns)
    grep -E "Failed password|authentication failure|Invalid user|ROOT LOGIN" \
        "$LOG_DIR/auth.log" > "$SAMPLE_DIR/anomalous_auth.log" 2>/dev/null
    
    # LOGIN TIMING PATTERNS (detect brute force timing)
    grep -E "sshd.*Accepted|sshd.*Failed" "$LOG_DIR/auth.log" | \
        awk '{print $1, $2, $3, $11}' > "$SAMPLE_DIR/login_timing.log" 2>/dev/null
    
    echo "$(date): Authentication patterns collected"
}

collect_system_behavior() {
    echo "$(date): Collecting system behavior patterns..."
    
    # PROCESS PATTERNS (normal vs unusual process behavior)
    ps aux --sort=-%cpu | head -20 > "$SAMPLE_DIR/process_patterns.log"
    
    # RESOURCE USAGE PATTERNS (CPU, memory, disk)
    echo "CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)" >> "$SAMPLE_DIR/resource_usage.log"
    echo "MEM: $(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')" >> "$SAMPLE_DIR/resource_usage.log"
    echo "DISK: $(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)" >> "$SAMPLE_DIR/resource_usage.log"
    
    # ERROR PATTERNS (system errors and warnings)
    grep -E "ERROR|CRITICAL|WARNING" "$LOG_DIR/messages" | \
        tail -100 > "$SAMPLE_DIR/system_errors.log" 2>/dev/null
    
    echo "$(date): System behavior collected"
}

collect_application_metrics() {
    echo "$(date): Collecting application-level metrics..."
    
    # API RESPONSE PATTERNS (response times, status codes)
    grep -E "HTTP/1\.[01]\" [0-9]{3}" "$LOG_DIR/httpd/access_log" | \
        awk '{print $9, $(NF-1)}' | tail -1000 > "$SAMPLE_DIR/api_responses.log" 2>/dev/null
    
    # REQUEST FREQUENCY PATTERNS (requests per minute)
    grep "$(date '+%d/%b/%Y:%H:%M')" "$LOG_DIR/httpd/access_log" 2>/dev/null | \
        wc -l > "$SAMPLE_DIR/request_frequency.log"
    
    # USER AGENT PATTERNS (detect bots, crawlers, unusual clients)
    grep -o '"[^"]*"$' "$LOG_DIR/httpd/access_log" | \
        sort | uniq -c | sort -nr | head -20 > "$SAMPLE_DIR/user_agents.log" 2>/dev/null
    
    echo "$(date): Application metrics collected"
}

collect_time_series_data() {
    echo "$(date): Collecting time-series patterns for temporal anomaly detection..."
    
    # HOURLY TRAFFIC PATTERNS (detect unusual traffic spikes/drops)
    for hour in {00..23}; do
        count=$(grep ":$hour:" "$LOG_DIR/httpd/access_log" 2>/dev/null | wc -l)
        echo "$(date '+%Y-%m-%d') $hour:00 $count" >> "$SAMPLE_DIR/hourly_patterns.log"
    done
    
    # RESPONSE TIME TRENDS (detect performance anomalies)
    tail -1000 "$LOG_DIR/httpd/access_log" 2>/dev/null | \
        awk '{print $(NF-1)}' | \
        awk '{sum+=$1; count++} END {if(count>0) print "avg_response_time:", sum/count}' \
        >> "$SAMPLE_DIR/performance_trends.log"
    
    echo "$(date): Time-series data collected"
}

create_feature_vectors() {
    echo "$(date): Creating ML feature vectors..."
    
    # Combine all data into structured format for ML training
    cat > "$SAMPLE_DIR/ml_feature_set.json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "environment": "$ENVIRONMENT",
  "features": {
    "network": {
      "normal_requests": $(wc -l < "$SAMPLE_DIR/normal_http_patterns.log" 2>/dev/null || echo 0),
      "attack_attempts": $(wc -l < "$SAMPLE_DIR/attack_patterns.log" 2>/dev/null || echo 0),
      "connection_events": $(wc -l < "$SAMPLE_DIR/connection_patterns.log" 2>/dev/null || echo 0)
    },
    "authentication": {
      "successful_logins": $(wc -l < "$SAMPLE_DIR/normal_auth.log" 2>/dev/null || echo 0),
      "failed_attempts": $(wc -l < "$SAMPLE_DIR/anomalous_auth.log" 2>/dev/null || echo 0)
    },
    "system": {
      "cpu_usage": $(grep "CPU:" "$SAMPLE_DIR/resource_usage.log" 2>/dev/null | tail -1 | cut -d' ' -f2 || echo 0),
      "memory_usage": $(grep "MEM:" "$SAMPLE_DIR/resource_usage.log" 2>/dev/null | tail -1 | cut -d' ' -f2 || echo 0),
      "error_count": $(wc -l < "$SAMPLE_DIR/system_errors.log" 2>/dev/null || echo 0)
    },
    "application": {
      "request_rate": $(cat "$SAMPLE_DIR/request_frequency.log" 2>/dev/null || echo 0),
      "avg_response_time": $(grep "avg_response_time" "$SAMPLE_DIR/performance_trends.log" 2>/dev/null | cut -d':' -f2 || echo 0)
    }
  }
}
EOF
    
    echo "$(date): Feature vectors created"
}

# INTELLIGENT SAMPLING to stay within free tier
optimize_for_free_tier() {
    echo "$(date): Optimizing dataset for free tier compliance..."
    
    # Calculate total size
    TOTAL_SIZE=$(du -sm "$SAMPLE_DIR" | cut -f1)
    
    if [ "$TOTAL_SIZE" -gt 50 ]; then  # If > 50MB, compress aggressively
        echo "$(date): Large dataset detected ($TOTAL_SIZE MB), applying compression..."
        
        # Compress logs with high compression
        find "$SAMPLE_DIR" -name "*.log" -exec gzip -9 {} \;
        
        # Keep only most recent samples if still too large
        find "$SAMPLE_DIR" -name "*.log.gz" -mmin +60 -delete
    fi
    
    echo "$(date): Dataset optimized to $(du -sm "$SAMPLE_DIR" | cut -f1)MB"
}

# Export comprehensive dataset to S3
export_comprehensive_dataset() {
    echo "$(date): Exporting comprehensive ML dataset to S3..."
    
    # Create comprehensive archive with organized structure
    cd /tmp && tar -czf "ml_anomaly_dataset_$(date +%Y%m%d_%H%M).tar.gz" ml_samples/
    
    if [ -f "ml_anomaly_dataset_"*.tar.gz ]; then
        # Upload with metadata for ML pipeline
        aws s3 cp ml_anomaly_dataset_*.tar.gz \
            "s3://$S3_BUCKET/ml-datasets/anomaly-detection/$(date +%Y/%m/%d)/" \
            --metadata "type=anomaly-detection,environment=$ENVIRONMENT,samples=comprehensive" \
            --storage-class STANDARD_IA
        
        # Cleanup
        rm -f ml_anomaly_dataset_*.tar.gz
        rm -rf ml_samples/
        echo "$(date): Comprehensive ML dataset exported"
    fi
}

# Main execution - comprehensive data collection
main() {
    echo "$(date): Starting COMPREHENSIVE anomaly detection data collection..."
    
    # Collect all essential data types
    collect_network_patterns
    collect_authentication_patterns  
    collect_system_behavior
    collect_application_metrics
    collect_time_series_data
    create_feature_vectors
    
    # Optimize and export
    optimize_for_free_tier
    export_comprehensive_dataset
    
    echo "$(date): Comprehensive anomaly detection dataset ready for ML training!"
}

# Run comprehensive collection
main 