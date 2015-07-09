DOI Requests need some extra setup:

1. Create a migration: `rails generate migration CreateDoiRequests`
1. Replace the contents of the new migration with this gist: https://gist.github.com/tingtingjh/ab35348f493d565cdcc8
1. Generate Role model: `rails generate roles`
1. Remove the before filter added to app/controllers/application_controller.rb
1. Migrate: `rake db:migrate`
1. Create an admin user: `rake datarepo:setup_roles`
1. Install Orcid: `rails generate orcid:install --skip-application-yml`
1. Revert changes already incorporated: `git checkout ./app/models/user.rb ./config/routes.rb`
1. Run the CAS installation script: https://github.com/VTUL/InstallScripts/blob/master/Vagrant/CAS_extras.sh
  - The script takes two parameters, the name of the repository, and the name of the server
  - Example: `bash ./CAS_extras.sh data-repo myserver.com`
