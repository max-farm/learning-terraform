variable "region" {
    description = "pls enter region to deploy"
    default = "us-east-1"
}

variable "instance_type" { #instance type based on environment 
    description = "Enter instance type"
    default = "t3.micro"
}

variable "allow_ports" {  #list of ports based on evironment
    description = "list of ports to open in SG"
    type = list
    default = ["80", "443"]
  
}

variable "enable_monitoring" {
    description = "enable detailed monitioring of an EC2 instance"
    type = bool
    default = true
}

variable "common_tags" { 
    description = "common tags applied on all resources"
    type = map
    default = {
        Owner  = "Max"
        Project = "TerraProj"
    }
}

variable "env" {
    default = "prod"
}

variable "iam_users" {
    description = "A list if IAM users"
    default = ["foo", "bar"] 
}