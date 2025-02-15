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

      # Apenas o Control Plane tem SSH público
      if node[:name] == "kind-control-plane"
        node_config.vm.network "forwarded_port", guest: 22, host: node[:ssh_port]
      end

      # Rede privada para comunicação entre os nós
      node_config.vm.network "private_network", ip: node[:ip]

      # Configuração de hardware
      node_config.vm.provider "virtualbox" do |vb|
        vb.gui = true  # Abre a interface gráfica automaticamente
        vb.name = node[:name]
        vb.memory = node[:memory]
        vb.cpus = node[:cpus]
      end

      # Provisionamento: Configuração de login automático e SSH
      node_config.vm.provision "shell", inline: <<-SHELL
        set -e

        # Desativa a tela de login exigida no VirtualBox
        sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
        echo '[Service]
        ExecStart=
        ExecStart=-/sbin/agetty --autologin vagrant --noclear %I $TERM
        ' | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf

        # Reinicia para aplicar a configuração
        sudo systemctl daemon-reexec
        sudo systemctl restart getty@tty1

        # Atualiza pacotes e instala SSH
        sudo swapoff -a
        sudo sed -i '/ swap / s/^/#/' /etc/fstab
        sudo apt-get update && sudo apt-get upgrade -y
        sudo apt-get install -y openssh-server
        sudo systemctl enable ssh
        sudo systemctl start ssh
      SHELL
    end
  end
end
