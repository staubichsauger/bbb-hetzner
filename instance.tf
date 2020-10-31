resource "hcloud_server" "server" {                     # Create a server
  name = "server-${local.name}"                         # Name server
  image = "${var.image}"                                # Basic image
  server_type = "${var.server_type}"                    # Instance type
  location = "${var.location}"                          # Region
  backups = "false"                                     # Enable backups
  ssh_keys = ["${hcloud_ssh_key.user.id}"]              # SSH key
  user_data = "${data.template_file.instance.rendered}" # The script that works when you start

  provisioner "file" {                                  # Copying files to instances
    source = "user-data/file"                           # Path to file on local machine
    destination = "/root/file"                          # Path to copy
  }
}

# File definition user-data
data "template_file" "instance" {
    template = "${file("${path.module}/user-data/instance.tpl")}"
}

# Definition ssh key from variable
resource "hcloud_ssh_key" "user" {
    name = "user"
    public_key = "${var.public_key}"
}
