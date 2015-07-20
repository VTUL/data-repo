task :with_defaults, [:email, :password] do |t, defaults|
  defaults.with_defaults(:email => :default_email, :password => :default_password)
end

namespace :datarepo do 

  desc 'Setup default roles and admin'
  task setup_defaults: :environment do
    desc 'Setup Roles'
    %w(admin collection_admin collection_user).each do |role|
      Role.find_or_create_by(name: role)
    end

    desc 'Set up a default Admin email and password'
    default_email = "admin@lib.vt.edu"
    default_password = "datarepo_password" 
    Rake::Task[:with_defaults].invoke(default_email, default_password)
    if User.find_by_email(default_email).nil?
      User.create(email: default_email, password: default_password, role_ids: [Role.where(name: 'admin').first.id])
      puts "Default admin email is: #{default_email}; password is: #{default_password}. Please change the password."
    else
      puts "Default admin email is: #{default_email}"
    end
  end
  
end

