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
  FROM #{from_image}
  ADD home home
  #{aline(sudoers_add)} \
  #{included_adds}\
  RUN \
    #{line(repos_line)}\
    apt-get -y update &&\
    #{line(system_packages_line)}\
    #{modules_line}\
    #{line(modules_line)}\
    #{line(included_adds_line)}\
    #{line(sed_line)}\
    #{line(install_packages_line)}\
    #{line(file_permissions_line)}\
    #{line(soft_links_line)}\
    #{line(log_dir_line)}\
    #{sudoers_line}\

  USER #{user.run_as}

  ENV ContUser #{user.run_as}
  ENV ContGrp #{user.gname}

  CMD ["/home/engines/scripts/system/start.sh"]
  )
  end

end