class BlueprintReader
  #keys within blueprint that are not used defined here to avoid no such method error 
  def service_configurations(details)
    #not used to build EXCEPT environment
  end

  def constants(details)
    #not used to build
  end

  def schedules(details)
  end
  
  def target_environment_variables(details)
    #not used to build
  end

  def consumer_params(details)
    #not used to build
  end

  def consumers(details)
    #not used to build
  end

  def custom_files(details)
    #dont use, this function include
  end
end