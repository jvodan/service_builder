class Container
  require_relative 'docker_create_options'
  attr_accessor :hostname,
  :container_name,
  :ctype,
  :image,
  :environments,
  :volumes_from,
  :volumes,
  :attached_services,
  :no_cert_map,
  :kerberos,
  :framework,
  :mapped_ports,
  :memory,
  :restart_policy,
  :capabilities,
  :is_privilaged,
  :on_host_net,
  :provides_stream,
  :accepts_stream,
  :command,
  :conf_self_start
  def initialize(name, ctype = :app)
    @hostname = name
    @container_name = name
    @ctype = ctype
    @conf_self_start = false
    @on_host_net = false
    @is_privilaged  = false
    @provides_stream = false
    @accepts_stream = false
    @command = nil
    @no_cert_map  = false
    @kerberos  = true if ctype == :app
    @capabilities = []
  end

  def store_address
    @store_address ||= { c_name: @container_name.to_s, c_type: @ctype.to_s }
  end

  def on_host_net?
    false
  end

  def accepts_stream?
    @accepts_stream
  end

  def provides_stream?
    @provides_stream
  end

  def is_privileged?
    @is_privilaged
  end

  def ports=(d)
    @mapped_ports = d
  end

  def docker_create_options
    r = DockerCreateOptions.new
    r.create_options(self)
  end
end
