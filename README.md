DOI Requests need some extra setup:

1. Create a migration: `rails generate migration CreateDoiRequests`
2. Replace the contents of the new migration with this gist: https://gist.github.com/tingtingjh/ab35348f493d565cdcc8
3. Generate Role model: `rails generate roles`
1. Migrate: `rake db:migrate`
5. Create an admin user: `rake datarepo:setup_roles`
6. Install Orcid: `rails generate orcid:install`
