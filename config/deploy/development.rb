set :user, "access"
set :runner, user

set :application, "access-dev.hellasgrid.gr"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the eploy_to variable:
set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :repository, "https://svn.hellasgrid.gr/svn/hellasgrid-user-registration.grid.auth.gr/branches/1.x"
set :scm, :subversion
set :copy_strategy, :export
set :deploy_via, :copy
set :use_sudo, false

role :app, "srv-103.afroditi.hellasgrid.gr"
role :web, "srv-103.afroditi.hellasgrid.gr"
role :db,  "srv-103.afroditi.hellasgrid.gr", :primary => true

set :db_adapter, "postgresql"
set :db_name, "HellasGridCA"
set :db_user, "HellasGridCA"
set :db_password, "HellasGridCA_open_db"
set :db_host, "10.206.123.32"

set :rails_env, "production"

set :rake, "/opt/ree/bin/rake"
set :ruby, "/opt/ree/bin/ruby"