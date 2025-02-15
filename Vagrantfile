Vagrant.configure("2") do |config|
  nodes = [
    { name: "kind-control-plane", memory: 4096, cpus: 2, ip: "192.168.56.10", ssh_port: 2222 },
    { name: "kind-worker1", memory: 3072, cpus: 2, ip: "192.168.56.11", ssh_port: 2223 },
    { name: "kind-worker2", memory: 3072, cpus: 2, ip: "192.168.56.12", ssh_port: 2224 }
  ]

  nodes.each do |node|
    config.vm.define node[:name] do |node_config|
      node_config.vm.box = "ubuntu/focal64"
      node_config.vm.hostname = node[:name]

      # Rede NAT para acesso à internet
      node_config.vm.network "forwarded_port", guest: 22, host: node[:ssh_port]

      # Rede Privada para comunicação entre os nós do cluster
      node_config.vm.network "private_network", ip: node[:ip]

      # Configuração de hardware
      node_config.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.memory = node[:memory]
        vb.cpus = node[:cpus]
      end

      # Provisionamento: Apenas atualizações básicas (sem Docker/Kind)
      node_config.vm.provision "shell", inline: <<-SHELL
        set -e
        sudo swapoff -a
        sudo sed -i '/ swap / s/^/#/' /etc/fstab
        sudo apt-get update && sudo apt-get upgrade -y
      SHELL
    end
  end
end
