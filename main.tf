terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.20.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "2.3.0"
    }
  }
  required_version = ">= 0.13"
}


locals {
  fqdn = "${var.jitsi_sub_domain}.${var.domain_name}"
}

data "hcloud_ssh_key" "root_ssh_key" {
  fingerprint = var.root_ssh_key_fingerprint
}

resource "random_password" "password" {
  length  = 42
  special = true
}

resource "hcloud_server" "jitsi_server" {
  name        = local.fqdn
  location    = var.location
  image       = "ubuntu-20.04"
  server_type = var.server_type
  ssh_keys = [
    data.hcloud_ssh_key.root_ssh_key.id
  ]
  user_data = <<EOF
#cloud-config
packages:
  - ansible
  - certbot
write_files:
  - content: |
      - hosts: ${var.jitsi_sub_domain}
        roles:
          - { role: systemli.letsencrypt }
          - { role: systemli.jitsi_meet }
        vars:
          jitsi_meet_server_name: "${local.fqdn}"
          jitsi_meet_ssl_cert_path: "/etc/letsencrypt/live/{{ jitsi_meet_server_name }}/fullchain.pem"
          jitsi_meet_ssl_key_path: "/etc/letsencrypt/live/{{ jitsi_meet_server_name }}/privkey.pem"
          jitsi_meet_config_default_language: ${var.jitsi_default_language}
          jitsi_meet_base_secret: "${random_password.password.result}"
          letsencrypt_account_email: ${var.letsencrypt_account_email}
          letsencrypt_cert:
            name: "{{ jitsi_meet_server_name }}"
            domains:
              - "{{ jitsi_meet_server_name }}"
            challenge: http
            http_auth: standalone
    path: /root/jitsi-server.yml
  - content: |
      [${var.jitsi_sub_domain}]
      ${local.fqdn} ansible_connection=local
    path: /root/ansible_hosts
runcmd:
  - [ ansible-galaxy, install, systemli.letsencrypt ]
  - [ ansible-galaxy, install, systemli.jitsi_meet ]
  - [ ansible-playbook, -i /root/ansible_hosts, /root/jitsi-server.yml ]
  - [ ufw, allow, ssh ]
  - [ ufw, allow, http ]
  - [ ufw, allow, https ]
  - [ ufw, allow, in, 10000:20000/udp ]
  - [ ufw, enable ]
EOF
}

