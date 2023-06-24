locals {
	names = ["bucket1","bucket2","bucket3","bucket4"]
}

resource "null_resource" "names1" {
	for_each = toset(local.names)
	triggers = {
		name = each.value
	}
}

resource "null_resource" "names" {
	for_each = toset(local.names)
	triggers = {
		name = each.value
	}
}

output "list_out" {
	value = null_resource.names
	}