resource "aws_instance" "instance" {
  ami                  = aws_launch_template.webserver.image_id
  instance_type        = aws_launch_template.webserver.instance_type
  key_name             = aws_launch_template.webserver.key_name
  user_data            = aws_launch_template.webserver.user_data
  tags                 = aws_launch_template.webserver.tags
  iam_instance_profile = aws_iam_instance_profile.aws-bootstrap-instance-profile.name
  security_groups      = [aws_security_group.webserver_sg.id]
  subnet_id            = aws_subnet.subnetAZ1.id
}

resource "aws_instance" "instance2" {
  ami                  = aws_launch_template.webserver.image_id
  instance_type        = aws_launch_template.webserver.instance_type
  key_name             = aws_launch_template.webserver.key_name
  user_data            = aws_launch_template.webserver.user_data
  tags                 = aws_launch_template.webserver.tags
  iam_instance_profile = aws_iam_instance_profile.aws-bootstrap-instance-profile.name
  security_groups      = [aws_security_group.webserver_sg.id]
  subnet_id            = aws_subnet.subnetAZ2.id
}
