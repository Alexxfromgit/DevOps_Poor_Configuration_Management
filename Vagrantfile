Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 512
    vb.cpus = 1
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git
  SHELL

  config.vm.provision "file", source: "ntp_deploy.sh", destination: "/root/task4_2/ntp_deploy.sh"
  config.vm.provision "file", source: "ntp_verify.sh", destination: "/root/task4_2/ntp_verify.sh"

  config.vm.provision "shell", inline: <<-SHELL
    chmod +x /root/task4_2/ntp_deploy.sh /root/task4_2/ntp_verify.sh
  SHELL
end
