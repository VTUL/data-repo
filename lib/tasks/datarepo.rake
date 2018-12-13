require 'net/ldap'

namespace :datarepo do
  desc 'Create test data'
  task test_data: :environment do
    me = User.find_by(email: "whunter@vt.edu")
    for i in 1..10 do
      c = Collection.new
      c.title = "dataset #{i}"
      c.apply_depositor_metadata(me.user_key)

      for n in 1..10 do
        gf = GenericFile.new
        gf.title << "File #{n} in Collection #{i}"
        gf.tag << "Item"
        gf.creator << me.email
        gf.rights = ['Attribution 3.0 United States']
        gf.resource_type << "Generic File"
        gf.filename = ["file_#{n}.txt"]
        gf.label = "file_#{n}"
        gf.apply_depositor_metadata me 
        gf.save
        c.members << gf
      end
      c.save
    end
  end

  desc 'Create default roles.'
  task add_roles: :environment do
    ['admin', 'collection_admin', 'collection_user'].each do |role_name|
      Role.find_or_create_by({name: role_name})
      puts "Created role '#{role_name}'."
    end
  end

  desc 'Add initial users.'
  task  populate_users: :environment do
    ldap = Net::LDAP.new(host: 'directory.vt.edu')
    ldap.bind
    treebase = 'ou=People,dc=vt,dc=edu'
    ldap_attributes = {uid: :authid, display_name: :displayname, department: :department}
    #Address is available as :postaladdress as well.

    IO.foreach('user_list.txt') do |email|
      email = email.strip
      filter = Net::LDAP::Filter.eq('mail', email)
      results = ldap.search(base: treebase, filter: filter)
      if results.count == 1
        user = User.find_or_initialize_by({email: email})
        user.provider = 'cas'
        user.uid = email.split('@')[0]

        result = results[0]
        ldap_attributes.each do |user_attr, ldap_attr|
          user_attr = user_attr.to_sym
          if result.respond_to?(ldap_attr)
            user[user_attr] = result[ldap_attr][0].force_encoding('UTF-8')
          end
        end

        new_user = user.id.nil?
        user.save!
        if new_user
          puts "Created '#{email}'."
        else
          puts "Updated '#{email}'."
        end
      elsif results.count > 1
        puts "Searching for '#{email}' did not return a unique result."
      else
        puts "Searching for '#{email}' did not return any results."
      end
    end
  end

  desc 'Upgrade users to admins.'
  task upgrade_users: :environment do
    admin_role = Role.find_by({name: 'admin'})

    IO.foreach('admin_list.txt') do |email|
      email = email.strip
      user = User.find_by({email: email})

      if user.nil?
        user = User.new(email: email, uid: email.split('@')[0], provider: 'cas')
      end

      user.roles << admin_role
      user.roles = user.roles.uniq
      user.group_list = 'admin'
      user.save!
      puts "#{email} upgraded."
    end
  end

  desc 'Update carousel images from zip.'
  task :update_images, [:image_zip] => :environment do |task, args|
    image_zip_path = args.with_defaults(image_zip: nil)[:image_zip]
    FileUtils.mkdir_p(Rails.root.join('app/assets/images/carousel/'))
    images = Dir.glob(Rails.root.join('app/assets/images/carousel/*.[Jj][Pp][Gg]'))
    unless images.empty?
      images.each do |image|
        puts "Deleting #{image}"
      end
      FileUtils.rm(images)
    end
    unless image_zip_path.nil?
      system("unzip -jd #{Rails.root.join('app/assets/images/carousel/')} #{image_zip_path}")
    end
  end
end
