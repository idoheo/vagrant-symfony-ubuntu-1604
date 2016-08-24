# -*- mode: ruby -*-
# vi: set ft=ruby :

vagrant_configuration = Hash.new

## Options that most likley do not need change
vagrant_configuration['image_name'] = 'ubuntu/xenial64'; # If your hadrware does not support 64 bit os virtualization, use "ubuntu/xenial32
vagrant_configuration['use_samba'] = true                # Use SAMBA for source folder on Windows host
vagrant_configuration['use_nfs'] = true                  # Use NFS for source folder on Unix host
vagrant_configuration['memory'] = 2048                   # RAM in MB
vagrant_configuration['cpus'] = 2                        # CPUs to use (CPU cores)
vagrant_configuration['post_startup_message'] = ""       # Custom post startup message

## Options that you will wanna change per box
vagrant_configuration['private_ip'] = '192.168.100.254'                                          # IP for virtual newtowk adapter
vagrant_configuration['hostname'] = vagrant_configuration['image_name'].gsub(/[^A-Za-z0-9]/,'-') # Hostname to setup for the virtual box

## Options that you should change if needed
vagrant_configuration['box_name'] = vagrant_configuration['hostname'].gsub(/[^A-Za-z0-9]/,'_') + ' ' + vagrant_configuration['private_ip'] # Box name for Virtualbox
vagrant_configuration['smb_host'] = vagrant_configuration['private_ip'][0, vagrant_configuration['private_ip'].rindex('.')] + '.1'         # Samba HOST ip (correct if needed)
vagrant_configuration['ansible_host_folder'] = './ansible';                                                                                # Path to ansible folder

module OS
	def OS.windows?
		(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
	end
	def OS.mac?
		(/darwin/ =~ RUBY_PLATFORM) != nil
	end
	def OS.unix?
		!OS.windows?
	end
	def OS.linux?
		OS.unix? and not OS.mac?
	end
end

Vagrant.configure("2") do |config|
	config.vm.box = vagrant_configuration['image_name']
	config.vm.box_check_update = true
	config.vm.box_version = '>=0'
	config.ssh.shell = "/bin/bash -l"
	config.vm.provider "virtualbox" do |v|
		v.memory = vagrant_configuration['memory']
		v.cpus = vagrant_configuration['cpus']
		v.linked_clone = !!(Vagrant::VERSION =~ /^1.8/)
		v.name = vagrant_configuration['box_name']
	end

	config.vm.hostname = vagrant_configuration['hostname']

	config.vm.network "private_network",
				ip: vagrant_configuration['private_ip'],
				auto_config: true

	config.vm.synced_folder ".",
					"/vagrant",
					disabled: true

	config.vm.synced_folder vagrant_configuration['ansible_host_folder'],
					"/ansible",
					disabled: false,
					create: false,
					mount_options: ["ro"]

	config.vm.synced_folder "./assets",
					"/project_assets",
					disabled: false,
					create: true,
					mount_options: ["rw"]

	if (OS.windows? && vagrant_configuration['use_samba'])

		config.vm.synced_folder "./source",
					"/opt/dev-project/source",
					disabled: false,
					create: true,
					mount_options: ["rw"],
					type: "smb",
					smb_host: vagrant_configuration['smb_host']

	elsif (OS.unix? && vagrant_configuration['use_nfs'])
		
		config.vm.synced_folder "./source",
					"/opt/dev-project/source",
					disabled: false,
					create: true,
					mount_options: ["rw"],
					type: "nfs"

	else
		
		config.vm.synced_folder "./source",
					"/opt/dev-project/source",
					disabled: false,
					create: true,
					mount_options: ["rw"]
		
	end

	config.vm.provision "shell-hostname",
				type: "shell",
				run: "always",
				inline: "TEMP_HOSTS=$(tempfile) && awk '!/# Ansible host/' /etc/hosts > $TEMP_HOSTS && echo \"127.0.0.1 $(hostname) # Ansible host\" >> $TEMP_HOSTS &&  sudo cp $TEMP_HOSTS /etc/hosts && rm $TEMP_HOSTS"

	config.vm.provision "shell-once",
				type: "shell",
				run: "once",
				inline: "/ansible/ansible.sh playbook-once"

	config.vm.provision "shell-always",
				type: "shell",
				run: "always",
				inline: "/ansible/ansible.sh playbook-always"

  config.vm.post_up_message = " - Vagrant development machine -

   - Virtualbox config -
      Machine name:       " + vagrant_configuration['box_name'] + "
      Box base:           " + config.vm.box + "
      Memory:             " + vagrant_configuration['memory'].to_s + " MB
      Cpu cores:          " + vagrant_configuration['cpus'].to_s + "

   - Network -
      IP:                 " + vagrant_configuration['private_ip'] + "
      Hostname:           " + vagrant_configuration['hostname'] + "

   - Source share type -
      Samba:              " + (OS.windows? && vagrant_configuration['use_samba'] ? "Yes" : "No") + "
      NFS:                " + (OS.unix? && vagrant_configuration['use_nfs'] ? "Yes" : "No") + "
      Virtual Box:        " + (( !(OS.windows? && vagrant_configuration['use_samba']) && !(OS.unix? && vagrant_configuration['use_nfs']) ) ? "Yes" : "No") + "

  " + vagrant_configuration['post_startup_message']

end
