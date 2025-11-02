variable "ami_id" {
  type = string

  description = "ami used fro creating instance"
}

variable "instance_type" {
  type        = string
  description = "instance type"
  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "select micro small medium of t3"
  }

}

#this becomes mandatory if there is no default
variable "sg_id" {
  type = list(any)
}

# this becomes optional if default is empty
variable "ec2_tags" {
  type    = map(any)
  default = {}
}
