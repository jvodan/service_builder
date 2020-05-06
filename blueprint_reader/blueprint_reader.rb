class BlueprintReader
  require 'yajl'
  require 'git'
  require_relative 'blueprint_keys'
  require_relative 'blueprint_load'

  attr_reader   :included_adds,
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
  :repos_line,
  :sudoers_add,
  :sudoers_line,
  :install_packages_line

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
      rescue NoSuchMethodException => e
        STDERR.puts("No Method found for #{k}")
      end
    end
  end

  def build_env
    @build_env ||= []
  end

  def add_to(cvar, val)
    if cvar.nil?
      cvar = val
    else
      cvar += val
    end
  end

end