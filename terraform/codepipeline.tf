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
        OAuthToken           = file("../.github/aws-bootstrap-token")
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

