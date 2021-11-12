output "jumpbox_user" {
  value = random_string.username.result
}
output "jumpbox_password" {
  value = random_password.password.result
}