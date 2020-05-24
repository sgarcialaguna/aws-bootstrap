resource "aws_autoscaling_group" "webserver" {
  name              = "aws-bootstrap"
  min_size          = 2
  max_size          = 6
  health_check_type = "ELB"
  launch_template {
    id      = aws_launch_template.webserver.id
    version = "$Latest"
  }
  target_group_arns   = [aws_lb_target_group.target_group.arn]
  vpc_zone_identifier = [aws_subnet.subnetAZ1.id, aws_subnet.subnetAZ2.id]
  tag {
    key                 = "name"
    value               = "aws-bootstrap"
    propagate_at_launch = true
  }
}

