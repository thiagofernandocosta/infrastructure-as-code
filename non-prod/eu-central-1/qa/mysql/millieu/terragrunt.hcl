locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  # Automatically load environment-level variables
  vars = read_terragrunt_config("vars.hcl")

}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "git::git@github.com:thiagofernandocosta/terraform-aws-rds.git?ref=${local.vars.locals.tag}"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  master_username = "admin"

  identifier = "${local.vars.locals.name}-${local.env}"

  engine            = "mysql"
  engine_version    = "5.7.19"
  instance_class    = "db.t2.micro"
  allocated_storage = 5

  name     = "${local.vars.locals.name}_${local.env}"
  username = "user"
  password = "mypassword"
  port     = "3306"

  iam_database_authentication_enabled = false

  # vpc_security_group_ids = ["sg-12345678"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval    = "0"
  monitoring_role_name   = "MyRDSMonitoringRole"
  create_monitoring_role = false

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  # DB subnet group
  db_subnet_group_name = "devops_automation_test"
  option_group_name = "devops-automation-option-group"

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${local.vars.locals.name}-${local.env}"

  # Database Deletion Protection
  deletion_protection = false

  create_db_subnet_group    = "false"
  create_db_option_group    = "false"
  create_db_parameter_group = "false"

  multi_az = false

}
