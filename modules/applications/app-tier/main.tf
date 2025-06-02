# ====================================
# APPLICATION TIER MODULE
# ====================================
# Private application servers

resource "aws_instance" "app" {
  count           = var.instance_count
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data/app_server.sh", {
    environment = var.environment
    app_port    = var.app_port
  }))

  tags = merge(var.common_tags, {
    Name = "${var.environment}-app-${count.index + 1}"
    Tier = "application"
  })
} 