output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.service.name
}
