# ====================================
# WEB TIER MODULE
# ====================================
# Public-facing web servers with load balancer

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

# Application Load Balancer (optional)
resource "aws_lb" "web" {
  count              = var.enable_load_balancer ? 1 : 0
  name               = "${var.environment}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.environment}-web-alb"
  })
}

# Target Group for ALB
resource "aws_lb_target_group" "web" {
  count    = var.enable_load_balancer ? 1 : 0
  name     = "${var.environment}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    Name = "${var.environment}-web-tg"
  })
}

# ALB Listener
resource "aws_lb_listener" "web" {
  count             = var.enable_load_balancer ? 1 : 0
  load_balancer_arn = aws_lb.web[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web[0].arn
  }
}

# Attach instances to target group
resource "aws_lb_target_group_attachment" "web" {
  count            = var.enable_load_balancer ? var.instance_count : 0
  target_group_arn = aws_lb_target_group.web[0].arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
} 