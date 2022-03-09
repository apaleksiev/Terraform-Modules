resource "aws_ecr_repository" "cirrus" {
	name			= "${var.app_name}-${var.app_env}-ecr"
	image_tag_mutability	= "MUTABLE"

	image_scanning_configuration {
		scan_on_push	= true
	}
}
