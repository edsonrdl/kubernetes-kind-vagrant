Vagrant.configure("2") do |config|
  nodes = [
    { name: "kind-control-plane", memory: 4096, cpus: 2, ip: "10.0.0.10", ssh_port: 2222 },
    { name: "kind-worker1", memory: 3072, cpus: 2, ip: "10.0.0.11" },
    { name: "kind-worker2", memory: 3072, cpus: 2, ip: "10.0.0.12" }
  ]

  nodes.each do |node|
    config.vm.define node[:name] do |node_config|
      node_config.vm.box = "ubuntu/focal64"
      node_config.vm.hostname = node[:name]

      # Apenas o Control Plane tem acesso SSH público
      if node[:name] == "kind-control-plane"
        node_config.vm.network "forwarded_port", guest: 22, host: node[:ssh_port]
      end

      # Rede privada entre os nós
      node_config.vm.network "private_network", ip: node[:ip]

      # Abre automaticamente a interface gráfica
      node_config.vm.provider "virtualbox" do |vb|
        vb.gui = true  
        vb.name = node[:name]
        vb.memory = node[:memory]
        vb.cpus = node[:cpus]
      end

      # Configuração de auto-login para evitar bloqueios na tela de login
      node_config.vm.provision "shell", inline: <<-SHELL
        set -e

        # Configura auto-login do usuário vagrant
        sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
        echo '[Service]
        ExecStart=
        ExecStart=-/sbin/agetty --noclear --autologin vagrant --keep-baud tty1 115200,38400,9600 $TERM
        Restart=always
        ' | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf

        sudo systemctl daemon-reexec
        sudo systemctl restart getty@tty1

        # Instalação do SSH e configuração segura (somente autenticação por chave)
        sudo apt-get update
        sudo apt-get install -y openssh-server
        sudo systemctl enable ssh
        sudo systemctl start ssh

        # Configuração do SSH: Apenas chave SSH, sem login por senha
        sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
        sudo sed -i 's/^#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config

        # Reinicia o SSH para aplicar as configurações
        sudo systemctl restart ssh
      SHELL
    end
  end
end
