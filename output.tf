output "instance_public_ip" {
  value = ["${aws_instance.efs-ec2.*.public_ip}"]
}
