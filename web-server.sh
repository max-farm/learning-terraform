#!/bin/bash
yum -y update
yum -y install httpd
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` #getting TOKEN
myip=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4` #accessing metadata using TOKEN
myhostname=`curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname` #accessing metadata using TOKEN
echo "<h1>--------------------------------------------------------------</h1><br><h1>Web-Server IP: $myip</h1><br><h1>URL: $myhostname</h1><br><h1>--------------------------------------------------------------</h1>" > index.html && sudo mv -i ./index.html /var/www/html/index.html 
sudo service httpd start
chkconfig httpd on