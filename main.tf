provider "aws" {
  profile = "aws-profile"
  region  = var.aws_region
}

# creating vpc with cidr
resource "aws_vpc" "krish" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "cloud"
  }
}

# creating public subnet
resource "aws_subnet" "public_sub" {
  vpc_id            = aws_vpc.krish.id
  cidr_block        = var.pub_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public-Sub"
  }
}
resource "aws_subnet" "public_sub_2" {
  vpc_id            = aws_vpc.krish.id
  cidr_block        = var.pub_cidr_2
  availability_zone = "us-east-1b"


  tags = {
    Name = "Public-Sub-2"
  }
}
# creating private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.krish.id
  cidr_block        = var.pvt_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-sub"  
  }
}
#create internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.krish.id

  tags = {
    Name = "3-igw"
  }
}
#create route table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.krish.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "MyRoute"
  }
}
resource "aws_route_table_association" "sub_association" {
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.rtb.id
}
resource "aws_route_table_association" "sub_association_2" {
  subnet_id      = aws_subnet.public_sub_2.id
  route_table_id = aws_route_table.rtb.id
}
#using default route table
resource "aws_default_route_table" "dfltrtb" {
  default_route_table_id = aws_vpc.krish.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "dfltrtb"
  }
}
#create elastic ip
resource "aws_eip" "myeip" {
  vpc      = true
}
#create nat-gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.public_sub.id

  tags = {
    Name = "3-NAT"
  }
   depends_on = [aws_internet_gateway.gw]
}
#create ec2 instnce 
resource "aws_instance" "web" {
   tags = {
    Name = "web-server"
  }
  ami           = var.ec2_ami
  key_name      = var.instance_key
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public_sub.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow.id]
  user_data = file("script.sh")
 }
 #create ec2 instance-2
 resource "aws_instance" "web_2" {
   tags = {
    Name = "web-server-2"
  }
  ami           = var.ec2_ami
  key_name      = var.instance_key
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.public_sub_2.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.allow.id]
  user_data = file("shebang.sh")
 }
 #create ec2-private instance
 resource "aws_instance" "db" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type
  key_name = var.instance_key
  subnet_id = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.allow_db.id]

  tags = {
    Name = "DB-Server"
  }
}
 #security group for vpc-to-ec2
resource "aws_security_group" "allow" {
  name        = "allow"
  description = "Allow  inbound traffic"
  vpc_id      = aws_vpc.krish.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-sg"
  }
}
#create security group for database and private instance
resource "aws_security_group" "allow_db" {
  name        = "allow_db"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.krish.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-sg"
  }
}
#create load balancer
resource "aws_lb" "alb" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = var.load_balancer
  security_groups    = [aws_security_group.allow.id]
  subnets            =  [
    aws_subnet.public_sub.id,
    aws_subnet.public_sub_2.id,
  ]

  enable_deletion_protection = false

  tags = {
    Environment = "alb"
  }
}
#create target group
resource "aws_lb_target_group" "albtg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  target_type = var.target_type
  vpc_id   = aws_vpc.krish.id

  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 80  
  }
}
resource "aws_lb_target_group_attachment" "front_end" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.web.id 
  port             = 80
}
resource "aws_lb_target_group_attachment" "front_end_2" {
  target_group_arn = aws_lb_target_group.albtg.arn
  target_id        = aws_instance.web_2.id 

  port             = 80
}
#listern 
resource "aws_lb_listener" "albl" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.albtg.arn
  }
}
