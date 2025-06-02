# ====================================
# DATA TIER MODULE
# ====================================
# Private database servers

resource "aws_instance" "db" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  key_name            = var.key_name
  subnet_id           = var.subnet_ids[0]  # Use first subnet for primary DB
  security_groups     = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data/db_server.sh", {
    environment = var.environment
    db_port     = var.db_port
  }))

  tags = merge(var.common_tags, {
    Name = "${var.environment}-db-primary"
    Tier = "database"
  })
}

# Optional: EBS volume for database storage
resource "aws_ebs_volume" "db_storage" {
  availability_zone = aws_instance.db.availability_zone
  size              = var.storage_size
  type              = "gp3"
  encrypted         = var.enable_encryption

  tags = merge(var.common_tags, {
    Name = "${var.environment}-db-storage"
  })
}

resource "aws_volume_attachment" "db_storage" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.db_storage.id
  instance_id = aws_instance.db.id
} 