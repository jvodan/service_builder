class BlueprintReader
  def scripts(details)
    details.keys.each do |k|
      self.send("#{k}_script", details[k])
    end
  end
  
  def write_script(p, details)
    p = "#{@dest_dir}/#{@build_name}/home/engines/scripts/#{p}"
    d = File.dirname(p)
    FileUtils.mkdir_p(d) unless Dir.exist?(d)
    f = File.new(p, 'w+')
    f.puts(details[:content])
    FileUtils.chmod_R('ug+x', p)
  rescue StandardError =>e
    STDERR.puts("#{e}")
  ensure
    f.close
  end

  def start_script(details)
    write_script('startup/start.sh', details)
  end

  def start_sudo_script(details)
    sudoers.push('/home/engines/startup/sudo/start.sh')
    write_script('startup/sudo/start.sh', details)
  end

  def install_script(details)
    write_script('build/install.sh', details)
  end

  def install_sudo_script(details)
    sudoers.push('/home/engines/build/sudo/install.sh')
    write_script('build/sudo/install.sh', details)
  end

  def post_install_script(details)
    write_script('build/post_install.sh', details)
  end

  def post_install_sudo_script(details)
    sudoers.push('/home/engines/build/sudo/post_install.sh')
    write_script('build/sudo/post_install.sh', details)
  end

  def first_run_script(details)
    write_script('first_run/first_run.sh', details)
  end

  def first_run_sudo_script(details)
    sudoers.push('/home/engines/first_run/sudo/first_run.sh')
    write_script('first_run/sudo/first_run.sh', details)
  end

  def backup_sudo_script(details)
    sudoers.push('/home/engines/backup/sudo/backup.sh')
    write_script('backup/sudo/backup.sh', details)
  end

  def backup_script(details)
    write_script('backup/backup.sh', details)
  end

  def restore_sudo_script(details)
    sudoers.push('/home/engines/backup/sudo/restore.sh')
    write_script('backup/sudo/restore.sh', details)
  end

  def restore_script(details)
    write_script('backup/restore.sh', details)
  end

  def shutdown_sudo_script(details)
    sudoers.push('/home/engines/startup/sudo/shutdown.sh')
    write_script('startup/sudo/shutdown.sh', details)
  end

  def shutdown_script(details)
    write_script('startup/shutdown.sh', details)
  end
end