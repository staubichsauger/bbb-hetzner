#!/bin/bash

terraform plan
terraform apply

ssh -o StrictHostKeyChecking=no -i $(cat variables.tf | grep id_rsa\" | sed 's#.*"\(.*id_rsa.*\).*"#\1#g') root@"$(cat terraform.tfvars | grep dnsname | sed 's#dnsname = "\(.*\)"#\1#g')" tail -f /var/log/cloud-init-output.log
