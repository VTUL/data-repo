namespace :datarepo do 

  desc 'Setup Roles'
  task setup_roles: :environment do
    %w(admin collection_admin collection_user).each do |role|
      if Role.where(name: role).first.nil?
        Role.create(name: role)
      end
    end

    desc 'Create an initial admin user for DataRepo'
    STDOUT.puts 'Please provide your email address:'
    email = STDIN.gets.strip

    STDOUT.puts 'Please Type in your password:'
    password = STDIN.gets.strip

    if User.find_by_email(email).nil?
      User.create(email: email, password: password, role_ids: [Role.where(name: 'admin').first.id])
      STDOUT.puts "#{email} has been set up as admin user."
    else
      STDOUT.puts 'You already have an account in our system.'
    end
  end
  
end
