# to make sure the nodes are created in order, we
# have to force a --no-parallel execution.
ENV['VAGRANT_NO_PARALLEL'] = 'yes'
require 'ipaddr'

def get_or_generate_k3s_token
  # TODO generate an unique random an cache it.
  # generated with openssl rand -hex 32
  'vlpXN4EkW8RcC283cq1CzrfLcxv1UxP7eAE08iqfEINija7uCQtgf9LFzXtUThvV'
end

def generate_nodesInfos(first_ip_address, count, name_prefix)
  addr = IPAddr.new first_ip_address
  (1..count).map do |n|
    ip_address, addr = addr.to_s, addr.succ
    name = "#{name_prefix}#{n}"
    fqdn = "#{name}.example.test"
    [name, fqdn, ip_address, n]
  end
end

k3s_channel = 'stable'
k3s_version = 'v1.25.7+k3s1'
kube_vip_version = 'v0.5.11' # https://github.com/kube-vip/kube-vip/releases
helm_version = 'v3.11.2' # https://github.com/helm/helm/releases
helmfile_version = 'v0.144.0' # https://github.com/roboll/helmfile/releases
k8s_dashboard_version = 'v2.7.0' # https://github.com/kubernetes/dashboard/releases
# NB make sure you use a version compatible with k3s. # see https://github.com/etcd-io/etcd/releases
etcdctl_version = 'v3.5.7'
k9s_version = 'v0.27.3' # https://github.com/derailed/k9s/releases
 krew_version = 'v0.4.3' # see https://github.com/kubernetes-sigs/krew/releases
metallb_chart_version = '4.1.20' # see https://artifacthub.io/packages/helm/bitnami/metallb

# set the flannel backend. use one of:
# * host-gw:          non-secure network (needs ethernet (L2) connectivity between nodes).
# * vxlan:            non-secure network (needs UDP (L3) connectivity between nodes).
# * wireguard-native: secure network (needs UDP (L3) connectivity between nodes).
flannel_backend = 'host-gw'
#flannel_backend = 'vxlan'
#flannel_backend = 'wireguard-native'

server_fqdn           = 's.example.test'
server_vip            = '10.11.0.10'
lb_ip_range           = '10.11.0.50-10.11.0.250'
k3s_token     = get_or_generate_k3s_token
extra_hosts = """
#{server_vip} #{server_fqdn}
"""
Vagrant.configure(2) do |config|
  master_cluster_number  = 1
  agent_cluster_number   = 1
  first_server_node_ip  = '10.11.0.11'
  first_agent_node_ip   = '10.11.0.21'
  masterNodes  = generate_nodesInfos(first_server_node_ip, master_cluster_number, 's')
  agent_nodes   = generate_nodesInfos(first_agent_node_ip, master_cluster_number, 'a')

  config.vm.box = 'generic/debian11'
  masterNodes.each do |name, fqdn, ip_address, n|
    config.vm.define name do |config|
      config.vm.provider 'vmware_workstation' do |vb, config|
        # vb.nested = true
        vb.memory = 8*1024
        vb.linked_clone = true
        vb.cpus = 4
        # vb.cpu_mode = 'host-passthrough'
        vb.gui=false
      end

      config.vm.provider 'libvirt' do |lv, config|
        lv.cpus = 4
        lv.cpu_mode = 'host-passthrough'
        lv.memory = 8*1024
        # lv.nested = true
        lv.keymap = 'pt'
      end

      # config.vm.synced_folder '.', '/vagrant', type: 'nfs', nfs_version: '4.2', nfs_udp: false
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'shell', path: './provisions/provision-base.sh', args: [extra_hosts]
      config.vm.provision 'shell', path: './provisions/provision-wireguard.sh'
      config.vm.provision 'shell', path: './provisions/provision-etcdctl.sh', args: [etcdctl_version]
      # see https://get.k3s.io/
      # see https://github.com/k3s-io/k3s/releases
      config.vm.provision 'shell', path: './provisions/provision-k3s-server.sh', args: [
        n == 1 ? "cluster-init" : "cluster-join",
        k3s_channel,
        k3s_version,
        k3s_token,
        flannel_backend,
        ip_address,
        krew_version
      ]
      config.vm.provision 'shell', path: './provisions/provision-helm.sh', args: [helm_version] # NB this might not really be needed, as rancher has a HelmChart CRD.
      config.vm.provision 'shell', path: './provisions/provision-helmfile.sh', args: [helmfile_version]
      # config.vm.provision 'shell', path: './provisions/provision-k9s.sh', args: [k9s_version]
      if n == 1
        # config.vm.provision 'shell', path: './provisions/provision-kube-vip.sh', args: [kube_vip_version, server_vip]
        # config.vm.provision 'shell', path: './provisions/provision-metallb.sh', args: [metallb_chart_version, lb_ip_range]
        config.vm.provision 'shell', path: './provisions/provision-k8s-dashboard.sh', args: [k8s_dashboard_version]
      end
    end
  end

  agent_nodes.each do |name, fqdn, ip_address, n|
    config.vm.define name do |config|
      config.vm.provider 'libvirt' do |lv, config|
        lv.memory = 4*1024
      end

      config.vm.provider 'vmware_workstation' do |vb|
        vb.linked_clone = true
        vb.cpus = 2
        # vb.cpu_mode = 'host-passthrough'
        vb.gui=false
        vb.memory = 4*1024
      end

      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip_address, libvirt__forward_mode: 'none', libvirt__dhcp_enabled: false
      config.vm.provision 'shell', path: './provisions/provision-base.sh', args: [extra_hosts]
      config.vm.provision 'shell', path: './provisions/provision-wireguard.sh'
      config.vm.provision 'shell', path: './provisions/provision-k3s-agent.sh', args: [
        "cluster-join",
        k3s_channel,
        k3s_version,
        k3s_token,
        ip_address
      ]
      # config.vm.provision 'shell', path: './provisions/provision-appEnv.sh'
    end
  end

  # config.trigger.before :up do |trigger|
  #   trigger.only_on = 's1'
  #   trigger.run = {
  #     inline: '''bash -euc \'
  #     mkdir -p tmp
  #     artifacts=(
  #       ../gitlab-vagrant/tmp/gitlab.example.com-crt.pem
  #       ../gitlab-vagrant/tmp/gitlab.example.com-crt.der
  #       ../gitlab-vagrant/tmp/gitlab-runners-registration-token.txt
  #     )
  #     for artifact in "${artifacts[@]}"; do
  #       if [ -f $artifact ]; then
  #         cp $artifact tmp
  #       fi
  #     done
  #     \'
  #     '''
  #   }
  # end
end
