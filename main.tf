# map和object混用，区别
variable "network" {
    description = ""
    type        = object({
        network = map(string)
        name  = string
    })
    default     = {
        network ={
          internal = 9000
          external = 9000
          ip       = "0.0.0.0"
          protocol = "tcp/udp"
        }
        name = "ss"
    }
}


# 循环加索引
output "network" {
    value    = var.network
}

variable "test" {
    type = set(object({
        # 使用set去重
        name = string
    }))
    default = [
        {name = "test1"},
        {name = "test2"},
        {name = "test3"},
        {name = "test4"},
        {name = "test5"},
        {name = "test5"}
    ]
}



output "test" {
    value = {for idx,t in flatten(var.test) : idx =>{
        #flatten将set再次转化成list，否则无法使用此循环
        name = t.name
        prex = 100+idx
    }}
}

#双重for循环
locals {
  services = [
    jsondecode(<<json
{
    "instance_name": "front",
    "instance_count": "3",
    "instance_type": "t2.micro",
    "subnet_type": "private",
    "elb": "yes",
    "data_volume": ["no", "0"]
}
    json
  ),
    jsondecode(<<json
{
    "instance_name": "back",
    "instance_count": "3",
    "instance_type": "t2.micro",
    "subnet_type": "private",
    "elb": "yes",
    "data_volume": ["no", "0"]
}
    json
    ),
  ]

  service_instances = flatten([
    for svc in local.services : [
      for i in range(1, svc.instance_count+1) : {
        instance_name = "${svc.instance_name}-${i}"
        instance_type = svc.instance_type
        subnet_type   = svc.subnet_type
        elb           = svc.elb
        data_volume   = svc.data_volume
      }
    ]
  ])
}


output "first_args" {
  value = local.service_instances
}