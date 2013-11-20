default['devstack']['host-ip'] = node[:ipaddress]
default['devstack']['database-password'] = "ostackdemo"
default['devstack']['rabbit-password'] = "ostackdemo"
default['devstack']['service-token'] = "token"
default['devstack']['service-password'] = "ostackdemo"
default['devstack']['admin-password'] = "ostackdemo"
default['devstack']['dest'] = "/opt/stack"

default['devstack']['repository'] = 'https://github.com/openstack-dev/devstack.git'
default['devstack']['reference'] = 'master'
default['devstack']['unstack'] = false

# Django...
default['devstack']['pip-timeout'] = "1000"
