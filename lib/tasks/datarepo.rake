namespace :datarepo do 

  desc 'Setup Admin Role'
  task setup_admin: :environment do
    if Role.where(name: 'admin').first.nil?
      Role.create(name: 'admin')
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
