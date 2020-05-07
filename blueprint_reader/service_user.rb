class ServiceUser
  attr_reader :run_as, :uid, :gname
  def initialize(h)
    @run_as = h[:run_as_user]
    @uid = h[:user_id]
    @gname = h[:user_primary_group]
    @create = h[:create_user]
    @gname = @run_as  if @gname.nil?
  end

  def create_line
    if create? == true
      %Q(groupadd -g #{@uid}  #{@gname}  &&\
      mkdir /home/#{@run_as} &&\
        useradd -u #{@uid}  -g #{@gname} --home /home/#{@run_as} -G containers #{@run_as} &&\
          chown -R #{@run_as} ~#{@run_as})
    else 
      STDERR.puts("no create #{@create} #{create?} \n #{inspect} ")
    end
  end
  def create?
    if @create == '1'
      true
    else
      false
    end
  end
end