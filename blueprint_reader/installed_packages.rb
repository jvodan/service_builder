class BlueprintReader
  
  
  def download_package(d)
    if d[:download_type] == 'git'
      "git clone #{d[:command_options]} #{d[:source_url]}  /tmp/#{d[:name]}"
    else
      "wget #{d[:command_options]} #{d[:source_url]} -o /tmp/#{d[:name]}"
    end
  end

  def extract_package(d)
    unless d[:extraction_command].nil?
      "cd /tmp/; #{d[:extraction_command]} #{d[:name]} &&\\\n"
    end
  end

  def install_package(d)
    "mv /tmp/#{d[:name]} #{d[:destination]}"
  end
end