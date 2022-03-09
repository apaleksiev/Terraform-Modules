
variable "aws_region" {
	description = "AWS Region"
	type	    = string
	default	    = "us-east-1"
}

variable "app_name" {
	description = "Application Name"
	type	    = string
	default	    = "cirrus"
}

variable "app_env" {
	description = "Application Environment"
	type	    = string
	default	    = "development"
}

variable "app_branch" {
	description = "CodePipeline Trigger Branch"
	type	    = string
	default	    = "development"
}

variable "log_group" {
	description = "Cloudwatch Logs"
	type	    = string
	default	    = ""
}

variable "container_frontend_cpu" {
	description = "Frontend container cpu"
	type	    = number
	default	    = 512
}

variable "container_frontend_mem" {
	description = "Frontend container mem"
	type	    = number
	default	    = 1024
}
