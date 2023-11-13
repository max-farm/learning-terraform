## exploring some terraform basics with aws
Building AWS ASG and ALB with web-server on 80 port with instances based on type of environment.

Web server installation script provided in web-server.sh 

Variables in terraform.tvfars can be changed to provide region, enable and disable monitoring and changes Environment - env. 

If env is "prod" the appropriate tags apllied and ASG scales to 2 instances and instance type t2.large. 

If env is other than "prod", for example "test", than t3.micro used for 1 instance. 
 
outputs.tf provide variables definitions output including load balancer URL.