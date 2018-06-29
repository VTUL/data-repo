class CollectionsController < ApplicationController
  include Hydra::Catalog
  include Sufia::CollectionsControllerBehavior
  require 'vtech_data/download_generator'

  skip_load_and_authorize_resource :only => [:datacite_search, :crossref_search, :import_metadata, :ldap_search, :add_files, :dataset_download]

  def presenter_class
    MyCollectionPresenter
  end

  def form_class
    MyCollectionEditForm
  end

  def show
    super
    max_dataset_for_export = 3 * 1024 * 1024 * 1024
    @dataset_size = 0
    @can_export = true
    if @collection.members.respond_to?('each')
      @collection.members.each do |gf|
        if gf.file_size.blank?
          @can_export = false
          break
        end
        file_size = gf.file_size.first.to_i
        @dataset_size += file_size
      end
    end
    @can_export = (@can_export && @dataset_size < max_dataset_for_export)
  end

  def after_create
      respond_to do |format|
        ActiveFedora::SolrService.instance.conn.commit
        format.html { redirect_to collections.collection_path(@collection), notice: 'Dataset was successfully created.' }
        format.json { render json: @collection, status: :created, location: @collection }
      end
  end

  def create
    @collection.apply_depositor_metadata(current_user.user_key)
    add_members_to_collection unless batch.empty?

    if !params[:collection][:funder].nil? && !params[:collection][:funder].empty?
      params[:collection][:funder].each do |funder|
        if funder.length > 0
          values = funder.split(":")
          @collection[:funder] << "<funder><fundername>#{values[0]}</fundername><awardnumber>#{values[1]}</awardnumber></funder>"
        end
      end
    end

    if params[:request_doi]
      @collection[:identifier] << t('doi.pending_doi')
    end

    if @collection.save
      if params[:request_doi]
        doi_request = DoiRequest.new(asset_id: @collection.id)
        if doi_request.save
          flash[:notice] = t('doi.messages.submit.success')
        else
          flash[:error] = t('doi.messages.submit.failure')
        end
      end

      after_create
    else
      after_create_error
    end
  end

  def update
    process_member_changes
    if @collection.update(collection_params.except(:members))
      newfunder = []
      if !params[:collection][:funder].nil? && !params[:collection][:funder].empty?
        params[:collection][:funder].each do |funder|
          if funder.length > 0
            values = funder.split(":")
            newfunder << "<funder><fundername>#{values[0]}</fundername><awardnumber>#{values[1]}</awardnumber></funder>"
          end
        end
      end
      @collection.update_attributes({:funder => newfunder})
      @collection[:identifier].each do |id|
        # Matches DOIs minted by VT Libraries
        if /\A#{Ezid::Client.config.default_shoulder}/ =~ id
          ezid_doi = Ezid::Identifier.find(id)
          if ezid_doi
            ezid_doi.update_metadata(
              datacite_creator: (@collection.creator.empty? ? "" : @collection.creator.first),
              datacite_title: @collection.title,
              datacite_publisher: (@collection.publisher.empty? ? "" : @collection.publisher.first),
              datacite_publicationyear: (@collection.date_created.empty? ? "" : @collection.date_created.first)
            )
          end
          if ezid_doi.save
            flash[:notice] = t('doi.messages.modify.success')
          else
            flash[:error] = t('doi.messages.modify.failure')
          end
          break
        end
      end
      after_update
    else
      after_update_error
    end
  end

  def datacite_search
    uri = URI('http://search.datacite.org/api?')
    uri.query = URI.encode_www_form(params)
    res = Net::HTTP.get(uri)
    parsed = JSON.parse(res)
    if parsed["responseHeader"]["status"] != 0
      @datacite_error = "Datacite server problem. You can fill in on your own."
      render :action => 'datacite_search_error'
    elsif parsed["response"]["numFound"] == 0
      @datacite_error = "No metadata found! You can fill in on your own."
      render :action => 'datacite_search_error'
    else
      @results = parsed["response"]["docs"]
    end
  end

  def crossref_search
    @results = JSON.parse(params[:results])
  end

  def import_metadata
    @result = params[:result].gsub('=>', ':')
  end

  def ldap_search
    ldap = Net::LDAP.new(host: 'directory.vt.edu')
    ldap.bind
    treebase = 'ou=People,dc=vt,dc=edu'
    ldap_attributes = {uid: :authid, display_name: :displayname, department: :department, address: :postaladdress}
    name = params[:name].gsub(/\s/,'*')
    filter = Net::LDAP::Filter.eq("cn", "*#{name}*")
    @results = ldap.search(base: treebase, filter: filter)
    @radio_name = params[:label]
    render :layout => false
  end

  def add_files
    if current_user.admin?
      self.search_params_logic += [:show_only_generic_files, :add_access_controls_to_solr_params]
    else
      self.search_params_logic += [:show_only_generic_files, :show_only_resources_deposited_by_current_user]
    end
    (@response, @files) = search_results({ q: '', rows: 10000 }, search_params_logic)
    @collection = Collection.find(params[:id])
    authorize! :edit, @collection
  end

  def dataset_download
    time_stamp = DateTime.now.strftime('%Q')
    download_generator = DownloadGenerator.new(time_stamp)
    download_generator.make_archive
    admin_download = (!params[:admin].blank? && params[:admin] == "admin")
    download_generator.generate_dataset_download(params[:id], admin_download)
    zip_file = download_generator.zip
    while !File.file? zip_file
      sleep(0.1)
    end
    send_file zip_file
  end
end
