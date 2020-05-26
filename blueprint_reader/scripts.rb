class BlueprintReader
  def build_script_dir
    @build_script_dir ||= "#{script_base}/build"
  end

  def runtime_script_dir
    @runtime_script_dir ||= "/#{@dest_dir}/#{@build_name}#{script_base}"
  end

  def write_script(p, content)
    write_file("#{runtime_script_dir}/#{p}", content, 0550)
  end

  def write_file(p, content, perms=0444)
    perms=0444 if perms.nil?
    d = File.dirname(p)
    FileUtils.mkdir_p(d) unless Dir.exist?(d)
    f = File.new(p, 'w+')
    f.puts(content.delete("\r")) unless content.nil?
    FileUtils.chmod_R(perms, p)
  rescue StandardError =>e
    STDERR.puts("Error Writing Script #{p} \n#{e}\n#{e.backtrace}")
  ensure
    f.close
  end

  def save_actionator(a)
    write_script("actionators/#{a[:name]}.sh", a[:script][:content])
    unless a[:script_sudo].nil?
      p = "actionators/sudo/#{a[:name]}.sh"
      write_script(p, a[:script_sudo][:content])
      sudoers.push("#{script_base}/#{p}")
    end
  end

  def save_configurator(a)
    rc = a[:read_script][:content] unless a[:read_script].nil?
    sc = a[:set_script][:content]
    write_script("configurators/set_#{a[:name]}.sh", sc)
    write_script("configurators/read_#{a[:name]}.sh", rc )
    unless a[:set_script_sudo].nil?
      p = "configurators/sudo/set_#{a[:name]}.sh"
      write_script(p, a[:set_script_sudo][:content])
      sudoers.push("#{script_base}/#{p}")
    end

  end

  def start_script(details)
    write_script('startup/start.sh', details[:content])
  end

  def start_sudo_script(details)
    sudoers.push("#{script_base}/startup/sudo/start.sh")
    write_script('startup/sudo/start.sh', details[:content])
  end

  def install_script(details)
    write_script('build/install.sh', details[:content])
    @install_script_line = "#{build_script_dir}/install.sh"
  end

  def install_sudo_script(details)
    sudoers.push("#{build_script_dir}/sudo/install.sh")
    write_script('build/sudo/install.sh', details[:content])
  end

  def post_install_script(details)
    write_script('build/post_install.sh', details[:content])
    @post_install_script_line = "#{build_script_dir}/post_install.sh"
  end

  def post_install_sudo_script(details)
    sudoers.push("#{build_script_dir}/sudo/post_install.sh")
    write_script('build/sudo/post_install.sh', details[:content])
  end

  def first_run_script(details)
    write_script('first_run/first_run.sh', details[:content])
  end

  def first_run_sudo_script(details)
    sudoers.push("#{script_base}/first_run/sudo/first_run.sh")
    write_script('first_run/sudo/first_run.sh', details[:content])
  end

  def backup_sudo_script(details)
    sudoers.push("#{script_base}/backup/sudo/backup.sh")
    write_script('backup/sudo/backup.sh', details[:content])
  end

  def backup_script(details)
    write_script('backup/backup.sh', details)
  end

  def restore_sudo_script(details)
    sudoers.push("#{script_base}/backup/sudo/restore.sh")
    write_script('backup/sudo/restore.sh', details[:content])
  end

  def restore_script(details)
    write_script('backup/restore.sh', details[:content])
  end

  def shutdown_sudo_script(details)
    sudoers.push("#{script_base}/startup/sudo/shutdown.sh")
    write_script('startup/sudo/shutdown.sh', details[:content])
  end

  def shutdown_script(details)
    write_script('startup/shutdown.sh', details[:content])
  end

  def install_sudo_script(details)
    @multistage_build_text = details[:content]
    STDERR.puts("#{@multistage_build_text}")
  end
  
  def post_install_sudo_script(details)
     @multistage_from_text = details[:content]
    STDERR.puts("#{@multistage_from_text}")
   end 
end