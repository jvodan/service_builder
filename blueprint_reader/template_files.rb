class BlueprintReader

   def save_template(d)
       write_file("#{@dest_dir}/#{@build_name}/templates/#{d[:path]}", d[:content])
   end

def template_ownership(d)
  add_file_perm(d)
end
  
end