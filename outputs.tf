output "jitsi_server_id" {
    value = hcloud_server.jitsi_server.id
    description = "The id of the server which runs jitsi."
}