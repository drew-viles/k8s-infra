locals {
  ports = flatten([
    for subset_key, subset in var.subsets : [
      for ports_key, port in subset.ports : {
        name     = port.name
        port     = port.port
        protocol = port.protocol
        path     = port.path
      }
    ]
  ])
}
