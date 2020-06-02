class BlueprintReader
  require 'yajl'
  require 'git'
  require_relative 'blueprint_keys'
  require_relative 'blueprint_load'
  require_relative 'docker_file'

  attr_accessor   :included_adds,
  :build_name,
  :user,
  :syslog_support,
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
  :included_adds,
  :repos_line,
  :sudoers_add,
  :sudoers_line,
  :install_packages_line,
  :install_script_line,
  :post_install_script_line,
  :template_line,
  :template_adds,
  :multistage_build_text,
  :multistage_from_text

  def process_service_bp(url, build_name, dest, release)
    @build_name = build_name
    @release = release
    @dest_dir = dest
    clone_repo(url)
    @bp = load_blueprint()
    process_bp

  end

  def process_bp
    @bp[:software].keys.each do |k|
      begin
        self.send(k.to_sym, @bp[:software][k])
      rescue NoMethodError => e
        STDERR.puts("No Method found for #{k} #{e} \n #{e.backtrace}")
      end
    end
    process_sudoers
    save_docker_file
  end

  def build_env
    @build_env ||= []
  end
  
  def script_base
    @script_base ||= '/home/engines/scripts'
  end

  def add_to(cvar, val)
    ivar = self.instance_variable_get(cvar)
    if ivar.nil?
      self.instance_variable_set(cvar, val)
    else
      self.instance_variable_set(cvar, ivar + val)
    end
  end

end