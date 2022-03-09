resource "aws_iam_role" "cirrus_cb" {
  name = "${var.app_name}-${var.app_env}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

#Logs, S3, ecr, lambda, codepipeline for now
resource "aws_iam_role_policy" "cirrus" {
  name = "${var.app_name}-${var.app_env}-codebuild-policy"
  role = aws_iam_role.cirrus_cb.id

  policy = <<POLICY

{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:*:*:${aws_cloudwatch_log_group.cirrus.name}:*",
                "arn:aws:logs:*:*:${aws_cloudwatch_log_group.cirrus.name}:*:*"
            ],
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ]
        },
        {
            "Action": [
                "s3:*",
                "ecr:*",
		"lambda:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::codepipeline-*"
            ],
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:GetBucketAcl",
                "s3:GetBucketLocation"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:CreateReportGroup",
                "codebuild:CreateReport",
                "codebuild:UpdateReport",
                "codebuild:BatchPutTestCases",
                "codebuild:BatchPutCodeCoverages"
            ],
            "Resource": [
                "arn:aws:codebuild:*:*:*"
            ]
        }
    ]
}
POLICY
}
