class DockerFactory
  require 'docker'
  require 'json'
  
  def self.build_image(p)
    tag = "engines/#{p[:name]}:#{p[:release]}"
    bdir = "#{p[:path]}/#{p[:name]}"
    i = Docker::Image.build_from_dir(bdir, self.docker_options(tag)) do |v|
      # FIXME use yajil
    if (log = JSON.parse(v)) && log.has_key?("stream") 
      $stdout.puts log["stream"]
    else
      $stdout.puts "Unknown #{log}"
    end
  end
   i
  end
  def self.docker_options(tag)
    { 'dockerfile' => 'Dockerfile', 't' => tag, 'forcerm' => true}
  end
  
  def self.create_container(options)
    r = Docker::Container.create(options)
    STDERR.puts("Container Create #{r}")
  end
end