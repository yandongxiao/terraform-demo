# 局部值就相当于函数内定义的局部变量
locals {
  service_name = "forum"
  owner        = "Community Team"
}

locals {
  # Ids for multiple sets of EC2 instances, merged together
  instance_ids = concat(aws_instance.blue.*.id, aws_instance.green.*.id)
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Service = local.service_name
    Owner   = local.owner
  }
}

resource "aws_instance" "example" {
  # ...

  tags = local.common_tags
}

# 输出值只有在执行 terraform apply 后才会被计算，光是执行 terraform plan 并不会计算输出值。
# 如果我们把一组 Terraform 代码想像成一个函数，那么输入变量就是函数的入参；函数可以有入参，也可以有返回值，同样的，Terraform 代码也可以有返回值，这就是输出值。
output "instance_ip_addr" {
  value       = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."
}
