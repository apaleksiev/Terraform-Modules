resource "aws_codebuild_project" "cirrus" {
  name          = "${var.app_name}-${var.app_env}-build"
  description   = "Cirrus Codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.example.arn

  artifacts {
    type = "CODEPIPELINE"
  }

	cache {
		type		= "S3"
		location	= aws_s3_bucket.cirrus.bucket
	}

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
   
#may need to variablize the bucket here
    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = aws_s3_bucket.cirrus.id
    }
  }


  logs_config {
    cloudwatch_logs {
      group_name  = "${var.log_group}"
      stream_name = "${var.app_name}-${var.app_env}-codebuild"
    }

  source {
    type = "CODEPIPELINE"
  }

  source_version = var.app_branch
}


