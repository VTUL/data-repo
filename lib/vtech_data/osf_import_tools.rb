class OsfImportTools
  require 'fileutils'
  require 'vtech_data/zip_file_generator'

  def initialize(oauth_token, user)
    @token = oauth_token
    @current_user = user
  end

  def get_user_projects
    begin
      me_obj = osf_get_object('https://api.osf.io/v2/users/me/')
      nodes_link = me_obj['data']['relationships']['nodes']['links']['related']['href']
      nodes_obj = osf_get_object(nodes_link)
      ret_val = nodes_obj['data'].map{ | project |
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
    rescue
      ret_val = { errors: true } 
    end
    return ret_val
  end

  def import_project project_id
    node_obj = osf_get_object(node_url_from_id(project_id))
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
      Rails.logger.error("Error fetching project license details. Is license present on project?")
    end

    begin
      external_link = File.join(node_obj['data']['links']['html'], 'addons', 'forward')
      external = osf_get_object(external_link)
    rescue
      Rails.logger.error("Error fetching external link. Probably doesn't exist for this project")
    end

    item = GenericFile.new
    item.title << node_obj['data']['attributes']['title']
    item.tag = node_obj['data']['attributes']['tags'].empty? ? ['OSF'] : node_obj['data']['attributes']['tags']
    item.creator << @current_user.email
    item.rights = [license_obj['data']['attributes']['name']] rescue ['Attribution 3.0 United States']
    item.resource_type << 'Other data'
    item.related_url << node_obj['data']['links']['html']
    item.filename = [project_name + '.zip']
    item.label = project_name + '.zip'
    item.apply_depositor_metadata @current_user

    item.save

    ingest_job = IngestLocalFileJob.new(item.id, tmp_path, project_name + '.zip', @current_user.user_key)
    ingest_job.run

    item.characterize

    collection = Collection.new
    collection.title = node_obj['data']['attributes']['title']
    collection.description = node_obj['data']['attributes']['description']
    collection.tag = node_obj['data']['attributes']['tags']
    collection.date_created = [node_obj['data']['attributes']['date_created']]
    collection.date_modified = node_obj['data']['attributes']['date_modified']
    collection.related_url << node_obj['data']['links']['html']
    collection.related_url << external['data']['attributes']['url'] if (!external.nil? && !external[:errors])
    collection.rights = [license_obj['data']['attributes']['name']] rescue []
    
    collection.apply_depositor_metadata(@current_user.user_key)
    collection.members << item
    collection.save

    if(!item.id.nil? && !collection.id.nil?)
      success = true      
    else
      success = false
    end
    OsfNotificationMailer.notification_email(success, collection.id, @current_user).deliver_later
  end

  def walk_nodes node_obj, project_name, current_path
    make_dir current_path

    make_node_metadata_file node_obj, current_path

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

  def make_node_metadata_file node_obj, path
    metadata_obj = Hash.new
    node_obj['data']['relationships'].keys
    metadata_obj['attributes'] = node_obj['data']['attributes']
    relationships = Hash.new

    citation_link = node_obj['data']['relationships']['citation']['links']['related']['href']
    relationships['citation'] = osf_get_object(citation_link)

    license_link = node_obj['data']['relationships']['license']['links']['related']['href']
    license = osf_get_object(license_link)
    relationships['license'] = license['data']['attributes']

    contributors_link = node_obj['data']['relationships']['contributors']['links']['related']['href']
    contributors = osf_get_object(contributors_link)
    relationships['contributors'] = Array.new
    contributors['data'].each do |data|
        relationships['contributors'] << data['embeds']['users']
    end
    
    metadata_obj['relationships'] = relationships
    xml_name = File.join(path, "#{node_obj['data']['id']}.xml")
    File.open(xml_name, 'wb'){ |file| file.write(metadata_obj.to_xml) }
    
    wikis_link = node_obj['data']['relationships']['wikis']['links']['related']['href']
    wikis = osf_get_object(wikis_link)
    if wikis['data'].length > 0
      wikis['data'].each do |data|
        link = data['links']['download']
        name = File.join(path, "#{data['attributes']['name']}.md")
        wiki_content = osf_get(link)
        File.open(name, 'wb'){ |file|file.write(wiki_content.body) } if !wiki_content.body.empty?
      end
    end
  end

  def make_dir path
    begin
      FileUtils.mkdir(path)
    rescue
      puts "Error creating directory. Maybe it already exists"
    end
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
    File.open(File.join(path, file_obj['attributes']['name']),"w") { |new_file| new_file.write(file.body.force_encoding('UTF-8')) }
  end

  def get_children node_obj
    children_link = node_obj['data']['relationships']['children']['links']['related']['href']
    children_obj = osf_get_object(children_link)
    children_obj['data'].map{ | child | child['links']['self'] }
  end

  def zip_project tmp, path, name
    archive = File.join(tmp,name)+'.zip'
    FileUtils.rm archive, :force=>true
    zf = ZipFileGenerator.new(path, archive)
    zf.write
    return archive
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




  def get_project_details proj_url
    proj_obj = osf_get_object(proj_url)
    project = proj_obj['data']
    contributors_link = project['relationships']['contributors']['links']['related']['href']
    contributors_obj = osf_get_object(contributors_link)
    project['contributors'] = contributors_obj['data'].map{| contributor | {
        'name' => contributor['embeds']['users']['data']['attributes']['full_name'],
        'creator' => contributor['attributes']['index'] == 0 ? true : false
      }}
    return project
  end

  def osf_get_object url
    response = osf_get url
    begin
    ret_val = JSON.parse(response.body)
    rescue
      ret_val = {errors: true}
      Rails.logger.warn "error parsing response"
    end
    return ret_val
  end

  def osf_get url
    begin
      response = @token.get(url)
    rescue
      puts "it broke"
    end
    response rescue nil
  end


  def node_url_from_id node_id
    File.join(Rails.application.config.osf_api_base_url, "nodes", node_id, "/")  
  end

end
