module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name               = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.alb_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  #TODO: Update target group and http listener for each service
  target_groups = [
    # Default action
    {
      name             = "${local.name}-default"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
    # Service 1
    {
      name             = "${local.service1_name}-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = local.service1_health_check_path
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
    # Service 2
    {
      name             = "${local.service2_name}-tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        enabled             = true
        interval            = 30
        path                = local.service2_health_check_path
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
  ]


  http_tcp_listener_rules = [
    # Default action
    {
      http_tcp_listener_index = 0
      priority                = 1
      actions = [{
        type             = "forward"
        target_group_arn = module.alb.target_group_arns[0]
      }]

      conditions = [{
        path_patterns = ["/"]
      }]
    },
    # Service 1
    {
      http_tcp_listener_index = 0
      priority                = 2
      actions = [
        {
          type             = "forward"
          target_group_arn = module.alb.target_group_arns[1]
        },

      ]
      conditions = [{
        path_patterns = [local.service1_loadbalancer_listener]
      }]
    },
    # Service 2
    {
      http_tcp_listener_index = 0
      priority                = 3
      actions = [
        {
          type             = "forward"
          target_group_arn = module.alb.target_group_arns[2]
        },

      ]
      conditions = [{
        path_patterns = [local.service2_loadbalancer_listener]
      }]
    },

  ]

  tags = local.tags
}
