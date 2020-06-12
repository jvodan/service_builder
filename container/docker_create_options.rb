class DockerCreateOptions
  def initialize
    @top_level = nil
  end
  require_relative 'container_state_files.rb'

  require_relative 'create_options/mount_options.rb'
  require_relative 'create_options/ports.rb'
  require_relative 'create_options/dns.rb'

  def create_options(container)
    @top_level = build_top_level(container)
    @top_level['name'] = container.container_name
    STDERR.puts("TOP LEVEL #{@top_level}")
    f = File.open("/tmp/#{container.container_name}.options", 'w')
    f.puts("#{@top_level.to_json}")
    @top_level
  rescue StandardError => e
    STDERR.puts("EXCEPTIPS #{e} \n #{e.backtrace}")
  ensure
    f.close unless f.nil?
  end

 

  def container_memory(container)
    container.memory.to_i * 1024 * 1024
  end

  def container_capabilities(container)
    unless container.capabilities.nil?
      add_capabilities(container.capabilities)
    else
      []
    end
  end

  def host_config_options(container)
    {
      'Binds' => volumes_mounts(container),
      'Memory' => container_memory(container),
      'MemorySwap' => container_memory(container) * 2,
      'VolumesFrom' => container_volumes(container),
      'CapAdd' => container_capabilities(container),
      'OomKillDisable' => false,
      'LogConfig' => log_config(container),
      'PublishAllPorts' => false,
      'Privileged' => container.is_privileged?,
      'ReadonlyRootfs' => false,
      'Dns' => container_get_dns_servers(container),
      'DnsSearch' => container_dns_search(container),
      'NetworkMode' => container_network_mode(container),
      'RestartPolicy' => restart_policy(container)
    }
  end

  def restart_policy(container)
    if ! container.restart_policy.nil?
      container.restart_policy
    elsif container.ctype == 'system_service'
      {'Name' => 'unless-stopped'}
    elsif container.ctype == 'service'
      #{'Name' => 'on-failure', 'MaximumRetryCount' => 4}
      {'Name' => 'no'}
    else
      {}
    end
  end

  def log_config(container)
    if container.ctype == 'service'
      { "Type" => 'json-file', "Config" => { "max-size" =>"5m", "max-file" => '10' } }
    elsif container.ctype == 'system_service'
      { "Type" => 'json-file', "Config" => { "max-size" =>"1m", "max-file" => '20' } }
    else
      { "Type" => 'json-file', "Config" => { "max-size" =>"1m", "max-file" => '5' } }
    end
  end

  def add_capabilities(capabilities)
    #    r = []
    #    capabilities.each do |capability|
    #      r += capability
    capabilities
  end

  def container_network_mode(container)
    if container.on_host_net? == false
      'bridge'
    else
      'host'
    end
  end

  def io_attachments(container, top)

    unless container.accepts_stream?
      top['AttachStdin'] = false
    else
      top['AttachStdin'] = true
    end
    unless container.provides_stream?
      top['AttachStdout'] = false
      top['AttachStderr'] = false
    else
      top['AttachStdout'] = true
      top['AttachStderr'] = true
    end

    top['OpenStdin'] = false
    top['StdinOnce'] = false
  end

  def build_top_level(container)
    top_level = {
      'User' => '',
      'Tty' => false,
      'Env' => envs(container),
      'Image' => container.image,
      'Labels' => get_labels(container),
      'Volumes' => {},
      'WorkingDir' => '',
      'NetworkDisabled' => false,
      'StopSignal' => 'SIGTERM',
      #       "StopTimeout": 10,
      'Hostname' => hostname(container),
      'Domainname' => container_domain_name(container),
      'HostConfig' => host_config_options(container)
    }
    io_attachments(container, top_level)
    top_level['ExposedPorts'] = exposed_ports(container) unless container.on_host_net
    top_level['HostConfig']['PortBindings'] = port_bindings(container) unless container.on_host_net
    set_entry_point(container, top_level)
   # STDERR.puts('Options:' + top_level.to_s)
    top_level
  end

  def set_entry_point(container, top_level)
    command =  container.command
    unless container.conf_self_start
      command = ['/bin/bash' ,'/home/engines/scripts/startup/start.sh'] if container.command.nil?
      top_level['Entrypoint'] = command
    end
  end

  def get_labels(container)
    {
      'container_name'  => container.container_name,
      'container_type' => container.ctype
    }
  end

  def envs(container)
    envs = system_envs(container)
    unless container.environments.nil?
    container.environments.each do |env| 
      next if env.build_time_only
      env.value ='NULL!' if env.value.nil?
      env.name = 'NULL' if env.name.nil?
      envs.push("#{env.name}=#{env.value}")
    end
      end
    envs
  end

  def system_envs(container)
    envs = []
    envs[0] = "CONTAINER_NAME=#{container.container_name}"
    envs[1] = "KRB5_KTNAME=/etc/krb5kdc/keys/#{container.container_name}.keytab" if container.kerberos == true
    envs
  end


end