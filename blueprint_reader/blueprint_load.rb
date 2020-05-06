class BlueprintReader
  def clone_repo(url)
    Git.clone(url, @build_name, :path => @dest_dir)
  end

  def load_blueprint
    blueprint_file = File.open("#{@dest_dir}/#{@build_name}/blueprint.json", 'r')
    begin
      require 'yajl'
      parser = Yajl::Parser.new(:symbolize_keys => true)
      json_hash = parser.parse(blueprint_file.read)
    ensure
      blueprint_file.close
    end
    json_hash
  end
end