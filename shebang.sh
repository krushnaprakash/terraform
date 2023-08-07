#!/bin/bash 
sudo yum update -y
sudo yum install httpd -y
systemctl start httpd
systemctl enable httpd
echo "<html>
        <center>
	        <br>
	        <br>
	        <h1>HELLO DEVOPS ENGG.</h1>
		<br>
	        <h2>devops-server</h2>
	 <center>                
</html>" > /var/www/html/index.html 
systemctl restart httpd
