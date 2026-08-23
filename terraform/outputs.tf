output "cluster_id" {
  value = yandex_kubernetes_cluster.this.id
}

output "cluster_external_endpoint" {
  value = yandex_kubernetes_cluster.this.master[0].external_v4_endpoint
}

output "database_host" {
  value = yandex_mdb_postgresql_cluster.this.host[0].fqdn
}

output "bucket_name" {
  value = yandex_storage_bucket.app.bucket
}

output "lockbox_secret_id" {
  value = yandex_lockbox_secret.app.id
}
