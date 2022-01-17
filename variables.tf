#variables.terraform 
variable "az_suffix" {
  type        = string
  default     = "_jss"
  description = "the suffix used to identify who created the Rescource"
}

variable "az_subscription_id" {
  type    = string
  default = "f3dcc913-3cdf-48b2-846f-6f5646072d3a"
}

variable "az_client_id" {
  type    = string
  default = "c506f66e-5c79-45a8-b426-464a69f70afe"
}

variable "az_client_secret" {
  type    = string
  default = "Z7fIGhDH3fvhPeXlh_cFUqjhks4A2wWalA"
}

variable "az_tenant_id" {
  type    = string
  default = "6c637512-c417-4e78-9d62-b61258e4b619"
}

variable "vnet_cidr" {
  default     = "10.0.0.0/16"
  description = "variable to set a cidr for loop for networks"
}
variable "subnet_list" {
  type    = set(string)
  default = ["subnet1", "subnet2", "subnet3", "subnet4"]
}

/*variable "subnet_numbers" {
  
}*/


/*
  "appId": "c506f66e-5c79-45a8-b426-464a69f70afe",
  "displayName": "module_4",
  "name": "c506f66e-5c79-45a8-b426-464a69f70afe",
  "password": "Z7fIGhDH3fvhPeXlh_cFUqjhks4A2wWalA",
  "tenant": "6c637512-c417-4e78-9d62-b61258e4b619"
  */