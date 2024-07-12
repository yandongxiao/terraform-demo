# Terraform defined several top-level blocks, such as terraform, resource, data, output, and variable.
# 一个块有一个类型(例子里类型就是terraform)。每个块类型都定义了类型关键字后面要跟多少标签，例如 resource 块规定了后面要跟两个标签
# —— 在例子里就是 aws_eip_association 和 eip_assoc。一个块类型可以规定任意多个标签，也可以没有标签。
# 块体必须被包含在一对花括号中间。在块体中可以进一步定义各种参数和其他的块。
terraform {
  required_providers {
    # define a local name aws for provider
    aws = {
      # HCL 中的参数就是将一个值赋给一个特定的名称。
      # 所有的值都有一个类型。类型之间可以进行隐式转换，原始类型分三类：string、number、bool。
      source  = "hashicorp/aws"
      version = "~>5.0"
      configuration_aliases = [aws.west]
    }
  }
}

# 输入变量
# 在一个 Terraform 模块(同一个文件夹中的所有 Terraform 代码文件，不包含子文件夹)中变量名必须是唯一的.
# 我们在代码中可以通过var.<NAME>的方式引用变量的值。
# 对输入变量赋值有几种途径，一种是在调用 terraform plan 或是 terraform apply 命令时以参数的形式传入：
#   1. $ terraform apply -var="image_id=ami-abc123"
#   2. $ terraform apply -var='image_id_list=["ami-abc123","ami-def456"]'
#   3. $ terraform plan -var='image_id_map={"us-east-1":"ami-abc123","us-east-2":"ami-def456"}'
# 第二种方法是使用参数文件。参数文件的后缀名可以是 .tfvars. 执行：terraform apply -var-file="testing.tfvars"
# 有两种情况，你无需指定参数文件：
#   1. 当前模块内有名为 terraform.tfvars 或是 terraform.tfvars.json 的文件
#   2. 当前模块内有一个或多个后缀名为 .auto.tfvars 或是 .auto.tfvars.json 的文件
# 可以通过设置名为 TF_VAR_<NAME> 的环境变量为输入变量赋值，例如：export TF_VAR_image_id=ami-abc123
variable "image_id" {
  # 可以在输入变量块中通过 type 定义类型
  type = string

  validation {
    # condition 参数是一个 bool 类型的参数，我们可以用一个表达式来定义如何界定输入变量是合法的
    # condition 表达式中只能通过 var.\<NAME\> 引用当前定义的变量，并且它的计算不能产生错误。
    # 如果表达式会产生错误，那么可以使用 can 函数来判定表达式的执行是否抛错。can(regex("^ami-", var.image_id))
    # 这个错误会被 can 函数捕获，输出 false。
    condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }

  # 将变量设置为 sensitive 可以防止我们在配置文件中使用变量时 Terraform 在 plan 和 apply 命令的输出中展示与变量相关的值。
  # 但是：Terraform 仍然会将敏感数据记录在状态文件中，任何可以访问状态文件的人都可以读取到明文的敏感数据值。
  sensitive = true

  # 输入变量的 nullable 参数控制模块调用者是否可以将 null 赋值给变量。
  # nullable 的默认值为 true。当 nullable 为 true 时，null 是变量
  # 的有效值，并且模块代码必须始终考虑变量值为 null 的可能性。将 null 作为模块输入参数传递将覆盖输入变量上定义的默认值。
  # 将 nullable 设置为 false 可确保变量值在模块内永远不会为空。如果 nullable 为 false 并且输入变量定义有默认值，则
  # 当模块输入参数为 null 时，Terraform 将使用默认值。
  nullable = false
  default  = "ami-12345"
}

variable "availability_zone_names" {
  type = list(string)
  # 默认值定义了当 Terraform 无法获得一个输入变量得到值的时候会使用的默认值。
  default = ["us-west-1a"]
  # 简单地向调用者描述该变量的意义和用法
  description = "The id of the machine image (AMI) to use for the server."
}

variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
      internal = 8300
      external = 8300
      protocol = "tcp"
    }
  ]
}

# the configuration for the aws provider
# this "aws" it the Local Name for the provider.
provider "aws" {
  # There is a "meta-arguments" that are defined by Terraform itself and available for all provider blocks: alias.
  # If alias is not set, It is the default provider configuration; resources that begin with `aws_` will use it as
  # the default, and it can be referenced as `aws`.
  #
  # Other parameters are defined by the aws provider.
  # You can use expressions in these values, but you can only reference values that are known at the time the provider
  # is configured.
  # Some providers can use environment variables as the value of some configuration parameters; we recommend using this
  # method as much as possible to avoid storing credentials in the Terraform code.

  # we use localstack for testing, so we don't need to set the access_key and secret_key
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  s3_use_path_style           = false
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # we use localstack for testing, so we need to set the endpoints
  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

# Additional provider configuration for west coast region; resources can reference this as `aws.west`.
# So we can use alias to define multiple configurations for the same provider, for example, to create
# resources in different regions.
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# use the data module to get data from aws. E.g. get the AMI id for the ubuntu image
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-20170727"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# use the resource module to create resources in aws. E.g. create an ec2 instance
resource "aws_instance" "web" {
  provider      = "aws"
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.web.id
  allocation_id = aws_eip.example.id
}

resource "aws_eip" "example" {
  domain = "vpc"
}

output "instance_id" {
  value = aws_instance.web.id
}
