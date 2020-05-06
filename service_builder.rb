require_relative 'blueprint_reader/blueprint_reader.rb'

def line(v)
  v = nil if v == ' '
  "#{v}&&\\\n" unless v.nil?
end

def aline(v)
  "#{v}\n" unless v.nil?
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

while ARGV[0].start_with?('-')
  case(ARGV[0])
  when '-d'
    delete_existing = true
  end
  ARGV.delete_at(0)
end
br = BlueprintReader.new
url = ARGV[0]#'https://github.com/EnginesServices/mysql'
build_name = ARGV[1] #'mysqld'
dest = '/tmp/'
sd = br.process_service_bp(url, build_name, dest)

br.process_sudoers
begin
  df = File.new("#{dest}/#{build_name}/Dockerfile",'w')
  df.puts(docker_file(br))
ensure
  df.close
end

