provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_security_group" "mysql_sg" {
  name        = "mysql-security-group"
  description = "Security group for MySQL"

  #Regla de entrada para puerto MySQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    # Permite el acceso desde cualquier IP.
    cidr_blocks = ["0.0.0.0/0"]  
  }
}

resource "aws_db_instance" "default" {
  #RDS name
	identifier            = "db-pruebatecnica"
	#Storage
  allocated_storage     = 20
  storage_type          = "gp2"
	#Engine
  engine                = "mysql"
  engine_version        = "8.0.32"
	#Family
  instance_class        = "db.t3.micro"
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]

	#DB details
  username              = "admin"
  password              = "123456abc"
	skip_final_snapshot   = true
  publicly_accessible  = true

}