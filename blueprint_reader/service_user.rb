class ServiceUser
  attr_reader :run_as, :uid, :gname
  def initialize(h)
    @run_as = h[:run_as_user]
    @uid = h[:user_id]
    @gname = h[:user_primary_group]
    @create = h[:create_user]
  end

  def create?
    if @create == 1
      true
    else
      false
    end
  end
end