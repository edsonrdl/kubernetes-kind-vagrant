Vagrant.configure("2") do |config|
  nodes = [
    { name: "kind-control-plane", memory: 4096, cpus: 2, ip: "192.168.56.10", ssh_port: 2222 },
    { name: "kind-worker1", memory: 3072, cpus: 2, ip: "192.168.56.11" },
    { name: "kind-worker2", memory: 3072, cpus: 2, ip: "192.168.56.12" }
  ]

  nodes.each do |node|
    config.vm.define node[:name] do |node_config|
      node_config.vm.box = "ubuntu/focal64"
      node_config.vm.hostname = node[:name]

      # Apenas o Control Plane tem SSH acessível pelo host
      if node[:name] == "kind-control-plane"
        node_config.vm.network "forwarded_port", guest: 22, host: node[:ssh_port]
      end

      # Rede privada para comunicação entre os nós
      node_config.vm.network "private_network", ip: node[:ip]

      # Configuração de hardware
      node_config.vm.provider "virtualbox" do |vb|
        vb.gui = true  # Mantém GUI ativada
        vb.name = node[:name]
        vb.memory = node[:memory]
        vb.cpus = node[:cpus]
      end

      # Provisionamento: Instalação de SSH e login automático
      node_config.vm.provision "shell", inline: <<-SHELL
        set -e

        # Configura auto-login para evitar travamento na tela inicial
        sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
        echo '[Service]
        ExecStart=
        ExecStart=-/sbin/agetty --autologin vagrant --noclear %I $TERM
        ' | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
        
        sudo systemctl daemon-reexec
        sudo systemctl restart getty@tty1

        # Atualiza pacotes e instala SSH
        sudo swapoff -a
        sudo sed -i '/ swap / s/^/#/' /etc/fstab
        sudo apt-get update && sudo apt-get upgrade -y
        sudo apt-get install -y openssh-server
        sudo systemctl enable ssh
        sudo systemctl start ssh

        # Permitir login por senha temporariamente
        echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
        echo "PermitRootLogin no" | sudo tee -a /etc/ssh/sshd_config
        echo "PubkeyAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
        sudo systemctl restart ssh
      SHELL
    end
  end
end
