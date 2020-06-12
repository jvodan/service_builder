require_relative 'blueprint_reader/blueprint_reader.rb'
require_relative 'docker_factory.rb'

def remove_existing(d)
  FileUtils.rm_r(d) if Dir.exist?(d)
end

def process_batch
  begin
    bf = File.new(@batch_file, 'r')
  rescue Exception =>e
    STDERR.puts("Error #{e} trying to open #{@batch_file}")
    exit
  end
  bf.each do |l|
    STDERR.puts(("#{l}"))
    c = l.split(' ')
    break if c.length == 0
    STDERR.puts(("do_build(#{c[0]}, #{c[1]}"))
    do_build(c[0], c[1])
    STDERR.puts(("did build (#{c[0]}, #{c[1]}"))
  end
ensure
  bf.close
end

def do_build(url, build_name)
  br = BlueprintReader.new(build_name, ctype = :service)
  remove_existing("#{@dest}/#{build_name}") if @delete_existing == true
  
  sd = br.process_service_bp(url, @dest, @release)
  ENV['DOCKER_URL'] = 'unix://var/run/docker.sock'
  DockerFactory.build_image({ name: build_name,
    release: @release,
    delete_existing: @delete_existing,
    path: @dest
  }) if @do_build
  ENV['DOCKER_IP'] = '192.168.208.98'
  options = br.container.docker_create_options
  STDERR.puts("#{options.to_json}")
  DockerFactory.create_container(options)
end

def process_args
  usage=%Q(service_builder -hD -R release -r repo_base -p -b -d base_dir blueprint_url build_name
 -h help
 -D delete existing
 -d base_dir defaults to /tmp
 -b build not yet implemented
 -p repo_base push to repo_base/build_name:release not implemented
 -r repo_base not implemented
 -R release build release
 -B batch_file Batch mode
)
  begin
    @dest = '/tmp/'
    @release = 'current'
    while ARGV[0].start_with?('-')
      case(ARGV[0])
      when '-D'
        @delete_existing = true
      when '-d'
        ARGV.delete_at(0)
        @dest = ARGV[0]
      when '-h'
        puts(usage)
        exit
      when '-B'
        ARGV.delete_at(0)
        @batch_file = ARGV[0]
      when '-b'
        @do_build = true
      when '-p'
        @do_push = true
      when '-R'
        ARGV.delete_at(0)
        @release = ARGV[0]
      when '-r'
        ARGV.delete_at(0)
        @docker_repo = ARGV[0]
      end
      ARGV.delete_at(0)
      break if ARGV.length == 0
    end
    if @batch_file.nil?
      if ARGV.length != 2
        STDERR.puts("Incorrect number of params \n#{usage}")
        exit -1
      end
      i =  do_build(ARGV[0], ARGV[1])
      STDERR.puts("Built #{i}")
    else
      process_batch
    end

  rescue StandardError =>e
    STDERR.puts("E #{e} \n #{e.backtrace}")
  end
end

process_args
