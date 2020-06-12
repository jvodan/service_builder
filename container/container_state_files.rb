class ContainerStateFiles
  require_relative '../config/system_config'
  class << self # container store directories & files
    def secrets_dir(ca)
      "/var/lib/engines/secrets/#{container_ns(ca)}"
    end

    def kerberos_dir(ca)
      "/var/lib/engines/services/auth/etc/krb5kdc/#{container_ns(ca)}"
    end

    def key_dir(ca)
      "#{SystemConfig.SSHStore}/#{container_ns(ca)}"
    end

    def container_log_dir(ca)
      "#{SystemConfig.SystemLogRoot}/#{container_ns(ca)}"
    end

    def container_ssh_keydir(ca)
      "#{SystemConfig.SSHStore}/#{container_ns(ca)}"
    end

    def container_service_dir(sn)
      "#{SystemConfig.RunDir}/services/#{sn}"
    end

    def container_disabled_service_dir(sn)
      "#{SystemConfig.RunDir}/services-disabled/#{sn}"
    end

    def container_state_dir(ca)
      "#{SystemConfig.RunDir}/#{container_ns(ca)}"
    end

    def container_rflag_dir(ca)
      "#{container_state_dir(ca)}/run/flags"
    end

    def container_flag_dir(ca)
      "#{container_state_dir(ca)}/run/flags/"
    end

    def container_ns(ca)
      "#{ca[:c_type]}s/#{ca[:c_name]}"
    end

    def create_container_dirs(ca)
      state_dir = container_state_dir(ca)
      unless File.directory?(state_dir)
        Dir.mkdir(state_dir)
        Dir.mkdir("#{state_dir}/run") unless Dir.exist?("#{state_dir}/run")
        Dir.mkdir("#{state_dir}/run/flags") unless Dir.exist?("#{state_dir}/run/flags")
        FileUtils.chown_R(nil, 'containers', "#{state_dir}/run")
        FileUtils.chmod_R('u+r', "#{state_dir}run")
        FileUtils.chmod_R('g+w', "#{state_dir}/run")
      end
      log_dir = container_log_dir(ca)
      Dir.mkdir(log_dir) unless File.directory?(log_dir)
      unless ca[:c_type] == 'engine'
        Dir.mkdir("#{state_dir}/configurations/") unless File.directory?("#{state_dir}/configurations")
        Dir.mkdir("#{state_dir}/configurations/default") unless File.directory?("#{state_dir}/configurations/default")
      end
      key_dir =  key_dir(ca)
      unless Dir.exist?(key_dir)
        Dir.mkdir(key_dir)  unless File.directory?(key_dir)
        FileUtils.chown(nil, 'containers',key_dir)
        FileUtils.chmod('g+w', key_dir)
      end
      true
    end

    def init_engine_dirs(en)
      ca = {c_type: 'app', c_name: en}
      FileUtils.mkdir_p("#{container_state_dir(ca)}/run") unless Dir.exist?("#{container_state_dir(ca)}/run")
      FileUtils.mkdir_p("#{container_state_dir(ca)}/run") unless Dir.exist?("#{container_state_dir(ca)}/run")
      FileUtils.mkdir_p(container_log_dir(ca)) unless Dir.exist?(container_log_dir(ca))
      FileUtils.mkdir_p(container_ssh_keydir(ca)) unless Dir.exist?(container_ssh_keydir(ca))
    end

    def load_pubkey(ca, cmd)
      kfn = "#{container_ssh_keydir(ca)}/#{cmd}_rsa.pub"
      if File.exists?(kfn)
        k = File.read(kfn)
        k.split(' ')[1]
      else
        ''
      end
    end

  end
end
