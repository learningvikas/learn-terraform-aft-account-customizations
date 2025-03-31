resource "time_static" "deployment" {}

output "current_time" {
    value = time_static.deployment.rfc3339
}

output "current_date" {
    value = formatdata("DD-MM-YYYY", time_static.deployment.rfc3339)
}