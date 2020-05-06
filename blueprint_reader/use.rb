class BlueprintReader
  def uses_syslog(s)
    @syslog_support = s
    if s == 'true'
      @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
      @system_packages_line += ' rsyslog '
    end
  end

  def uses_kerberos(k)
    @kerberos_support = k
    if k == 'true'
      @system_packages_line = 'apt-get install -y ' if @system_packages_line.nil?
      @system_packages_line += ' krb5-user krb5-config '
    end
  end
end