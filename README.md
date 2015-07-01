DOI Requests need some extra setup:

1. Create a migration: `rails generate migration CreateDoiRequests`
1. Replace the contents of the new migration with this gist: https://gist.github.com/tingtingjh/ab35348f493d565cdcc8
1. Migrate: `rake db:migrate`
