
output "latest_amazon_linux_ami_id" { #image AMI id
  value = data.aws_ami.latest_amazon_linux.id
}

output "web_loadbalancer_url" {  #URL for accessing web-server 
  value = aws_lb.web.dns_name
}

output "env" {
  value = var.env
}

output "instance_type" {
  value = aws_launch_template.web.instance_type
}

output "monitoring" {
  value = var.enable_monitoring
}

output "region" {
  value = var.region
}

output "db-endpoint" {
  value = aws_db_instance.my_db.endpoint
}

output "name-az-1" {
  value = data.aws_availability_zones.available.names[0]
}

output "name-az-2" {
  value = data.aws_availability_zones.available.names[1] 
}