#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html>
        <center>
	        <br>
	        <br>
	        <h1>HELLO DEVOPS ! KRUSHNA</h1>
		<br>
	        <h2>devops-server-created by terraform </h2>
	<center>
</html>" > /var/www/html/index.html
sudo systemctl restart httpd
sudo yum update -y
sudo yum install java-openjdk -y
sudo  curl -O https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.91/bin/apache-tomcat-8.5.91.tar.gz
sudo tar -xzvf apache-tomcat-8.5.91.tar.gz -C /home/ec2-user/
sudo /home/ec2-user/apache-tomcat-8.5.91/bin/catalina.sh start
sudo mv /home/ec2-user/target/* /home/ec2-user/apache-tomcat-8.5.91/webapps/

