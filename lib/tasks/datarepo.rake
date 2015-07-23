require 'net/ldap'

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

  desc 'Add initial users.'
  task  populate_users: :environment do
    ldap = Net::LDAP.new(host: 'directory.vt.edu')
    treebase = 'ou=People,dc=vt,dc=edu'
    ldap_attributes = {'uid': :authid, 'display_name': :displayname, 'department': :department, 'address': :postaladdress}

    IO.foreach('emails.txt') do |email|
      email = email.strip
      filter = Net::LDAP::Filter.eq('mail', email)
      results = ldap.search(base: treebase, filter: filter)
      if results.count == 1
        user = User.find_or_initialize_by({'email': email})
        user.provider = 'cas'
        user.uid = email.split('@')[0]
        user.password = Devise.friendly_token

        result = results[0]
        ldap_attributes.each do |user_attr, ldap_attr|
          user_attr = user_attr.to_sym
          if result.respond_to?(ldap_attr)
            user[user_attr] = result[ldap_attr][0]
          end
        end

        user.save!
        puts "Created '#{email}'"
      elsif results.count > 1
        puts "Searching for '#{email}' did not return a unique result."
      else
        puts "Searching for '#{email}' did not return any results."
      end
    end
  end
end

