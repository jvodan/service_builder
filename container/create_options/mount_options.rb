require 'yaml'

def container_volumes(container)
  unless container.volumes_from.nil?
    container.volumes_from
  else
    []
  end
end

def volumes_mounts(container)
  mounts = []
  unless container.volumes.nil?
    container.volumes.each_value do |volume|
      mounts.push(mount_string_from_hash(volume))
    end
  end

  sm = system_mounts(container)
  mounts.concat(sm) unless sm.nil?
 
  # SECRET SERVICE DISABLED
 # secrets = secrets_mounts(container)  
 # mounts.concat(secrets) unless secrets.nil?

  # HOMES SERVICE DISABLED
  # homes = homes_mounts(container)
  # mounts.concat(homes) unless homes.nil?

  unless container.ctype == 'system_service'
    # VOLUME SERVICE DISABLED
    #rm = registry_mounts(container)
    #mounts.concat(rm) unless rm.nil?
  end
  mounts
end

def mount_string(volume)
  volume[:permissions] =  volume['permissions']  unless volume['permissions'].nil?
  volume[:localpath] =  volume['localpath']  unless volume['localpath'].nil?
  volume[:remotepath] =  volume['remotepath']  unless volume['remotepath'].nil?
  perms = 'ro'
  if volume[:permissions] == 'rw'
    perms = 'rw'
  else
    perms = 'ro'
  end
  "#{volume[:localpath]}:#{volume[:remotepath]}:#{perms}"
rescue StandardError => e
  STDERR.puts('Problem with ' + volume.to_s)
  raise e
end

def cert_mounts(ca)
  store = "#{ca[:c_type]}s/#{ca[:c_name]}/"
  ["#{SystemConfig.CertAuthTop}#{store}certs:#{SystemConfig.CertificatesDestination}:ro",
    "#{SystemConfig.CertAuthTop}#{store}keys:#{SystemConfig.KeysDestination}:ro"]
end

def get_local_prefix(vol)
  unless vol[:variables][:volume_src].start_with?('/tmp/var/lib/engines/apps/') == true || vol[:variables][:volume_src].start_with?('/tmp/var/lib/engines/services/') == true
    unless vol[:shared] == true
      "/tmp/var/lib/engines/#{vol[:container_type]}s/#{vol[:parent_engine]}/#{vol[:service_handle]}/"
    else
      "/tmp/var/lib/engines/#{vol[:container_type]}s/#{vol[:service_owner]}/#{vol[:service_owner_handle]}/"
    end
  else
    ''
  end
rescue Exception => e
  STDERR.puts('EXCEPTION:'+ e.to_s + ' With ' + vol.to_s)
  raise e
end

def get_remote_prefix(vol)
  if  vol[:container_type] == 'app'
    unless vol[:variables][:engine_path].start_with?('/home/app/') || vol[:variables][:engine_path].start_with?('/home/fs/')
      '/home/fs/'
    else
      ''
    end
  else
    unless vol[:variables][:engine_path].start_with?('/')
      '/'
    else
      ''
    end
  end
rescue Exception => e
  STDERR.puts('EXCEPTION:'+ e.to_s + ' With ' + vol.to_s)
  raise e
end

def  mount_string_from_hash(vol)
  STDERR.puts("Moutn #{vol}")
  unless vol[:variables][:permissions].nil? || vol[:variables][:volume_src].nil?  || vol[:variables][:engine_path].nil?
    perms = 'ro'
    if vol[:variables][:permissions] == 'rw'
      perms = 'rw'
    else
      perms = 'ro'
    end
    vol[:variables][:volume_src].strip!
    vol[:variables][:volume_src].gsub!(/[ \t]*$/,'')
    "#{get_local_prefix(vol)}#{vol[:variables][:volume_src]}:#{get_remote_prefix(vol)}#{vol[:variables][:engine_path]}:#{perms}"
  else
    STDERR.puts('missing keys in vol ' + vol.to_s )
    ''
  end
end


def registry_mounts(container)
  mounts = []
  vols = container.attached_services(
  {type_path: 'filesystem/local/filesystem'
  })
  if vols.is_a?(Array)
    vols.each do | vol |
      v_str = mount_string_from_hash(vol)
      mounts.push(v_str)
    end
    # else
    STDERR.puts('Registry mounts was' + v_str.to_s)
  end
  mounts
end

def  mount_string_for_secret(secret)

  if secret[:shared] == true
    src_cname =  secret[:service_owner]
    src_ctype =  secret[:container_type]
    sh = secret[:service_owner_handle]
    #   STDERR.puts('Secrets mount Shared')
  else
    #    STDERR.puts('Secrets mount Owner')
    src_cname =  secret[:parent_engine]
    src_ctype =  secret[:container_type]
    sh = secret[:service_handle]
  end
  # STDERR.puts('Secrets mount' +  '/tmp/var/lib/engines/secrets/' + src_ctype.to_s + 's/' +  src_cname.to_s + '/' + sh.to_s + ':/home/.secrets/'  + sh.to_s + ':ro')
  s = "/tmp/var/lib/engines/secrets/#{src_ctype}s/#{src_cname}/#{sh}:/home/.secrets/#{sh}:ro"
  # STDERR.puts('Secrets mount' + s.to_s)
  s
end

def  mount_string_for_homes(home)
  s = nil
  src_cname =  home[:parent_engine]
  src_ctype =  home[:container_type]
  if  home[:variables][:home_type] == 'all'
    # STDERR.puts('Secrets mount' +  '/tmp/var/lib/engines/secrets/' + src_ctype.to_s + 's/' +  src_cname.to_s + '/' + sh.to_s + ':/home/.secrets/'  + sh.to_s + ':ro')
    s = "/tmp/var/lib/engines/home/:/home/users/:#{home[:variables][:access]}"
  elsif home[:variables][:home_type] == 'seperate'
    s = []
    home[:variables][:homes].split(", \n").each do | user |
      #     STDERR.puts('SDFSDF ' + '/tmp/var/lib/engines/home/' + user)
      #FIXME do a ldap looku for user if user exists create else next
      #  next unless Dir.exist?('/home/users/' + user  )
      #     STDERR.puts('SDFSDF ' + '/tmp/var/lib/engines/home/' + user + '/' +  home[:parent_engine] + ':/home/users/' + user  + '/' +  home[:parent_engine] + ':'  + home[:variables][:access])
      s.push("/tmp/var/lib/engines/home/#{user}/#{home[:parent_engine]}:/home/users/#{user}/#{home[:parent_engine]}:#{home[:variables][:access]}")
    end
  else
    STDERR.puts('serr ' + home.to_s)
  end
  # STDERR.puts('Homes mount' + s.to_s)
  s
end

def homes_mounts(container)
  mounts = []
  unless container.ctype == 'system_service'
    homes = container.attached_services(
    {type_path: 'homes'
    })
    #   STDERR.puts('HOMES ' + homes.to_s)
    if homes.is_a?(Array)
      homes.each do | home |
        m_str = mount_string_for_homes(home)
        if m_str.is_a?(String)
          mounts.push(m_str)
        elsif m_str.is_a?(Array)
          mounts.concat(m_str)
        end
      end
      #  else
      #   STDERR.puts('Secrets mounts was' + secrets.to_s)
    end
  end
  mounts
end

def secrets_mounts(container)
  mounts = []
  unless container.ctype == 'system_service'
    secrets = container.attached_services(
    {type_path: 'secrets'
    })
    if secrets.is_a?(Array)
      secrets.each do | secret |
        m_str = mount_string_for_secret(secret)
        mounts.push(m_str)
      end
    end
  end
  mounts
end

def system_mounts(container)
  mounts = []
  if container.ctype == 'app'
    mounts_file_name = SystemConfig.ManagedEngineMountsFile
  else
    mounts_file_name = SystemConfig.ManagedServiceMountsFile
  end
  mounts_file = File.open(mounts_file_name, 'r')
  begin
    volumes = YAML::load(mounts_file)
  ensure
    mounts_file.close
  end
  volumes.each_value do |volume|
    STDERR.puts("Read #{volume}")
    mounts.push(mount_string(volume))
  end
  mounts.push(state_mount(container.store_address))
  mounts.push(logdir_mount(container))
  mounts.push(vlogdir_mount(container.store_address)) unless in_container_log_dir(container) == '/var/log' || in_container_log_dir(container) == '/var/log/'
  mounts.push(ssh_keydir_mount(container.store_address))
  cm = nil
  cm = cert_mounts(container.store_address) unless container.no_cert_map == true
  mounts.push(kerberos_mount(container.store_address)) if container.kerberos == true
  mounts.concat(cm) unless cm.nil?
  mounts
end

def ssh_keydir_mount(ca)
  "#{ContainerStateFiles.container_ssh_keydir(ca)}:/home/home_dir/.ssh:rw"
end

def secrets_mount(ca)
  "#{ContainerStateFiles.secrets_dir(ca)}:/home/.secrets:ro"
end

def kerberos_mount(ca)
  "#{ContainerStateFiles.kerberos_dir(ca)}:/etc/krb5kdc/keys/:ro"
end

def vlogdir_mount(ca)
  "#{container_local_log_dir(ca)}':/var/log/:rw"
end

def logdir_mount(c)
  "#{container_local_log_dir(c.store_address)}:#{in_container_log_dir(c)}:rw"
end

def state_mount(ca)
  "#{ContainerStateFiles.container_state_dir(ca)}/run:/home/engines/run:rw"
end

def container_local_log_dir(ca)
  ContainerStateFiles.container_log_dir(ca)
end

def service_sshkey_local_dir(ca)
  "/opt/engines/etc/ssh/keys/#{ca[:c_type]}s/#{ca[:c_name]}"
end

def in_container_log_dir(container)
  if container.framework.nil? || container.framework.length == 0
    '/var/log'
  else
    container_logdetails_file_name = false
    framework_logdetails_file_name = "#{SystemConfig.DeploymentTemplates}/#{container.framework}/home/engines/etc/LOG_DIR"
    SystemDebug.debug(SystemDebug.docker, 'Frame logs details', framework_logdetails_file_name)
    if File.exist?(framework_logdetails_file_name)
      container_logdetails_file_name = framework_logdetails_file_name
    else
      container_logdetails_file_name = "#{SystemConfig.DeploymentTemplates}/global/home/engines/etc/LOG_DIR"
    end
    SystemDebug.debug(SystemDebug.docker,'Container log details', container_logdetails_file_name)
    begin
      container_logdetails = File.read(container_logdetails_file_name)
    rescue
      container_logdetails = '/var/log'
    end
    container_logdetails
  end
end