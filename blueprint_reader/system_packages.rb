class BlueprintReader
  def add_system_package_line(l)
    @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
    @system_packages_line += " #{l}"
  end

  def versioned_package(p)
    if p[:version].nil?
      p[:package]
    else
      "#{p[:package]}:#{p[:version]}"
    end
  end

end