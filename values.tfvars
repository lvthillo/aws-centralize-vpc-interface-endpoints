region                    = "eu-west-1"
assumed_role              = "<deploy_role>"
vpc_endpoint_service_list = ["sqs", "ssm", "ec2messages", "ssmmessages", "kms"]
account_1 = {
  account_id  = "<account_id_1>"
  vpc_name    = "vpc-1"
  vpc_cidr    = "10.0.0.0/16"
  vpc_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
account_2 = {
  account_id  = "<account_id_2>"
  vpc_name    = "vpc-2"
  vpc_cidr    = "192.168.10.0/24"
  vpc_subnets = ["192.168.10.0/26", "192.168.10.64/26", "192.168.10.128/26"]
}
account_3 = {
  account_id  = "<account_id_3>"
  vpc_name    = "vpc-3"
  vpc_cidr    = "192.168.100.0/24"
  vpc_subnets = ["192.168.100.0/26", "192.168.100.64/26", "192.168.100.128/26"]
}