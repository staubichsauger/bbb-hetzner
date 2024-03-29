# ⚠️ DEPRECATED ⚠️

Just use the Hetzner app image when creating a server. It works fine with smaller instances than the recommended server sizes if you just want it for a small conference. The setup in this repo no longer works and will not be maintained.

# Deploy a temporary BigBlueButton instance to the Hetzner Cloud using terraform

This repository contains a [terraform](https://www.terraform.io/) configuration to deploy [BigBlueButton](https://bigbluebutton.org/) to the [Hetzner Cloud](https://www.hetzner.com/cloud) using [bbb-docker](https://github.com/alangecker/bigbluebutton-docker). The result is meant for temporary on-demand BBB instances, but could be modified for more permanent deployments.

## Prerequisites

- Terraform installation
- Hetzner Cloud account and API token for the project you want to deploy to
- Floating IPv4 address and 10GB volume inside the Hetzner Cloud project
- Domain name with the DNS A-record pointing to the Hetzner Cloud floating IP address
- ssh-keygen installed or ssh key without password protection

## Setup

Rename ```terraform.tfvars.example``` to ```terraform.tfvars``` and add your desired configuration to it:
- hcloud_token is your Hetzner Cloud API token
- dnsname is the domain name which point to the floating IP
- admin_email/pwd will be your admin crendentials of the newly created BBB installation

Set your desired values inside the ```variables.tf``` file (do NOT place the info contained in the ```terraform.tfvars``` inside this file as well!):
- image: I only tested debian, you may try a different image without any guarantees
- server_type: size of the server - I don't have much experience yet, but 3c/4g (cpx21) and 2c/8g (cx31) have worked with a few people so far. BBB recommends 8c/16g for "production use" - whatever that means
- loaction: location of the server, choose the one closest to you. keep in mind the floating IP and the volume must be located at the same location!
-floating_ip_/volume_name: names you have given the floating IP and volume
- public/private_key_path: path to a public/private ssh key used to access the VM. this only seems to accept ssh keys without a password. You can execute the ```gen-tmp-key.sh``` which will create a new password-less ssh keypair inside a new ```tmp``` folder. Use ssh -i ```tmp/id_rsa root@<your-domain-name>``` to ssh into the VM.

Have a look at the ```user-data/bbb-env``` file to see if the settings are as desired. Keep in mind that this is what currently works for me, any change might break the installation.

## Deployment
Run ```terraform init```, ```terraform plan```, and ```terraform apply``` to deploy the BBB server. Check the changes before typing ```yes``` at the apply step. Alternatively you can run the ```start.sh``` script after ```terraform init```, which will output the progress of the init script.

The volume is used to store your LetsEncrypt certificate, your BBB greenlight users and the custom built docker images. This accelerates consecutive deployments and carries users over.

Once you don't need the server any more, run ```terraform destroy```.

## Acknowledgments
The following links were essential to the creation this project:
- [alangecker/bigbluebutton-docker](https://github.com/alangecker/bigbluebutton-docker)
- [Terraform + Hetzner](https://blog.maddevs.io/terraform-hetzner-1df05267baf0)

## Licenses
This project has some copied/modified code from [alangecker/bigbluebutton-docker](https://github.com/alangecker/bigbluebutton-docker), which is provided under the [LGPL v3.0 licence](https://github.com/alangecker/bigbluebutton-docker/blob/v2.2.x/LICENSE). The copied/modified parts are:
- ```user-data/bbb-env```, which is a modified version of https://github.com/alangecker/bigbluebutton-docker/blob/v2.2.x/sample.env
- ```user-data/instance.tpl```, which contains code copied from https://github.com/alangecker/bigbluebutton-docker/blob/v2.2.x/scripts/setup
