output "instance_id" {
  description = "EC2 instance ID"
  value = aws_instance.example.id
}

output "instance_state" {
  description = "ECs state"
  value = aws_instance.example.instance_state
}