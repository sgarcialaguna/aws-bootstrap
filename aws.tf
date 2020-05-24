provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "webserver" {
  ami             = "ami-076431be05aaf8080"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.webserver_sg.name}"]
  key_name        = "default"
  user_data       = file("boot.sh")
  tags = {
    type = "aws-bootstrap-webserver"
  }
  iam_instance_profile = aws_iam_instance_profile.aws-bootstrap-instance-profile.name
}

resource "aws_iam_instance_profile" "aws-bootstrap-instance-profile" {
  name = "aws-bootstrap-instance-profile"
  role = aws_iam_role.aws-bootstrap.name
}


resource "aws_security_group" "webserver_sg" {
  name = "Allow access to webserver"
  ingress {
    description = "Allow access to webserver"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH to webserver"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_s3_bucket" "my-code-deploy-bucket" {
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
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

resource "aws_codebuild_project" "aws-bootstrap" {
  name         = "aws-bootstrap"
  service_role = aws_iam_role.deploy.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:2.0"
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = ""
  }
}

resource "aws_codedeploy_app" "aws-bootstrap" {
  name             = "aws-bootstrap"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "staging" {
  deployment_group_name  = "staging"
  app_name               = aws_codedeploy_app.aws-bootstrap.name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.deploy.arn
  ec2_tag_filter {
    key   = "type"
    type  = "KEY_AND_VALUE"
    value = "aws-bootstrap-webserver"
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = "aws-bootstrap"
  role_arn = aws_iam_role.deploy.arn
  artifact_store {
    location = aws_s3_bucket.my-code-deploy-bucket.bucket
    type     = "S3"
  }
  depends_on = [aws_instance.webserver]

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]
      configuration = {
        Owner                = "sgarcialaguna"
        Repo                 = "aws-bootstrap"
        Branch               = "master"
        OAuthToken           = file(".github/aws-bootstrap-token")
        PollForSourceChanges = false
      }
    }
  }
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["build"]
      version          = "1"

      configuration = {
        ProjectName = "aws-bootstrap"
      }
    }
  }
  stage {
    name = "Staging"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build"]
      version         = "1"
      configuration = {
        ApplicationName     = "aws-bootstrap"
        DeploymentGroupName = aws_codedeploy_deployment_group.staging.deployment_group_name
      }
    }
  }
}

