# with module
module "alb_sg" {
  source              = "terraform-aws-modules/security-group/aws"
  version             = "~> 4.0"
  name                = "${local.name}-alb-sg"
  description         = "ALB security group"
  vpc_id              = module.vpc.vpc_id
  ingress_rules       = ["http-80-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = module.vpc.private_subnets_cidr_blocks

  tags = local.tags
}

module "ecs_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 4.0"
  name        = "${local.name}-ecs-sg"
  description = "ECS security group"
  vpc_id      = module.vpc.vpc_id
  computed_ingress_with_source_security_group_id = [
    {
      from_port                = 0
      to_port                  = 65535
      protocol                 = "tcp"
      description              = "ECS ports"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = local.tags
}
