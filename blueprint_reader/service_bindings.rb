class BlueprintReader
  def service_configurations(details)
    details.each do |s|
      process_binding(s)
    end   
  end
  
  def process_binding(s)
    if s[:publisher_namespace] == 'EnginesSystem' && s[:type_path] == 'filesystem/local/filesystem'
      STDERR.puts("VOLE #{s}")
      s[:container_type] = 'service'
      s[:parent_engines] = 'mysql'
      s[:service_handle] = s[:variables][:service_name]
      @container.volumes[s[:variables][:service_name]] = s
    STDERR.puts("VOLEs #{@container.volumes}")
    end
  end
end