module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = local.name

  # Capacity provider - autoscaling groups
  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    # On-demand instances
    local.autoscaling_name = {
      auto_scaling_group_arn         = module.autoscaling[local.autoscaling_name].autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 2
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }
  # TODO: Update services
  services = {
    # Service 1
    (local.service1_name) = {
      lanch_type               = "EC2"
      requires_compatibilities = ["EC2"]
      network_mode             = "bridge"
      cpu                      = 512
      memory                   = 512
      capacity_provider_strategy = {
        # On-demand instances
        local.autoscaling_name = {
          weight            = 1
          capacity_provider = module.ecs_cluster.autoscaling_capacity_providers[local.autoscaling_name].name
          base              = 1
        }
      }
      desired_count = 1
      # Container definition(s)
      container_definitions = {
        (local.service1_container_name) = {
          image                    = local.service1_container_image_url
          cpu                      = 0,
          essential                = true,
          readonly_root_filesystem = false # Nestjs image requires access to write to root filesystem
          port_mappings = [
            {
              name          = local.service1_container_name,
              containerPort = local.service1_container_port,
              hostPort      = 0,
              protocol      = "tcp",
              appProtocol   = "http"
            }
          ],
          # log_configuration is created automatically

        }
      }

      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 1)
          container_name   = local.service1_container_name
          container_port   = local.service1_container_port
        }


      }
      subnet_ids = module.vpc.private_subnets
    }
    # Service 2
    (local.service2_name) = {
      lanch_type               = "EC2"
      requires_compatibilities = ["EC2"]
      network_mode             = "bridge"
      cpu                      = 512
      memory                   = 256
      capacity_provider_strategy = {
        # On-demand instances
        local.autoscaling_name = {
          weight            = 1
          capacity_provider = module.ecs_cluster.autoscaling_capacity_providers[local.autoscaling_name].name
          base              = 1
        }
      }
      desired_count = 1
      # Container definition(s)
      container_definitions = {
        (local.service2_container_name) = {
          image                    = local.service2_container_image_url
          cpu                      = 0,
          essential                = true,
          readonly_root_filesystem = false # Nestjs image requires access to write to root filesystem
          port_mappings = [
            {
              name          = local.service2_container_name,
              containerPort = local.service2_container_port,
              hostPort      = 0,
              protocol      = "tcp",
              appProtocol   = "http"
            }
          ],
          # log_configuration is created automatically

        }
      }

      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 2)
          container_name   = local.service2_container_name
          container_port   = local.service2_container_port
        }


      }
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = local.tags
}
