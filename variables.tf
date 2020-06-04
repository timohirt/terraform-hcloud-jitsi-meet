#
# Virtual Machine
#
# The jitis meet server is installed on a VM running at Hetzner Cloud.
# The "server_type" defines the resources (CPU, RAM) available for running
# jitsi and the price, of course.
#
# You can find the latest "server_types" on Hetzer Cloud website on by using
# their API (https://docs.hetzner.cloud/#server-types-get-all-server-types).
#
# "cx21" turned out to work well with 15 - 20 users and is the default.
#
variable "server_type" {
  type = string
  default = "cx21"
  description = "The server type determines CPU and RAM of the server to use."
}

# You can lookup the fingerprint (eg. "74:3a:..:bf:fb:6b:49:03") in Hetzner Cloud Console
# or get it from a data source or a resouce in your Terraform project.
variable "root_ssh_key_fingerprint" {
  type = string
  description = "Fingerprint of the ssh key at Hetzner Cloud which for root access."
}

#
# DNS
#
# It is assumed that a DNS Zone was already created at Hetzner DNS.
# The "domain_name" is used with a data source. The subdomain is
# created in the corresponding DNS zone. A Terraform resource 
# manages the state of the record.
# 
variable "domain_name" {
  type = string
  description = "The name of the DNS zone at Hetzener DNS to create DNS records for the server."
}

variable "jitsi_sub_domain" {
  type = string
  default = "meet"
  description = "The subdomain where jitsi server will be reachable and SSL certificates are generated for."
}

#
# SSL
#
# For encryption of data in transit, a SSL certificate is generated 
# at Let's Encrypt and then the reverse proxy is configured to use it.
#
# In order to generate certificates with Let's Encrypt, an account
# needs to be created or reused. 
#
# Set "letsencrypt_account_email" to this email. If no Let's Encrypt
# account exists, one is created automatically.
#
variable "letsencrypt_account_email" {
  type = string
  description = "Email of Let's Encrypt account."
}

#
# Jitsi
#
# The following variables can be used for customizing jitsi meet
# at least a little bit.
#
variable "jitsi_default_language" {
  type = string
  default = "en"
  description = "Default language of jitsi meet."
}

