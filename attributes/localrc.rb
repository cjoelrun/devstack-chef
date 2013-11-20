default['devstack']['localrc'] = {
  host_ip:               node['devstack']['host-ip'],
  admin_password:        node['devstack']['admin-password'],
  database_password:     node['devstack']['database-password'],
  rabbit_password:       node['devstack']['rabbit-password'],
  service_token:         node['devstack']['service-token'],
  service_password:      node['devstack']['service-password'],
  dest:                  node['devstack']['dest']
}
