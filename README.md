# Rsyslog and Terraform in AWS
Collecting logs from one server and transferring them via Rsyslog to another

# Quick Start
1. Use this instuctions to install [Terraform](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started) and configurate AWS CLI 
2. Terraform will automatically search for saved API credentials in ~/.aws/credentials
3. Copy all file in one dirctory on you unix PC
4. Use command `terraform init` to initialize a working directory containing Terraform configuration files
5. Use command `terraform apply` to create VM's
6. To check loging file go to /var/log/rsyslog/ip-192-168-0-239 and check file *time_log*

# File list
1. Provider.tf - info for provider
2. Main.tf -  Create VM, copy file and run script
3. Securitygroup.tf - Create securitygroup for connect to VM
4. Subnet.tf - Create subnet to create custom network
5. Var.tf - variables

///////////////////// Scrips /////////////////////////////

1. Log.sh - log time and save to file
2. Script_cron.sh - Script to create scheduled task log.sh

//////////////// Сonfiguration Files /////////////////////

1. Rsyslog.conf - Conf file for rsyslog server
2. Time.conf - conf file for rsyslog client

//////////////// Virtual Mashine ////////////////////////

1. VM_RSYSLOG - Rsyslog server, private network ip 192.168.0.240
2. VM_log - Rsyslog client, private network ip 192.168.0.239

