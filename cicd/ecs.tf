resource "aws_security_group" "cirrus_ecs_sg" {
	name	= "${var.app_name}-${var.app_env}-ecs-sg"
	vpc_id	= "${module.vpc.vpc_id}"

	ingress {
		from_port	= 8080
		protocol	= "tcp"
		to_port		= 8080
		security_groups = ["${aws_security_group.cirrus_frontend.id}"]
	}

        egress {
		from_port       = 0
		protocol        = "-1"
		to_port         = 0
		cidr_blocks     = ["0.0.0.0/0"]
	}

	tags = {
		Name	= "${var.app_name}-${var.app_env}-ecs-sg"
	}
}

resource "aws_ecs_cluster" "cirrus" {
	name			= "${var.app_name}-${var.app_env}-ecs"
	capacity_providers	= ["FARGATE"]

	setting {
		name	= "containerInsights"
		value	= "enabled"
	}
}

resource "aws_ecs_service" "cirrus_ecs_service" {
	name            = "${var.app_name}-${var.app_env}-ecs-service"
	cluster         = aws_ecs_cluster.cirrus.arn

	
	task_definition	= aws_ecs_task_definition.cirrus.arn

	desired_count   = 1
	launch_type     = "FARGATE"

	load_balancer {
		target_group_arn	= aws_lb_target_group.cirrus.arn
		container_name		= "cirrus"
		container_port		= 8080
	}

	network_configuration {
		subnets			= "${module.vpc.public_subnets}"
		security_groups		= ["${aws_security_group.cirrus_ecs_sg.id}"]
		assign_public_ip	= "true"
	}

	lifecycle {
		ignore_changes	= [desired_count]
	}
}

resource "aws_ecs_task_definition" "cirrus" {
	family			= "${var.app_name}-${var.app_env}-ecs-task-definition"
	task_role_arn		= aws_iam_role.cirrus_ecs_task_role.arn
	execution_role_arn	= aws_iam_role.cirrus_ecs_task_exec_role.arn
	container_definitions	= <<TASK_DEFINITION
[
  {
    "name": "cirrus-frontend",
    "image": "${aws_ecr_repository.cirrus.arn}/cirrus:latest",
    "cpu": ${var.container_frontend_cpu},
    "memory": ${var.container_frontend_mem},
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
	    "awslogs-group": "${aws_cloudwatch_log_group.cirrus.name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "frontend"
        }
    }
  }
]
TASK_DEFINITION

	cpu				= "${var.container_frontend_cpu}"
	memory				= "${var.container_frontend_mem}"
	network_mode			= "awsvpc"
	requires_compatibilities	= ["FARGATE"]
}
