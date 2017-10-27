class OsfAPIController < OsfAuthController
  require 'fileutils'
  require 'vtech_data/zip_file_generator'

  helper_method :detail_route
  before_action :check_logged_in, only: [:list, :detail]
  before_action :get_oauth_token

  def list
    me_obj = osf_get_object('https://api.osf.io/v2/users/me/')
    nodes_link = me_obj['data']['relationships']['nodes']['links']['related']['href']
    nodes_obj = osf_get_object(nodes_link)
    @projects = nodes_obj['data'].map{ | project |
      if project['attributes']['category'] == 'project'
        contributors_link = project['relationships']['contributors']['links']['related']['href']
        contributors_obj = osf_get_object(contributors_link)
      	{ 
          'id' => project['id'], 
          'links' => project['links'], 
          'attributes' => project['attributes'], 
          'contributors' => contributors_obj['data'].map{| contributor | {
            'name' => contributor['embeds']['users']['data']['attributes']['full_name'],
            'creator' => contributor['attributes']['index'] == 0 ? true : false
          }}
        }
      else
        nil
      end
    }
  end

  def detail
    node_obj = osf_get_object(node_url_from_id(params["project_id"]))
    project_name = node_obj['data']['attributes']['title'].downcase.gsub(" ", "_")

    tmp_path = File.join(Rails.root.to_s, 'tmp')
    root_path = File.join(tmp_path, project_name)

    walk_nodes node_obj, project_name, root_path   
    archive_full_path = zip_project tmp_path, root_path, project_name
    remove_tmp_files project_name

    begin
      license_link = node_obj['data']['relationships']['license']['links']['related']['href']
      license_obj = osf_get_object(license_link)
    rescue
      logger.error("Error fetching project license details. Is license present on project?")
    end

    begin
      external_link = File.join(node_obj['data']['links']['html'], 'addons', 'forward')
      external = osf_get_object(external_link)
    rescue
      logger.error("Error fetching external link. Probably doesn't exist for this project")
    end

    item = GenericFile.new
    item.title << node_obj['data']['attributes']['title']
    item.tag = node_obj['data']['attributes']['tags'].empty? ? ['OSF'] : node_obj['data']['attributes']['tags']
    item.creator << current_user.email
    item.rights = [license_obj['data']['attributes']['name']] rescue ['Attribution 3.0 United States']
    item.resource_type << 'Other data'
    item.related_url << node_obj['data']['links']['html']
    item.filename = [project_name + '.zip']
    item.label = project_name + '.zip'
    item.apply_depositor_metadata current_user

    file_obj = f = File.open(archive_full_path , 'r')

#    characterization_xml = Hydra::FileCharacterization.characterize(file_obj, project_name + ".zip", :fits) do |config|
#                             config[:fits] = Hydra::Derivatives.fits_path
#                           end

#    characterization_obj = Nokogiri::XML.parse(characterization_xml).root
#    raise characterization_obj.inspect

    item.content.content = file_obj
    item.mime_type = 'application/zip'
    item.save

    actor = Sufia::GenericFile::Actor.new(item, current_user)
    actor.push_characterize_job

    collection = Collection.new
    collection.title = node_obj['data']['attributes']['title']
    collection.description = node_obj['data']['attributes']['description']
    collection.tag = node_obj['data']['attributes']['tags']
    collection.date_created = [node_obj['data']['attributes']['date_created']]
    collection.date_modified = node_obj['data']['attributes']['date_modified']
    collection.related_url << node_obj['data']['links']['html']
    collection.related_url << external['data']['attributes']['url'] if !external.nil?
    collection.rights = [license_obj['data']['attributes']['name']] rescue []
    
    collection.apply_depositor_metadata(current_user.user_key)
    collection.members << item
    collection.save


  end

  def walk_nodes node_obj, project_name, current_path
    make_dir current_path

    files_link = node_obj['data']['relationships']['files']['links']['related']['href']
    files_obj = osf_get_object(files_link)
    files_obj['data'].each do | source |
      source_name = source['attributes']['name']
      source_path = File.join(current_path, source_name)
      import source['relationships']['files']['links']['related']['href'], source_path
    end
    
    children_array = get_children node_obj
    if children_array.respond_to?('each')
      children_array.each do | child_link |
        child_obj = osf_get_object(child_link)
        child_name = child_obj['data']['attributes']['title'].downcase.gsub(" ", "_")
        child_path = File.join(current_path, child_name)
        walk_nodes child_obj, project_name, child_path
      end
    end
  end

  def get_children node_obj
    children_link = node_obj['data']['relationships']['children']['links']['related']['href']
    children_obj = osf_get_object(children_link)
    children_obj['data'].map{ | child | child['links']['self'] }
  end

  def remove_tmp_files dir_name
    upload_dir = File.join(Rails.root.to_s, 'tmp')
    archive_name = File.join(upload_dir, "#{dir_name}.zip")
    while !File.file? archive_name do
      sleep 0.01
    end
    if File.file? archive_name
      tmp_dir = File.join(upload_dir, dir_name)
      FileUtils.rm_rf(tmp_dir)
    end
  end

  def zip_project tmp, path, name
    archive = File.join(tmp,name)+'.zip'
    FileUtils.rm archive, :force=>true
    zf = ZipFileGenerator.new(path, archive)
    zf.write
    return archive
  end

  def detail_route project_id
    "/osf_api/detail/#{project_id}"
  end

  def get_oauth_token
    @oauth_token = oauth_token
  end

  def node_url_from_id node_id
    File.join(Rails.application.config.osf_api_base_url, "nodes", node_id, "/")  
  end

  def import directory_object, path
    files_obj = osf_get_object(directory_object)
    if files_obj['links']['meta']['total'] > 0
      make_dir path
    
      files_obj['data'].each do | node |
        kind = node['attributes']['kind']
        if kind == 'file'
          get_file node, directory_object, path
        elsif kind == 'folder'
          sub_directory = node['relationships']['files']['links']['related']['href']
          sub_path = File.join(path, node['attributes']['name'])
          make_dir sub_path
          import sub_directory, sub_path
        end
      end

    end
  end

  def get_file file_obj, directory, path
    file = osf_get(file_obj['links']['download'])
#    File.open(File.join(path, file_obj['attributes']['name']), 'w:ASCII-8BIT') { |new_file| new_file.write(file.body) }
    File.open(File.join(path, file_obj['attributes']['name']),"w") { |new_file| new_file.write(file.body.force_encoding('UTF-8')) }
  end

  def make_dir path
    begin
      FileUtils.mkdir(path)
    rescue
      puts "Error creating directory. Maybe it already exists"
    end
  end

  def osf_get url
    begin
      response = @oauth_token.get(url)
    rescue
      puts "it broke"
    end
    response rescue nil
  end

  def osf_get_object url
    response = osf_get url
    JSON.parse(response.body)
  end

  def check_logged_in
    redirect_to oauth_auth_url unless session['oauth_token']
  end

end
