variable "subnets" {
  type = map(object({
    cidr_block       = string
    availability_zone = string
  }))
  default = {
    subnet1 = {
      cidr_block       = "10.0.1.0/24"
      availability_zone = "us-west-2a"
    }
    subnet2 = {
      cidr_block       = "10.0.2.0/24"
      availability_zone = "us-west-2b"
    }
  }
}

variable "db_data" {
  default = {
    username = "user"
    password = "password"
  }
}