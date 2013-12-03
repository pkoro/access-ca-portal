class Capistrano::Configuration

 ##
 # Print an informative message with asterisks.

 def inform(message)
   puts "#{'*' * (message.length + 4)}"
   puts "* #{message} *"
   puts "#{'*' * (message.length + 4)}"
 end

 ##
 # Read a file and evaluate it as an ERB template.
 # Path is relative to this file's directory.

 def render_erb_template(filename)
   template = File.read(filename)
   result   = ERB.new(template).result(binding)
 end

 ##
 # Run a command and return the result as a string.
 #
 # TODO May not work properly on multiple servers.
 
 def run_and_return(cmd)
   output = []
   run cmd do |ch, st, data|
     output << data
   end
   return output.to_s
 end

end

namespace :gridauth do
 desc "Create shared/config directory and default database.yml."
 task :create_shared_config do
   run "mkdir -p #{shared_path}/config"

   # Copy database.yml if it doesn't exist.
   result = run_and_return "ls #{shared_path}/config"
   unless result.match(/database\.yml/)
     contents = render_erb_template(File.dirname(__FILE__) + "/templates/database.yml.erb")
     put contents, "#{shared_path}/config/database.yml"
   end
 end
 after "deploy:setup", "gridauth:create_shared_config"
 
 desc "Create directory for uploaded files"
 task :create_upload_dir do
   run "mkdir -p #{shared_path}/files"
 end
 after "gridauth:create_shared_config", "gridauth:create_upload_dir"
 
 desc "Link the database.yml" 
 task :link_database_yml_from_shared_config do
   run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml" 
 end
 after "deploy:update_code", "gridauth:link_database_yml_from_shared_config"
 
 desc "Update config.yml" 
 task :update_config_yml do
   rev = `svn info -rHEAD|grep "^Revision:"|awk -F": " '{print $2}'|tr -d "\n"`
   run "sed -i 's\#_REVISION_\##{rev}\#g' #{current_path}/config/config.yml"
 end
 after "deploy:symlink", "gridauth:update_config_yml"
 
 desc "Create link for the directory where the uploaded files will reside"
 task :link_uploaded_files_directory do
   run "ln -nfs #{deploy_to}/#{shared_dir}/files #{release_path}/public/files"
 end
 after "gridauth:link_database_yml_from_shared_config", "gridauth:link_uploaded_files_directory"

end

#############################################################
#	Passenger
#############################################################

namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
after :deploy, "passenger:restart"
