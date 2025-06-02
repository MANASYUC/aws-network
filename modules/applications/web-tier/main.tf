# ====================================
# WEB TIER MODULE
# ====================================
# Public-facing web servers

resource "aws_instance" "web" {
  count           = var.instance_count
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [var.security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data/web_server.sh", {
    environment = var.environment
  }))

  tags = merge(var.common_tags, {
    Name = "${var.environment}-web-${count.index + 1}"
    Tier = "web"
  })
} 