output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "listener_arn" {
  description = "ARN of the ALB listener"
  value       = aws_lb_listener.http.arn
}
