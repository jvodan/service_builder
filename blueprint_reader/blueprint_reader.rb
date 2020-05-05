class BlueprintReader
  require 'yajl'
  require 'git'
  require_relative 'scripts'
  require_relative 'service_user'
  require_relative 'unrelated_keys'

  attr_reader   :included_adds,
  :build_name,
  :user,
  :uses_syslog,
  :no_ca,
  :kerberos_support,
  :system_packages_line,
  :file_permissions_line,
  :from_image,
  :log_dir_line,
  :soft_links_line,
  :modules_line,
  :sed_line,
  :included_adds_line,
  :repos_line,
  :sudoers_add,
  :sudoers_line,
  :install_packages_line

  def sudoers
    @sudoers ||= []
  end

  def process_sudoers
    unless sudoers.length == 0
      begin
        f = File.new("#{@dest_dir}/#{@build_name}/sudoers",'w')
        sudoers.each do |s|
          f.write("#{@user.run_as} ALL=(root) NOPASSWD: #{s}\n")
        end
      ensure
        f.write("\n\n")
        f.close
      end
      @sudoers_add = "ADD sudoers /etc/sudoers.d/#{@build_name}"
      @sudoers_line = "chown root.root /etc/sudoers.d/#{@build_name} && chmod 600 /etc/sudoers.d/#{@build_name}"
    end
  end

  def clone_repo(url)
    Git.clone(url, @build_name, :path => @dest_dir)
  end

  def load_blueprint
    blueprint_file = File.open("#{@dest_dir}/#{@build_name}/blueprint.json", 'r')
    begin
      require 'yajl'
      parser = Yajl::Parser.new(:symbolize_keys => true)
      json_hash = parser.parse(blueprint_file.read)
    ensure
      blueprint_file.close
    end
    json_hash
  end

  def process_service_bp(url, build_name, dest)
    @build_name = build_name
    @dest_dir = dest
    clone_repo(url)
    @bp = load_blueprint()
    process_bp
  end

  def process_bp
    @bp[:software].keys.each do |k|
      begin
        self.send(k.to_sym, @bp[:software][k])
      rescue StandardError => e
        STDERR.puts("#{e}\n #{e.backtrace}")
      end
    end
  end

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

  def uses_syslog(s)
    @uses_syslog = s
    if s == 'true'
      @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
      @system_packages_line += ' rsyslog '
    end
  end

  def uses_kerberos(k)
    @kerberos_support = k
    if k == 'true'
      @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
      @system_packages_line += ' krb5-user krb5-config '
    end
  end

  def system_packages(details)
    @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
    details.each do |p|
      @system_packages_line += " #{versioned_package(p)}"
    end
  end

  def versioned_package(p)
    if p[:version].nil?
      p[:package]
    else
      "#{p[:package]}:#{p[:version]}"
    end
  end

  def consumer_scripts(details)
    details.each_pair do |k,v|
      write_script("service/#{k}.sh", v)
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

  def save_actionator(a)
    write_script("actionators/#{a[:name]}.sh", a[:script])
  end

  def save_configurator(a)
    write_script("configurators/set_#{a[:name]}.sh", a[:set_script])
    write_script("configurators/read_#{a[:name]}.sh", a[:read_script])
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

  def add_file_perm(f)
    add_file_perm_cmd(file_perm_create(f)) unless f[:create].nil?
    add_file_perm_cmd(file_perm_chown(f))
    add_file_perm_cmd(file_perm_chmod(f)) unless f[:permissions].nil?
  end

  def add_file_perm_cmd(l)
    @file_permissions_line += " &&\\\n" unless @file_permissions_line.nil?
    add_to(@file_permissions_line, l)
  end

  def file_perm_create(f)
    if f[:create] == 'dir'
      "mkdir -d #{f[:path]}"
    elsif f[:create] = 'file'
      %Q(
     if ! test -f #{f[:path]} \
     then\
     touch #{f[:path]};\
     fi
   )
    end
  end

  def file_perm_chown(f)
    r = nil
    unless f[:user].nil?
      r = "chown #{f[:user]}"
      r += ".#{f[:group]}" unless f[:group].nil?
    else
      r = "chown #{f[:group]}"
    end
    r += " #{file_perm_recursive(f)} #{f[:path]}" unless r.nil?
  end

  def file_perm_chmod(f)
    "{chmod #{f[:permissions]}  #{file_perm_recursive(f)} #{f[:path]}"
  end

  def  file_perm_recursive(f)
    if f[:recursive]  == 'true'
      '-R'
    else
      ' '
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

  def download_package(d)
    if d[:download_type] == 'git'
      "git clone #{d[:command_options]} #{d[:source_url]}  /tmp/#{d[:name]}"
    else
      "wget #{d[:command_options]} #{d[:source_url]} =o /tmp/#{d[:name]}"
    end
  end

  def extract_package(d)
    unless d[:extraction_command].nil?
      r += "cd /tmp/; #{d[:extraction_command]} #{d[:name]} &&\\\n"
    end
  end

  def install_package(d)
    mv  "/tmp/#{d[:name]} #{d[:destination]}"
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

  def build_env
    @build_env ||= []
  end

  def required_modules(details)
    details.each do |m|
      add_system_package_line(m[:os_package]) unless m[:os_package].nil?
      add_to(@modules_line, self.send("install_#{m[:type]}_module", m))
    end
  end

  def add_system_package_line(l)
    @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
    @system_packages_line += " #{l}"
  end

  def replacement_strings(details)
    details.each do |s|
      @sed_line +="&& \\\n" unless @sed_line.nil?
      add_to(@sed_line, " cat #{s[:source_file]} | sed \"#{string}\" >/tmp/.sed && mv /tmp/.sed #{s[:destination_file]}")
    end
  end

  def add_to(store, val)
    if store.nil?
      store = val
    else
      store += val
    end
  end

end