VAGRANTFILE_API_VERSION = "2"

servers = { "ubuntu_x86" => { "box"            => "ubuntu_x86",
                              "ami"            => "ami-ad42009d",
                              "distribution"   => "ubuntu",
                              "package"        => "deb",
                              "username"       => "ubuntu",
                              "architecture"   => "amd64",
                            },
          }

# Here's a quick breakdown on what the single letter objects mean.
# b - box configuration
# c - imported configuration (value in hash above)
# s - server (key in hash above)
# v - vagrant

Vagrant.configure(VAGRANTFILE_API_VERSION) do |v|
  # For each configuration from the hash above:
  servers.each do |s, c|

    v.vm.define s do |b|

      b.vm.box = "dummy"
      b.ssh.private_key_path = ENV['KEYPAIR_PATH']
      b.ssh.username = c['username']

      b.vm.provider :aws do |aws|
        aws.access_key_id = ENV['AWS_ACCESS_KEY']
        aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
        aws.region = "us-west-2"
        aws.security_groups = "default"
        aws.keypair_name = ENV['KEYPAIR_NAME']
        aws.instance_type = "m3.large"
        aws.ami = c['ami']
      end

      b.vm.provision :shell, :inline => "echo \"export distribution=#{c['distribution']}\" >> /etc/profile.d/env_variables.sh"
      b.vm.provision :shell, :inline => "echo \"export package=#{c['package']}\" >> /etc/profile.d/env_variables.sh"
      b.vm.provision :shell, :inline => "echo \"export architecture=#{c['architecture']}\" >> /etc/profile.d/env_variables.sh"
      b.vm.provision :shell, :inline => "echo \"export pc_token=#{ENV['PACKAGECLOUD_TOKEN']}\" >> /etc/profile.d/env_variables.sh"
      b.vm.provision :shell, :inline => "echo \"export pc_username=#{ENV['PACKAGECLOUD_USERNAME']}\" >> /etc/profile.d/env_variables.sh"

      # Install necesary packages to compile Twemproxy and
      #  Build packages and push them to package cloud.
      b.vm.provision :shell, :path => "scripts/bootstrap.sh"

    end
  end
end
