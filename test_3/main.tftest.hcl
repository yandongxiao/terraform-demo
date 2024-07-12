# 每个测试文件包含以下根级别的属性和块
# 一个到多个 run 块。
# 零个到一个 variables 块。
# 零个到多个 provider 块。

variables {
  bucket_prefix = "test"

  #  基本类型分三类：string、number、bool。这是类型名称
  name = "ydx"
  age  = 25
  man  = true

  # 下面全部是复杂类型，复杂类型也支持隐式类型转换。

  # 集合内所有元素的类型必须相同。
  children = list("keyla")
  children2 = ["keyla"]   # 必须换成其它名称，否则， 报错Each argument may be set only once.
  # 键类型必须是 string，值类型任意
  parents = { "dad" : "xxx", "mum" : "yyy" }
  animals = set("aaa", "bbb")

  # 结构化类型
  me = {
    type = object({
      a = string
      b = string
      # any 是 Terraform 中非常特殊的一种类型约束，它本身并非一个类型，而只是一个占位符。
      # 每当一个值被赋予一个由 any 约束的复杂类型时，Terraform 会尝试计算出一个最精确的类型来取代 any。
      c = any
      d = optional(string)  # an optional attribute
      e = optional(number, 127) # an optional attribute with default value
    })
    default = {
      a = "a"
      b = "b"
      c = 1
    }
  }

  # tuple 类型，每个元素都有独立的类型
  t = tuple("ydx", 25, true)
}

# 默认情况下，Terraform 测试会创建真实的基础设施，并可以对这些基础设施进行断言和验证。
# 你可以通过更新 run 块中的 command 属性（下面有示例）来覆盖默认的测试行为。默认情况下，每个 run 块都会执行 command = apply，
# 命令 Terraform 对你的配置执行完整的 apply 操作。将 command 值替换为 command = plan 会告诉 Terraform 不为这个 run 块创建新的基础设施。
run "valid_string_concat" {
  # 不创建新的基础设施，相当于单元测试
  # 运行了一个单独的Terraform plan 命令，该命令创建了S3存储桶，然后通过检查实际名称是否与预期名称匹配，来验证计算名称的逻辑是否正确。
  command = plan

  assert {
    condition     = aws_s3_bucket.bucket.bucket == "test-bucket"
    error_message = "S3 bucket name did not match expected"
  }
}
