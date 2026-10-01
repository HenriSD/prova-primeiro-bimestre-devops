output "ec2_sg_id" {
  description = "ID do Security Group da EC2"
  value       = aws_security_group.ec2.id
}

output "rds_sg_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}
