class ServiceUser
  attr_reader :run_as, :uid, :gname
  def initialize(h)
    @run_as = h[:run_as_user]
    @uid = h[:user_id]
    @gname = h[:user_primary_group]
    @create = h[:create_user]
    @gname = @run_as  if @gname.nil?
    @uid = 200200 if @uid.nil?
    end
  

  def create_line
    if create? == true
      %Q(groupadd -g #{@uid}  #{@gname}  ;\\
      mkdir -p /home/#{@run_as} &&\\
      id=`id #{@run_as} |wc -c` &&\\
      if test $id -eq 0;\
       then  \
        useradd -u #{@uid}  -g #{@gname} --home /home/#{@run_as} -G containers #{@run_as} ;\
       else \
        usermod  -u #{@uid}  -G containers #{@run_as}; \
       fi &&\\
      usermod -a -G containers #{@run_as} &&\\
      chown -R #{@run_as} ~#{@run_as}&&\\)                     
    else 
      "usermod -a -G containers #{@run_as}&&\\"
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