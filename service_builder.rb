require_relative 'blueprint_reader/blueprint_reader.rb'

def line(v)
  v = nil if v == ' '
  "#{v}&&\\\n" unless v.nil?
end

def aline(v)
  "#{v}\n" unless v.nil?
end

def remove_existing(d)
  FileUtils.rm_r(d) if Dir.exist?(d)
end

def docker_file(br)
  %Q(
FROM #{br.from_image}
ADD home home
#{aline(br.sudoers_add)} \
#{br.included_adds}\
RUN \
  #{line(br.repos_line)}\
  apt-get -y update &&\
  #{line(br.system_packages_line)}\
  #{br.modules_line}\
  #{line(br.modules_line)}\
  #{line(br.included_adds_line)}\
  #{line(br.sed_line)}\
  #{line(br.install_packages_line)}\
  #{line(br.file_permissions_line)}\
  #{line(br.soft_links_line)}\
  #{line(br.log_dir_line)}\
  #{br.sudoers_line}\

USER #{br.user.run_as}

ENV ContUser #{br.user.run_as}
ENV ContGrp #{br.user.gname}

CMD ["/home/engines/scripts/system/start.sh"]
)
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
  br = BlueprintReader.new
  remove_existing("#{@dest}/#{build_name}") if @delete_existing == true

  sd = br.process_service_bp(url, build_name, @dest, @release)

  br.process_sudoers
  begin
    df = File.new("#{@dest}/#{build_name}/Dockerfile",'w')
    df.puts(docker_file(br))
  ensure
    df.close
  end
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
      do_build(ARGV[0], ARGV[1])
    else
      process_batch
    end

  rescue StandardError =>e
    STDERR.puts("E #{e} \n #{e.backtrace}")
  end
end

process_args
