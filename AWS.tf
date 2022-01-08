provider "aws" {
    access_key = "xxx"
    secret_key = "www"
    region = "eu-central-1"
}

resource "aws_instance" "my_Ubuntu" {
    ami = "ami-0d527b8c289b4af7f"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.my_WS.id]
    tags = {
    Name = "My_Web"
    Owner = "Maydannikov"
    Project = "Trial_project"
    }
    depends_on = [aws_instance.my_Jenkins]
    key_name = "enter_here_your_key"
}

resource "aws_security_group" "my_WS" {
  name        = "WebS"
  description = "MySG"

  ingress {
    description      = "SG"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mySG"
  }
}

resource "aws_instance" "my_Jenkins" {
    ami = "ami-0d527b8c289b4af7f"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.my_WS.id]
    tags = {
    Name = "My_Jenkins"
    Owner = "Maydannikov"
    Project = "Trial_project"
    }
    key_name = "enter_here_your_key"
}
