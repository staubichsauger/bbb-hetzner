resource "hcloud_server" "server" {                     # Create a server
  name = "server-${local.name}"                         # Name server
  image = var.image                                # Basic image
  server_type = var.server_type                    # Instance type
  location = var.location                          # Region
  backups = "false"                                     # Enable backups
  ssh_keys = [hcloud_ssh_key.user.id]              # SSH key
  user_data = data.template_file.instance.rendered # The script that works when you start

  connection {
    type = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host = self.ipv4_address
  }

  provisioner "file" {                                  # Copying files to instances
    source = "user-data/https.yml"                           # Path to file on local machine
    destination = "/tmp/https.yml"                          # Path to copy
  }
}

# File definition user-data
data "template_file" "instance" {
    template = file("${path.module}/user-data/instance.tpl")
}

# Definition ssh key from variable
resource "hcloud_ssh_key" "user" {
    name = "user"
    public_key = var.public_key
}

data "hcloud_floating_ip" "video" {
  name = "video"
}

resource "hcloud_floating_ip_assignment" "video" {
  floating_ip_id = data.hcloud_floating_ip.video.id
  server_id = hcloud_server.server.id
}

data "hcloud_volume" "certs" {
  name = "certs"
}

resource "hcloud_volume_attachment" "certs" {
  volume_id = data.hcloud_volume.certs.id
  server_id = hcloud_server.server.id
  automount = false
}
