class OsfImportTools
  require 'fileutils'
  require 'vtech_data/zip_file_generator'

  def initialize(oauth_token)
    @token = oauth_token
  end

  def get_user_projects
#    begin
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
#    rescue
#      ret_val = { errors: true } 
#    end
    return ret_val
  end




  def osf_get_object url
    response = osf_get url
    ret_val = nil
    begin
      ret_val = JSON.parse(response.body)
    rescue
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


end
