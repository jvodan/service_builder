class BlueprintReader
  require_relative 'scripts'
  require_relative 'service_user'
  require_relative 'unrelated_keys'
  require_relative 'file_permissions'
  require_relative 'installed_packages'
  require_relative 'system_packages'
  require_relative 'sudoers'
  require_relative 'use'
  def base(details)
    @user = ServiceUser.new(details)
    @from_image = details[:parent_image]
    #care about User[Run as User ID Primary group create user]
  end

  def disposition(details)
    #care about Start syslog Consumerless No CA map Kerberos support
    uses_syslog(details[:start_syslog])
    uses_kerberos(details[:kerberos_support])
    @no_ca = details[:no_ca_map]
  end

  def scripts(details)
    details.keys.each do |k|
      self.send("#{k}_script", details[k])
    end
  end

  def system_packages(details)
    @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
    details.each do |p|
      @system_packages_line += " #{versioned_package(p)}"
    end

    def consumer_scripts(details)
      details.each_pair do |k,v|
        write_script("service/#{k}.sh", v)
      end
    end

    def scripts(details)
      details.keys.each do |k|
        self.send("#{k}_script", details[k])
      end
    end

    def actionators(details)
      details.each do |a|
        save_actionator(a)
      end
    end

    def configurators(details)
      details.each do |a|
        save_configurator(a)
      end
    end

    def log_directories(details)
      details.each do |l|
        @log_dir_line += "&&\\n" unless @log_dir_line.nil?
        add_to(@log_dir_line, "mkdir #{l} && chown #{@cont_user} #{l}")
      end
    end

    def file_permissions(details)
      details.each do |f|
        add_file_perm(f)
      end
    end

    def external_repositories(details)
      details.each do |r|
        @repos_line += "&&\\\n" unless @repos_line.nil?
        add_to(@repos_line, "wget -qO - #{r[:key]} | apt-key add - &&\\\n") unless r[:key].nil?
        add_to(@repos_line, "add-apt-repository  -y #{r[:source]}")
      end
    end

    def included_files(details)
      details.each do |d|
        add_to(@included_adds, "{ADD #{d[:source]} #{d[:destination]}\n")
        d[:path] = d[:destination]
        @included_adds_line += " &&\\\n" unless @included_adds_line.nil?
        add_to(@included_adds_line, add_file_perm(d))
        #         "template": true
      end
    end

    def installed_packages(details)
      details.each do |d|
        @install_packages_line += "&&\\\n" unless @install_packages_line.nil?
        add_to(@install_packages_line, %Q(
            #{download_package(d)} &&\
            #{extract_package(d)}
            #{install_package(d)}
            ))
      end
    end

    def soft_links(details)
      details.each do |l|
        @soft_links_line += "&&\\n" unless @log_dir_line.nil?
        add_to(@soft_links_line, "ln -s #{l[:source]} #{l[:target]}")
        @soft_links_line += "&& chown #{@cont_user} #{l[:owner]}" unless l[:owner].nil?
      end
    end

    def environment_variables(details)
      #not quite teh same with services less options
      details.each do |d|
        if d[:build_time_only] == true
          build_env.push(d) unless d[:value].nil?
        else
          add_to(@env_line, "ENV #{d[:name]} #{d[:value]}\n") unless d[:value].nil?
        end
      end
    end

    def replacement_strings(details)
      details.each do |s|
        @sed_line +="&& \\\n" unless @sed_line.nil?
        add_to(@sed_line, " cat #{s[:source_file]} | sed \"#{string}\" >/tmp/.sed && mv /tmp/.sed #{s[:destination_file]}")
      end
    end

    def required_modules(details)
      details.each do |m|
        add_system_package_line(m[:os_package]) unless m[:os_package].nil?
        add_to(@modules_line, self.send("install_#{m[:type]}_module", m))
      end
    end
  end

end