class BlueprintReader
  def add_file_perm(f)
    add_file_perm_cmd(file_perm_create(f)) unless f[:create].nil?
    add_file_perm_cmd(file_perm_chown(f))
    add_file_perm_cmd(file_perm_chmod(f)) unless f[:permissions].nil?
  end

  def add_file_perm_cmd(l)
    @file_permissions_line += " &&\\\n" unless @file_permissions_line.nil?
    add_to('@file_permissions_line', l)
    STDERR.puts("#{ @file_permissions_lin}")
    
  end

  def file_perm_create(f)
    if f[:create] == 'dir'
      "mkdir -p #{f[:path]}"
    elsif f[:create] = 'file'
      %Q(
      if ! test -f #{f[:path]} \
      then\
      touch #{f[:path]};\
      fi
    )
    end
  end

  def file_perm_chown(f)
   f[:user] = f[:owner] if f.key?(:owner) 
  
    r = nil
    unless f[:user].nil?
      r = "chown #{f[:user]}"
      r += ".#{f[:group]}" unless f[:group].nil?
    else
      r = "chown #{f[:group]}"
    end
    r += " #{file_perm_recursive(f)} #{f[:path]}" unless r.nil?
      r
  end

  def file_perm_chmod(f)
    "chmod #{f[:permissions]}  #{file_perm_recursive(f)} #{f[:path]}"
  end

  def  file_perm_recursive(f)
    if f[:recursive] == 'true'
      '-R'
    else
      ' '
    end
  end

end