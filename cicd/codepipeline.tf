resource "aws_codestarconnections_connection" "cirrus" {
	name		= "${var.app_name}-${var.app_env}-cs-connect"
	provider_type	= "GitHub"
}



resource "aws_codepipeline_webhook" "cirrus" {
	name		= "${var.app_name}-${var.app_env}-cp-webhook"
	authentication	= "UNAUTHENTICATED"
	target_action	= "Source"
	target_pipeline	= aws_codepipeline.cirrus.name

	filter {
		json_path	= "$.ref"
		match_equals	= "refs/heads/{Branch}"
	}
}



resource "aws_codepipeline" "cirrus" {
	name		= "${var.app_name}-${var.app_env}-codepipeline"
	role_arn	= aws_iam_role.cirrus_codepipeline.arn

	artifact_store {
		location	= aws_s3_bucket.cirrus.bucket
		type		= "S3"
	}

	stage {
		name	= "Source"

		action {
			name			= "Source"
			category		= "Source"
			owner			= "AWS"
			provider		= "CodeStarSourceConnection"
			version			= "1"
			output_artifacts	= ["source_output"]

			configuration = {
				ConnectionArn		= aws_codestarconnections_connection.cirrus.arn
				FullRepositoryId	= "Cirrus/project"
				BranchName		= "${var.app_branch}"
			}
		}
	}

	stage {
		name	= "Build"

		action {
			name			= "Build"
			category		= "Build"
			owner			= "AWS"
			provider		= "CodeBuild"
			input_artifacts		= ["source_output"]
			output_artifacts	= ["build_output"]
			version			= "1"

			configuration	= {
				ProjectName	= aws_codebuild_project.cirrus.name
			}
		}
	}

	stage {
		name	= "Deploy"

		action {
			name		= "Deploy"
			category	= "Deploy"
			owner		= "AWS"
			provider	= "ECS"
			input_artifacts	= ["build_output"]
			version		= "1"

			configuration	= {
				ClusterName	= aws_ecs_cluster.cirrus.name
				ServiceName	= aws_ecs_service.cirrus.name
			}
		}
	}
}

