variable "network_interface_id" {}
variable "nat_ip_destination" {}
variable "private_route_table_ids" {}
resource "aws_route" "this" {
    count                  = length(var.private_route_table_ids)
    route_table_id         = var.private_route_table_ids[count.index]
    destination_cidr_block = var.nat_ip_destination
    network_interface_id   = var.network_interface_id

  lifecycle {
    create_before_destroy = false
  }
}