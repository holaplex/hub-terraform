#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization
resource "google_certificate_manager_dns_authorization" "default" {
  name        = "hub-default-dnsauth-${random_id.rnd.hex}"
  description = "Certificate DNS Auth for Hub UI subdomain"
  domain      = local.values.project.domain
}

#https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate
resource "google_certificate_manager_certificate" "root_cert" {
  name        = "hub-default-rootcert"
  description = "hub default wildcard cert"
  managed {
    domains = [local.values.project.domain, "*.${local.values.project.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id
    ]
  }
}

output "dns_record_name" {
  value       = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
  description = "The DNS record name for the DNS challenge"
}

output "dns_cname_value" {
  value       = google_certificate_manager_dns_authorization.default.dns_resource_record[0].data
  description = "The CNAME value for the DNS challenge"
}
