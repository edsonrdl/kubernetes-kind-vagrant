Vagrant.configure("2") do |config|
  nodes = [
    { name: "kind-control-plane", memory: 4096, cpus: 2 },
    { name: "kind-worker1", memory: 3072, cpus: 2 },
    { name: "kind-worker2", memory: 3072, cpus: 2 }
  ]

  nodes.each do |node|
    config.vm.define node[:name] do |node_config|
      node_config.vm.box = "ubuntu/focal64"
      node_config.vm.hostname = node[:name]

      # Rede NAT para acesso à internet
      node_config.vm.network "forwarded_port", guest: 22, host: (2222 + nodes.index(node))

      # Rede Privada para comunicação entre os nós do cluster
      node_config.vm.network "private_network", type: "dhcp"

      # Configuração de hardware
      node_config.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.memory = node[:memory]
        vb.cpus = node[:cpus]
      end

      # Provisionamento
      node_config.vm.provision "shell", inline: <<-SHELL
        set -e
        sudo swapoff -a
        sudo sed -i '/ swap / s/^/#/' /etc/fstab
        sudo apt-get update && sudo apt-get upgrade -y
        sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

        # Instalando Docker
        curl -fsSL https://get.docker.com | sudo bash
        sudo usermod -aG docker vagrant
        newgrp docker

        # Instalando Kind e kubectl
        KIND_VERSION="v0.20.0"
        curl -Lo ./kind "https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-amd64"
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind

        KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/

        # Criando cluster Kind apenas no nó de controle
        if [[ "$(hostname)" == "kind-control-plane" ]]; then
          cat <<EOF > kind-config.yaml
          kind: Cluster
          apiVersion: kind.x-k8s.io/v1alpha4
          networking:
            disableDefaultCNI: true
          nodes:
            - role: control-plane
            - role: worker
            - role: worker
          EOF

          kind create cluster --config kind-config.yaml --name kind-prod

          mkdir -p /home/vagrant/.kube
          kind get kubeconfig --name kind-prod > /home/vagrant/.kube/config
          chown -R vagrant:vagrant /home/vagrant/.kube
        fi

        sudo apt-get autoremove -y
        sudo apt-get clean
      SHELL
    end
  end
end
