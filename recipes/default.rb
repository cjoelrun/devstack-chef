#
# Cookbook Name:: devstack
# Recipe:: default
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'apt'
include_recipe 'git'

directory "#{node['devstack']['localrc']['dest']}" do
  owner "root"
  group "root"
  mode 00755
  action :create
  recursive true
end

git "#{node['devstack']['localrc']['dest']}/devstack" do
  repository "https://github.com/openstack-dev/devstack.git"
  reference "master"
end

template "localrc" do
   path "#{node['devstack']['localrc']['dest']}/devstack/localrc"
   owner "root"
   group "root"
   mode 00644
end

directory "/root/.pip" do
  owner "root"
  group "root"
  mode 00644
  action :create
  recursive true
end

template "pip.conf" do
   path "/root/.pip/pip.conf"
   owner "root"
   group "root"
   mode 00644
end

stack_user = node['devstack']['localrc']['stack_user'] || 'stack'

execute "#{node['devstack']['localrc']['dest']}/devstack/tools/create-stack-user.sh" do
  not_if "id #{stack_user}"
end

execute "stack.sh" do
  command "sudo -u #{stack_user} ./stack.sh"
  cwd "#{node['devstack']['localrc']['dest']}/devstack"
  not_if { ::File.exists? "#{node['devstack']['localrc']['dest']}/devstack/stack-screenrc" }
end
