#
# main
#
# This terraform plan does nothing
#
# variables
#
variable "file" {
  description = "Path to file to return, full path or relative"
}
#
# outputs
#
output "file" {
  value = "${var.file}"
}

