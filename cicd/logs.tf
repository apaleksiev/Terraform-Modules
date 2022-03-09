resource "aws_cloudwatch_log_group" "cirrus" {
	name = "${var.app_name}-${var.app_env}-logs"
}
