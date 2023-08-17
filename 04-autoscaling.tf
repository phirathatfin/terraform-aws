data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"
  for_each = {
    # On-demand instances
    asg = {
      instance_type              = local.instance_type
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      user_data                  = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${local.name}
        ECS_LOGLEVEL=debug
        EOF
      EOT
    }
  }

  name                            = "${local.name}-${each.key}"
  image_id                        = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type                   = each.value.instance_type
  security_groups                 = [module.ecs_sg.security_group_id]
  user_data                       = base64encode(each.value.user_data)
  ignore_desired_capacity_changes = true
  iam_instance_profile_name       = "ecsInstanceRole"
  create_iam_instance_profile     = false
  vpc_zone_identifier             = module.vpc.private_subnets
  health_check_type               = "EC2"
  min_size                        = local.autoscaling_min_size
  max_size                        = local.autoscaling_max_size
  desired_capacity                = local.autoscaling_desired_capacity

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  # Spot instances
  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy

  tags = local.tags
}
