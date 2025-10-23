output "public_ips" {
  value = {
    manager  = aws_instance.manager.public_ip
    worker_a = aws_instance.worker_a.public_ip
    worker_b = aws_instance.worker_b.public_ip
  }
}
