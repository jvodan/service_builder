class BlueprintReader
  def line(v)
    v = nil if v == ' '
    "#{v}&&\\\n" unless v.nil?
  end

  def aline(v)
    "#{v}\n" unless v.nil?
  end

  def save_docker_file
    begin
      df = File.new("#{@dest_dir}/#{@build_name}/Dockerfile",'w')
      df.puts(docker_file)
    ensure
      df.close
    end
  end

  def docker_file
  %Q(
  #{multistage_build_text}
  FROM  engines/servicelayer:current
  FROM #{from_image}
  ADD home /home
  #{aline(sudoers_add)} \
  #{included_adds}
    
  #{template_adds}
  RUN  #{build_script_dir}/no_init.sh &&\\
    #{line(@user.create_line)} \
    chown 0.0 -R  #{build_script_dir} &&\\
    chgrp -R containers -R /home/engines &&\\
    #{line(repos_line)}\
    apt-get -y update &&\\
    #{line(system_packages_line)}\
    #{line(install_script_line)}\
    #{line(modules_line)}\
    #{line(template_line)}\
    #{line(included_adds_line)}\
    #{line(sed_line)}\
    #{break_run(multistage_from_text)}\
    #{line(install_packages_line)}\
    #{line(file_permissions_line)}\
    #{line(soft_links_line)}\
    #{line(log_dir_line)}\
    #{line(sudoers_line)}\
    #{line(post_install_script_line)}\
    #{build_script_dir}/post_build_clean.sh  
  USER #{user.run_as}

  ENV ContUser #{user.run_as}
  ENV ContGrp #{user.gname}
    RUN id ; ls -la /home/engines/scripts/startup
  CMD ["#{script_base}/system/start.sh"]
  )
  end

  def break_run(st)
    unless st.nil?
      %Q(echo .
      #{st}
      RUN )
    end

  end
end