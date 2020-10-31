# Token Variable Definition
variable "hcloud_token" {}

# Name variable definition
variable "name" {
	default = "bbb"
}

# Defining a variable source OS image for an instance
variable "image" {
	default = "debian-10"
}

# Definition of an instance type variable depending on the choice of tariff
variable "server_type" {
	default = "cx31"
}

# Definition of the region in which the instance will be created
variable "location" {
	default = "nbg1"
}

# Determining the ssh key that will be added to the instance when creating
variable "public_key" {}
variable "private_key_path" {}
