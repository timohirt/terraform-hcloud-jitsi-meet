output "jitsi_server_id" {
    value = hcloud_server.jitsi_server.id
    description = "The id of the server which runs jitsi."
}

output "jitsi_server_ipv4_address" {
    value = hcloud_server.jitsi_server.ipv4_address
    description = "The ipv4 address assigned to the Jitsi server." 
}

