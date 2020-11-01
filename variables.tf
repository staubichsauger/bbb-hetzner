# Token Variable Definition
variable "hcloud_token" {}

# Name variable definition
variable "name" {
	default = "bbb"
}
variable "dnsname" {}

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

# Define the names of the Hetzner Cloud prerequisites
variable "floating_ip_name" {
	default = "video"
}
variable "volume_name" {
	default = "certs"
}

# Determining the ssh key that will be added to the instance when creating
variable "public_key_path" {
	default = "tmp/id_rsa.pub"
}
variable "private_key_path" {
	default = "tmp/id_rsa"
}

# Admin credentials
variable "admin_email" {}
variable "admin_pwd" {}
