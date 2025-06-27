project_name   = "obligatorio-sparis"
environment    = "dev"


vpc_name = "dev-vpc"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]

cluster_name = "dev-eks"


node_group_name = "dev-node-group"

existing_role_arn = "arn:aws:iam::928352609536:role/c155737a4002552l10231790t1w9283526095-LambdaSLRRole-6gMaxEt1S76h"




