# devstack Cookbook
  
  Cookbook to install devstack
  
## Requirements
   
###   Cookbooks
    - git
      
### Operating Systems
    - centos
    - ubuntu
      
### Attributes
   
   devstack::default
   
   
   | Key                                 | Type    | Description                                | Default         |
   |-------------------------------------+---------+--------------------------------------------+-----------------|
   | ~['devstack']['host-ip']~           | String  | The host/ip to bind the stack to           | ~198.101.10.10~ |
   | ~['devstack']['database-password']~ | String  | The password for the DevStack database     | ~ostackdemo~    |
   | ~['devstack']['rabbit-password']~   | String  | The password for tde rabbit service        | ~ostackdemo~    |
   | ~['devstack']['service-token']~     | String  | The token for the DevStack service user    | ~token~         |
   | ~['devstack']['service-password']~  | String  | The password for the DevStack service user | ~ostackdemo~    |
   | ~['devstack']['admin-password']~    | String  | The password for the DevStack admin user   | ~ostackdemo~    |
   | ~['devstack']['dest']~              | String  | The directory to install DevStack          | ~/opt/stack~    |
   | ~['devstack']['pip-timeout']~       | Integer | The default time out for pip               | ~1000~          |
   
   The ~['devstack']['localrc']~ attribute space allows for overriding anything that ends up in ~localrc~.
   For an example, see the included ~Vagrantfile~.

   
# Devstack usage

## Chef

- `run_list: recipe[devstack]`

## command-line interaction

First things first:

- Become the `stack` user: `sudo -u stack -i`.
- If you intend to use the CLI on the VM:


### See what's going on

- Rejoin running screen session: `screen -x stack` or`/opt/stack/devstack/rejoin-stack.sh`.
  If this fails, run `sudo chown stack:stack $(readlink /proc/self/fd/0)`
- Devstacks Screen setup (specified in `/opt/stack/devstack/stack-screenrc`) starts each enabled service in its own tab, with an additional shell tab (0).
  It does not make use of any process supervision or even init scripts beyond that.
  To restart a service, interrupt it (`Ctrl+C`) and use the tab's Bash history to restart it.

### Interact with OpenStack via CLI

- Source the credentials, `. openrc USER TENAND PASSWORD`, so:
  - `. /opt/stack/devstack/openrc admin admin password` for admin credentials
  - `. /opt/stack/devstack/openrc` for default credentials, demo/demo/password

### Starting over more quickly

As `stack` user:

- `./unstack.sh`
- optionally change `RECLONE` to `False` in `/opt/stack/devstack/localrc`
- `./stack.sh`

If you are trying to work out purely devstack-related issues, it's easiest with having only a minimal number of services enabled, such as `postgresql` and `key` (Keystone).

### GNU Screen 101

In what follows, `^a` means `Ctrl+a`.
In general, where something like `^a n` is mentioned, `^a ^n` works, too, and is quicker to type.

- detach: `^a d`
- quit: `^a :quit`
- next tab: `^a n`
- previous tab: `^a p`
- list of tabs: `^a "`
- go to tab 3: `^a 3`
- scroll mode: `^a [` (exit with `q`)

## Interact via Horizon

- Access `http://$MYIP/` and login using the credentials (admin/password, demo/password).

## Connect to a VM without proper networking

First ensure that your securty groups allow whatever is needed (Ping, SSH).
Then proceed using the command line (as `root`):

```console
root@devstack:/opt/stack/devstack# ip a | grep "inet "
    inet 127.0.0.1/8 scope host lo
    inet 1X.X8.67.84/21 brd 1X.X8.71.255 scope global eth0
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
root@devstack:/opt/stack/devstack# . openrc demo demo password
root@devstack:/opt/stack/devstack# nova list
+--------------------------------------+-------+--------+------------+-------------+--------------------------------+
| ID                                   | Name  | Status | Task State | Power State | Networks                       |
+--------------------------------------+-------+--------+------------+-------------+--------------------------------+
| 2b2510ad-7540-4050-930f-39b6324518a0 | asdfg | ACTIVE | None       | Running     | private=10.0.0.3, 172.24.4.227 |
+--------------------------------------+-------+--------+------------+-------------+--------------------------------+
root@devstack:/opt/stack/devstack# nova show asdfg
+--------------------------------------+----------------------------------------------------------+
| Property                             | Value                                                    |
+--------------------------------------+----------------------------------------------------------+
| OS-DCF:diskConfig                    | MANUAL                                                   |
| OS-EXT-AZ:availability_zone          | nova                                                     |
| OS-EXT-STS:power_state               | 1                                                        |
| OS-EXT-STS:task_state                | None                                                     |
| OS-EXT-STS:vm_state                  | active                                                   |
| OS-SRV-USG:launched_at               | 2013-11-13T15:23:40.073143                               |
| OS-SRV-USG:terminated_at             | None                                                     |
| accessIPv4                           |                                                          |
| accessIPv6                           |                                                          |
| config_drive                         |                                                          |
| created                              | 2013-11-13T15:23:18Z                                     |
| flavor                               | m1.small (2)                                             |
| hostId                               | a7189550aaf6259d040aa5009aee3fb99cad6ecb6cf2225c9adf31fa |
| id                                   | 2b2510ad-7540-4050-930f-39b6324518a0                     |
| image                                | ubuntu-1304 (d56319cf-d839-4197-a5d2-beb1aff60fae)       |
| key_name                             | None                                                     |
| metadata                             | {}                                                       |
| name                                 | asdfg                                                    |
| os-extended-volumes:volumes_attached | []                                                       |
| private network                      | 10.0.0.3, 172.24.4.227                                   |
| progress                             | 0                                                        |
| security_groups                      | [{u'name': u'default'}]                                  |
| status                               | ACTIVE                                                   |
| tenant_id                            | 5e5875a5cf4d4452914ddd8eca8e52a5                         |
| updated                              | 2013-11-13T15:23:40Z                                     |
| user_id                              | 2bf259812ce9448a98f17b95ddd87453                         |
+--------------------------------------+----------------------------------------------------------+
```

Figure out the UUID of the private network's subnet, to find its network namespace:

```console
root@devstack:/opt/stack/devstack# neutron net-show private
+-----------------+--------------------------------------+
| Field           | Value                                |
+-----------------+--------------------------------------+
| admin_state_up  | True                                 |
| id              | c00e5359-750e-4535-bbfe-e735be308fdc |
| name            | private                              |
| router:external | False                                |
| shared          | False                                |
| status          | ACTIVE                               |
| subnets         | cb8b74b7-068e-4bef-a19f-0652bb688939 | # <<<<<
| tenant_id       | 5e5875a5cf4d4452914ddd8eca8e52a5     |
+-----------------+--------------------------------------+
root@devstack:/opt/stack/devstack# ip netns
qrouter-90efff20-03e5-47bf-ad38-c9272b15943a
qdhcp-c00e5359-750e-4535-bbfe-e735be308fdc                 # <<<<<
root@devstack:/opt/stack/devstack# ip netns exec qdhcp-c00e5359-750e-4535-bbfe-e735be308fdc ping -c 1 10.0.0.2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_req=1 ttl=64 time=0.106 ms

--- 10.0.0.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.106/0.106/0.106/0.000 ms

Floating IPs can be tested by using the namespace of the `public` network (which actually is the floating IP pool):

```console
root@devstack:/opt/stack/devstack# neutron net-show public
+-----------------+--------------------------------------+
| Field           | Value                                |
+-----------------+--------------------------------------+
| admin_state_up  | True                                 |
| id              | 222ec706-9c0d-4ec0-a12c-e68240375cf3 | # <<<<<
| name            | public                               |
| router:external | True                                 |
| shared          | False                                |
| status          | ACTIVE                               |
| subnets         | 5de13e0e-6001-41f3-ad7a-a1a3f346f8da |
| tenant_id       | c055d6f814ed4295bccae855962cca20     |
+-----------------+--------------------------------------+
root@devstack:/opt/stack/devstack# neutron router-list
+--------------------------------------+---------+-----------------------------------------------------------------------------+
| id                                   | name    | external_gateway_info                                                       |
+--------------------------------------+---------+-----------------------------------------------------------------------------+
| 90efff20-03e5-47bf-ad38-c9272b15943a | router1 | {"network_id": "222ec706-9c0d-4ec0-a12c-e68240375cf3", "enable_snat": true} |
+--------------------------------------+---------+-----------------------------------------------------------------------------+
root@devstack:/opt/stack/devstack# ip netns
qrouter-90efff20-03e5-47bf-ad38-c9272b15943a               # <<<<<
qdhcp-c00e5359-750e-4535-bbfe-e735be308fdc
root@devstack:/opt/stack/devstack# ip netns exec qrouter-90efff20-03e5-47bf-ad38-c9272b15943a ssh ubuntu@172.24.4.227
The authenticity of host '172.24.4.227 (172.24.4.227)' can't be established.
ECDSA key fingerprint is f8:8a:ed:f6:bc:12:4f:6f:a8:49:06:19:83:0e:d7:cb.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '172.24.4.227' (ECDSA) to the list of known hosts.
Permission denied (publickey).
```

## Setting up proper host-only networking

Looking at the following picture depicting the Linux bridge network setup in an OpenStack network node:

![Network node schematics](http://docs.openstack.org/network-admin/admin/content/figures/2/figures/under-the-hood-scenario-1-linuxbridge-network.png)

In the one-node Devstack deployment, we have all the non-red components (veth pairs and Linux bridges).
By adding the IP address of the public network's router (by default the floating IP range is 172.24.4.224/28) to the bridge that is supposed to be linked with the public network (upper right corner), we get a host-only connection:

```console
root@devstack:~# neutron net-list
+--------------------------------------+---------+--------------------------------------------------+
| id                                   | name    | subnets                                          |
+--------------------------------------+---------+--------------------------------------------------+
| 3cf1ce39-df34-40d1-b91f-24e3f606c748 | public  | 8e8cf5b6-9500-47ab-abc0-25301bbeba8d             | # <<<<<
| 912c4d05-783b-4b4a-8881-bea40dfc08b7 | private | c573b0b9-e09b-4453-af93-a2438785aee2 10.0.0.0/24 |
+--------------------------------------+---------+--------------------------------------------------+
root@devstack:~# brctl show
bridge name bridge id   STP enabled interfaces
brq3cf1ce39-df    8000.3a0c3bcfaf52 no    tap78fd7c80-65                                              # <<<<<
brq912c4d05-78    8000.0ef36043ca65 no    tap9268ccea-e9
              tapb068971a-76
              tapd213bec4-f5
              tapd8a487b3-8c
virbr0    8000.000000000000 yes
root@devstack:~# ip netns
qrouter-9ed3cae0-d09e-4078-8c2a-3f04a5f6b780
qdhcp-912c4d05-783b-4b4a-8881-bea40dfc08b7

# or short

root@devstack:~#  BRIDGE=$(brctl show | grep `neutron net-list --quote none -f csv -c id -- --router:external=True | tail -n1 | awk '{split($0,a,"-") ; print a[1]}'` | awk '{split($0,a," ") ; print a[1]}')
root@devstack:~# echo $BRIDGE
brq97103221-cd

root@devstack:~# ip netns exec qrouter-9ed3cae0-d09e-4078-8c2a-3f04a5f6b780 ip r
default via 172.24.4.225 dev qg-78fd7c80-65
root@devstack:~# ip a add 172.24.4.225/28 dev brq3cf1ce39-df
root@devstack:~# ssh cirros@172.24.4.227
cirros@172.24.4.227's password:   # 'cubswin:)'
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether fa:16:3e:65:3a:ce brd ff:ff:ff:ff:ff:ff
    inet 10.0.0.3/24 brd 10.0.0.255 scope global eth0
    inet6 fe80::f816:3eff:fe65:3ace/64 scope link
       valid_lft forever preferred_lft forever
$ uname -a
Linux cirros 3.2.0-37-virtual #58-Ubuntu SMP Thu Jan 24 15:48:03 UTC 2013 x86_64 GNU/Linux
$ ip r
default via 10.0.0.1 dev eth0
10.0.0.0/24 dev eth0  src 10.0.0.3
$ ping -c1 1X.X8.71.100                              # <<< can ping the host
PING 1X.X8.71.100 (1X.X8.71.100): 56 data bytes
64 bytes from 1X.X8.71.100: seq=0 ttl=63 time=5.385 ms

--- 1X.X8.71.100 ping statistics ---
1 packets transmitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 5.385/5.385/5.385 ms
```

## Contributing
   
   1. Fork the repository on Github
   2. Create a named feature branch (like `add_component_x`)
   3. Write your change
   4. Write tests for your change (if applicable)
   5. Run the tests, ensuring they all pass
   6. Submit a Pull Request using Github
      
## License and Authors
   
   - Author:: Cameron Lopez (cameronjlopez@gmail.com)
   - Author:: Stephan Renatus (s.renatus@cloudbau.de)
   - Author:: Edmund Haselwanter (e.haselwanter@cloudbau.de)
