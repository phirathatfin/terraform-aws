data "aws_availability_zones" "available" {}

locals {
  region                       = "ap-southeast-1"
  name                         = "terraform-ecs"
  instance_type                = "t2.micro"
  autoscaling_name             = "terraform-ecs-asg"
  autoscaling_min_size         = 1
  autoscaling_max_size         = 1
  autoscaling_desired_capacity = 1

  service1_name                  = "service1"
  service1_container_name        = "service1"
  service1_container_port        = 3000
  service1_container_image_url   = ""
  service1_health_check_path     = "/nest-aws/v1"
  service1_loadbalancer_listener = "/nest-aws*"

  service2_name                  = "service2"
  service2_container_name        = "service2"
  service2_container_port        = 3000
  service2_container_image_url   = ""
  service2_health_check_path     = "/nest-aws/v1"
  service2_loadbalancer_listener = "/nest-aws*"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/Finstable/terraform-aws"
  }
}
