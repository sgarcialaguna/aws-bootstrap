resource "aws_iam_instance_profile" "aws-bootstrap-instance-profile" {
  name = "aws-bootstrap-instance-profile"
  role = aws_iam_role.aws-bootstrap.name
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws-bootstrap" {
  name               = "aws-bootstrap"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  description        = "Allow access to CodeDeploy"
}

resource "aws_iam_role_policy_attachment" "code_deploy" {
  role       = aws_iam_role.aws-bootstrap.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.aws-bootstrap.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

data "aws_iam_policy_document" "deployment-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com", "codedeploy.amazonaws.com", "codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "deploy" {
  name               = "deploy"
  assume_role_policy = data.aws_iam_policy_document.deployment-assume-role-policy.json
  description        = "Deployment role"
}

resource "aws_iam_role_policy_attachment" "poweruser" {
  role       = aws_iam_role.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
