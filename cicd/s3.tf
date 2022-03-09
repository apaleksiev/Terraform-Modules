resource "aws_s3_bucket" "cirrus" {
	bucket = "${var.app_name}-${var.app_env}-artifacts"
	acl    = "private"

	versioning {
	  enabled = true
	}
}

## TODO: add a blank lambda (blank.zip) as a bucket object to the bucket
