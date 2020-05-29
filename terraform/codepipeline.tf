resource "aws_codedeploy_app" "aws-bootstrap" {
  name             = "aws-bootstrap"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "staging" {
  deployment_group_name  = "staging"
  app_name               = aws_codedeploy_app.aws-bootstrap.name
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = aws_iam_role.deploy.arn
  autoscaling_groups     = [aws_autoscaling_group.webserver.id]
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
      name             = "Webserver_Image"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["imageDetail"]
      configuration = {
        RepositoryName = aws_ecr_repository.aws_bootstrap.name
      }
    }

    action {
      name             = "Scripts"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["scripts"]
      configuration = {
        S3Bucket    = aws_s3_bucket.aws-bootstrap-scripts.bucket
        S3ObjectKey = "scripts.zip"
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
      input_artifacts = ["scripts"]
      version         = "1"
      configuration = {
        ApplicationName     = "aws-bootstrap"
        DeploymentGroupName = aws_codedeploy_deployment_group.staging.deployment_group_name
      }
    }
  }
}

