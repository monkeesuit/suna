resource "google_compute_firewall" "rules" {
  for_each = { for r in var.rules : r.name => r }

  name      = "${each.value.name}-${var.environment}"
  network   = var.network
  direction = each.value.direction
  priority  = each.value.priority

  source_ranges      = each.value.direction == "INGRESS" ? each.value.ranges : null
  destination_ranges = each.value.direction == "EGRESS" ? each.value.ranges : null

  dynamic "allow" {
    for_each = each.value.action == "allow" ? [each.value] : []
    content {
      protocol = each.value.protocol
      ports    = each.value.ports
    }
  }

  dynamic "deny" {
    for_each = each.value.action == "deny" ? [each.value] : []
    content {
      protocol = each.value.protocol
      ports    = each.value.ports
    }
  }

  target_tags = each.value.target_tags != null ? each.value.target_tags : []
}
