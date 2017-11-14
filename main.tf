provider "aws" {
  region = "${var.aws_region}"
  version = "~> 1.2"
}

resource "aws_security_group" "efs-client" {
  name        = "ec2-efs-client-sg"
  description = "Security group for EFS Client"
  vpc_id      = "${var.vpc_prod_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["74.109.185.9/32"]
  }

  ingress {
    from_port   = 1024
    to_port     = 1048
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "EFS-client-sg"
    owner = "alalla"
    env = "dev"
    Builder = "Terraform"
  }
}

resource "aws_security_group" "efs-mount" {
  name        = "EFS-mount-sg"
  description = "Security group for EFS mount target"
  vpc_id      = "${var.vpc_prod_id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_group_id = ["${aws_security_group.efs-client.id}"]
  }

  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "EFS-mount-sg"
    owner = "alalla"
    env = "dev"
    Builder = "Terraform"
  }
}

resource "aws_efs_file_system" "efs-master" {
    performance_mode = "generalPurpose"

    tags {
      Name = "EFS-MASTER"
      owner = "alalla"
      env = "dev"
      Builder = "Terraform"
    }
}

resource "aws_efs_mount_target" "efs-mount-target" {
  #count = "${length(split(", ", lookup(var.az_id, var.aws_region)))}"
  file_system_id = "${aws_efs_file_system.efs-master.id}"
  subnet_id = "${var.subnet_id}"
  security_groups = ["${aws_security_group.efs-mount.*.id}"]
}

resource "aws_instance" "efs-ec2" {
  ami           = "${var.aws_ami}"
  instance_type = "${var.instance_type}"

  tags {
    Name = "ec2-efs-client"
    owner = "alalla"
    env = "dev"
    Builder = "Terraform"
  }

  availability_zone = "${var.az_id}"
  subnet_id         = "${var.subnet_id}"
  key_name          = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.efs-client.id}"]
  associate_public_ip_address = true
  
  connection {
    user        = "ec2-user"
    key_file    = "${file(var.ssh_key_filename)}"
    agent       = false
    timeout     = "60s"
  }

  provisioner "remote-exec" {
    inline = [
    # mount EFS volume
    # create a directory to mount efs volume
    "sudo mkdir -p /mnt/efs", 
    # mount the efs volume
    "sudo mount -t nfs4 -o nfsvers=4.1 ${aws_efs_mount_target.efs-mount-target.dns_name}:/ /mnt/efs", 
    # create fstab entry to ensure automount
    "sudo su -c \"echo '${aws_efs_mount_target.efs-mount-target.dns_name}:/ /mnt/efs nfs defaults,vers=4.1 0 0' >> /etc/fstab\""
    ]
  }
  
}