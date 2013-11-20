Vagrant.require_plugin "vagrant-berkshelf"
Vagrant.require_plugin "vagrant-cachier"
Vagrant.require_plugin "vagrant-omnibus"

Vagrant.configure("2") do |config|
  # Berkshelf plugin configuration
  config.berkshelf.enabled = true

  # Cachier plugin configuration
  config.cache.auto_detect = true

  # Omnibus plugin configuration
  config.omnibus.chef_version = :latest

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cpus", 1]
    vb.customize ["modifyvm", :id, "--memory", 2048]
    vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
  end

  config.vm.define :devstack do |conf|
    conf.vm.hostname = "devstack"
    conf.vm.box = "opscode-ubuntu-12.04"
    conf.vm.box_url = "https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box"
    # eth1, this will be the endpoint
    conf.vm.network "private_network", ip: "192.168.101.101"
    # eth2, this will be the OpenStack "public" network, use DevStack default
    config.vm.network "private_network", ip: "172.24.4.225", :netmask => "255.255.255.224", :auto_config => false
    conf.vm.provision :chef_solo do |chef|
      chef.run_list = 'devstack'
      chef.json = {
        devstack: {
          # ovs is broken in icehouse/master, so use stable havana
          reference: 'stable/havana',
          localrc: {
            host_ip:               '192.168.101.101',
            stack_user:            'stack',
            logfile:               '/opt/stack/logs/stack.sh.log',
            admin_password:        'password',
            database_password:     'password',
            rabbit_password:       'password',
            service_token:         'password',
            service_password:      'password',
            dest:                  '/opt/stack',
            keystone_token_format: 'PKI',
            swift_replicas:        1,
            swift_hash:            '011688b44136573e209e',
            verbose:               true,
            log_color:             true,
            screen_logdir:         '/opt/stack/logs',
            # if we want sec groups in havana with OVS we need ovs and bridges
            libvirt_vif_driver:    'nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver',
            enabled_services:  [
              'rabbit', # 'zeromq', 'qpid'
              'mysql',
              'key',               # Keystone
              'horizon',           # Horizon
              'n-api',             # Nova
              'n-crt',
              'n-obj', # AWS compat
              'n-cpu',
              'n-cond',
              'n-sch',
              'g-api',             # Glance
              'g-reg',
              # 's-proxy',         # Swift
              # 's-obj',
              # 's-container',
              # 's-account',
              'q-svc',             # Neutron
              'q-agt',
              'q-dhcp',
              'q-l3',
              'q-meta',
              'neutron',
              'q-lbaas',           # Neutron extensions
              'q-fwaas',
              # 'q-vpn',           # this effectively disables q-l3
              # 'heat',              # Heat
              # 'h-api',
              # 'h-api-cfn',
              # 'h-api-cw',
              # 'h-eng',
              # 'ceilometer-acompute',
              # 'ceilometer-acentral',
              # 'ceilometer-collector',
              # 'ceilometer-api',
              # 'ceilometer-alarm-notify',
              # 'ceilometer-alarm-eval',
              'cinder',            # Cinder
              'c-api',
              'c-vol',
              'c-sch'
              ],
            # How to override the repo/branch                
            # horizon_repo:          'https://github.com/openstack/horizon',
            # horizon_branch:        'master',
            q_plugin:              'ml2',
            q_agent:               'openvswitch',
            # enable_tenant_tunnels: true,
            apache_enabled_services: 'keystone',
            # add the google dns as a sane default
            q_dhcp_extra_default_opts: 'dnsmasq_dns_server=8.8.8.8'
          }
        }
      }
    end
    #config.vm.provision :shell, :inline => "cd devstack; sudo -u vagrant env HOME=/home/vagrant ./stack.sh"
    #config.vm.provision :shell, :inline => "ovs-vsctl add-port br-ex eth2"

    ## do this for enabling internet to the public openstack network
    #config.vm.provision :shell, :inline => "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE"

  end

end

