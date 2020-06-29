# Jitsi Server

Create a virutal machine and set up a Jitsi meet server with Terraform.

## Prerequisites

- Before you start, you need to change the domain server of your domain to point
  to the Hetzner domain servers. Typically, this can be done at the registrar
  you used to register your domain name.
  
- Create a new or find an existing Terraform project to add the Jitsi server.

- Providers [are not shipped](https://www.terraform.io/docs/configuration/modules.html#providers-within-modules)
  with this module and must be added to the Terraform project. Add the 
  following to `terraform.tf` in the project directory:

        variable "hcloud_token" {}

        provider "hcloud" {
                version = "~> 1.16.0"
                token = var.hcloud_token
        }

        variable "hetznerdns_token" {}

        provider "hetznerdns" {
            apitoken = var.hetznerdns_token
        }

        provider "random" {
            version = "~> 2.2"
        }

- Set Hetzner Cloud API Token in tfvars file, env, or use a parameter. Add
  the following to `terraform.tfvars` in the root of your Terraform project and
  replace the placeholders with your actual API tokens.

        hcloud_token = "<Hetzner Cloud API Token>"
        hetznerdns_token = "<Hetzner DNS API Token>"

- Add a SSH key resource or add a data source referencing an existing key at
  Hetzner Cloud. This key will be used to create the virtual machine and
  install the Jitsi server. You can ssh into this virtual machine
  as root using this SSK key.

        resource "hcloud_ssh_key" "root" {
            name = "root@${var.domain_name}"
            public_key = file("~/.ssh/id_rsa.pub")
        }

## Example

```
data "hcloud_ssh_key" "ssh_key_1" {
  name = "my-key"
}

module "jitsi_server" {
    source = "git@github.com:timohirt/terraform-hcloud-jitsi-meet.git"

    root_ssh_key_fingerprint = data.hcloud_ssh_key.ssh_key_1.fingerprint
    domain_name = "example.com"
    jitsi_sub_domain = "jitsi"
    letsencrypt_account_email = "jitsi@example.com"
}
```




