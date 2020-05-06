class BlueprintReader
  def sudoers
     @sudoers ||= []
   end
 
   def process_sudoers
     unless sudoers.length == 0
       begin
         f = File.new("#{@dest_dir}/#{@build_name}/sudoers",'w')
         sudoers.each do |s|
           f.write("#{@user.run_as} ALL=(root) NOPASSWD: #{s}\n")
         end
       ensure
         f.write("\n\n")
         f.close
       end
       @sudoers_add = "ADD sudoers /etc/sudoers.d/#{@build_name}"
       @sudoers_line = "chown root.root /etc/sudoers.d/#{@build_name} && chmod 600 /etc/sudoers.d/#{@build_name}"
     end
   end
end