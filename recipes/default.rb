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
  mode 00755
  recursive true
end

git "#{node['devstack']['localrc']['dest']}/devstack" do
  repository node['devstack']['repository']
  reference node['devstack']['reference']
end

template "localrc" do
  path "#{node['devstack']['localrc']['dest']}/devstack/localrc"
  mode 00644
end

directory "/root/.pip" do
  owner "root"
  group "root"
  mode 00644
  recursive true
end

template "pip.conf" do
  path "/root/.pip/pip.conf"
  mode 00644
end

stack_user = node['devstack']['localrc']['stack_user'] || 'stack'

execute "bash #{node['devstack']['localrc']['dest']}/devstack/tools/create-stack-user.sh" do
  not_if "id #{stack_user}"
end

execute "unstack.sh" do
  user stack_user
  command "./unstack.sh"
  environment( 
    'HOME' => node['devstack']['localrc']['dest']
  )
  cwd "#{node['devstack']['localrc']['dest']}/devstack"
  only_if { node['devstack']['unstack'] }
end

execute "stack.sh" do
  user stack_user
  command "./stack.sh"
  environment( 
    'HOME' => node['devstack']['localrc']['dest']
  )
  cwd "#{node['devstack']['localrc']['dest']}/devstack"
  only_if { node['devstack']['unstack'] or not ::File.exists? "#{node['devstack']['localrc']['dest']}/devstack/stack-screenrc" }
end
