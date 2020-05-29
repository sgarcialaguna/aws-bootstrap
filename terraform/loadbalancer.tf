resource "aws_lb" "loadbalancer" {
  name               = "webserver-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webserver_sg.id]
  subnets            = [aws_subnet.subnetAZ1.id, aws_subnet.subnetAZ2.id]
  tags = {
    name = "aws-bootstrap"
  }
}

resource "aws_lb_listener" "listener_80" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_lb_target_group" "target_group" {
  target_type = "instance"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = aws_vpc.webserver.id
  health_check {
    enabled  = true
    protocol = "HTTP"
  }
  tags = {
    name = "aws-bootstrap"
  }
}

resource "aws_launch_template" "webserver" {
  name          = "webserver"
  image_id      = "ami-0bce3fe782b5b6394"
  instance_type = "t2.micro"
  key_name      = "default"
  user_data     = filebase64("boot.sh")
  tags = {
    type = "aws-bootstrap-webserver"
  }
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.aws-bootstrap-instance-profile.name
  }
}
