terraform {
  required_providers {
    hcloud = ">= 1.16"
  }
}

data "hetznerdns_zone" "dns_zone" {
    name = var.domain_name
}

data "hcloud_ssh_key" "root_ssh_key" {
  fingerprint = var.root_ssh_key_fingerprint
}

resource "hcloud_server" "jitsi_server" {
  name = "${var.jitsi_sub_domain}.${var.domain_name}"
  location = "nbg1"
  image = "ubuntu-20.04"
  server_type = var.server_type
  ssh_keys = [
    data.hcloud_ssh_key.root_ssh_key.id
  ]
  user_data =<<EOF
#cloud-config
packages:
  - ansible
  - certbot
write_files:
  - content: |
      - hosts: jitsi-servers
        roles:
          - { role: systemli.letsencrypt }
          - { role: systemli.jitsi_meet }
        vars:
          jitsi_meet_server_name: "${var.jitsi_sub_domain}.${var.domain_name}"
          jitsi_meet_ssl_cert_path: "/etc/letsencrypt/live/{{ jitsi_meet_server_name }}/fullchain.pem"
          jitsi_meet_ssl_key_path: "/etc/letsencrypt/live/{{ jitsi_meet_server_name }}/privkey.pem"
          jitsi_meet_config_default_language: ${var.jitsi_default_language}
          letsencrypt_account_email: ${var.letsencrypt_account_email}
          letsencrypt_cert:
            name: "{{ jitsi_meet_server_name }}"
            domains:
              - "{{ jitsi_meet_server_name }}"
            challenge: http
            http_auth: standalone
    path: /root/jitsi-server.yml
  - content: |
      [jitsi-servers]
      ${var.jitsi_sub_domain}.${var.domain_name} ansible_connection=local
    path: /root/ansible_hosts
runcmd:
  - [ ansible-galaxy, install, systemli.letsencrypt ]
  - [ ansible-galaxy, install, systemli.jitsi_meet ]
  - [ ansible, -i /root/ansible_hosts, /root/jitsi-server.yml ]
  - [ ufw, allow, ssh ]
  - [ ufw, allow, http ]
  - [ ufw, allow, https ]
  - [ ufw, allow, in, 10000:20000/udp ]
  - [ ufw, enable ]
EOF
}

resource "hetznerdns_record" "jitsi_server" {
    zone_id = data.hetznerdns_zone.dns_zone.id
    name = var.jitsi_sub_domain
    value = hcloud_server.jitsi_server.ipv4_address
    type = "A"
    ttl= 60
}

