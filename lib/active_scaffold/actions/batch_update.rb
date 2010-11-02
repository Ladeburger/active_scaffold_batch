module ActiveScaffold::Actions
  module BatchUpdate
    def self.included(base)
      base.before_filter :batch_update_authorized_filter, :only => [:batch_edit, :batch_update]
      base.verify :method => [:post, :put],
                  :only => :batch_update,
                  :redirect_to => { :action => :index }
      base.add_active_scaffold_path File.join(Rails.root, 'vendor', 'plugins', ActiveScaffold::Config::BatchUpdate.plugin_directory, 'frontends', 'default' , 'views')
    end

    def batch_edit
      do_batch_edit
      respond_to_action(:batch_edit)
    end

    def batch_update
      selected_columns = params[:batch_update]
      if !selected_columns.nil? && selected_columns.is_a?(Array)
        #selected_columns.collect!{|col_name| col_name.to_sym}
        do_batch_update(selected_columns)
      else
        @batch_successful = false
      end
      do_list if batch_successful?
      respond_to_action(:batch_update)
    end

    
    protected
    def batch_edit_respond_to_html
      if batch_successful?
        render(:action => 'batch_update')
      else
        return_to_main
      end
    end
    def batch_edit_respond_to_js
      render(:partial => 'batch_update_form')
    end
    def batch_update_respond_to_html
      if params[:iframe]=='true' # was this an iframe post ?
        responds_to_parent do
          render :action => 'on_batch_update.js', :layout => false
        end
      else # just a regular post
        if batch_successful?
          flash[:info] = as_(:updated_model, :model => @record.to_label)
          return_to_main
        else
          render(:action => 'batch_update')
        end
      end
    end
    def batch_update_respond_to_js
      render :action => 'on_batch_update'
    end
    def batch_update_respond_to_xml
      render :xml => response_object.to_xml(:only => active_scaffold_config.batch_update.columns.names), :content_type => Mime::XML, :status => response_status
    end
    def batch_update_respond_to_json
      render :text => response_object.to_json(:only => active_scaffold_config.batch_update.columns.names), :content_type => Mime::JSON, :status => response_status
    end
    def batch_update_respond_to_yaml
      render :text => Hash.from_xml(response_object.to_xml(:only => active_scaffold_config.batch_update.columns.names)).to_yaml, :content_type => Mime::YAML, :status => response_status
    end

    def do_batch_edit
      self.successful = true
      do_new
    end

    def do_batch_update(selected_columns)
      update_columns = active_scaffold_config.batch_update.columns

      template_record = active_scaffold_config.model.new
      template_record = update_record_from_params(template_record, update_columns, params[:record])
      update_attributes = template_record.attributes.slice(*selected_columns)
      
      active_scaffold_config.model.marked.each do |marked_record|
        if marked_record.authorized_for?(:crud_type => :update)
          @record = marked_record
          @record.attributes = update_attributes
          update_save
          if successful?
            @record.marked = false
          else
            @batch_successful = false
            #copy errors from record and collect them
          end
        else
          @batch_successful = false
          # some info that you are not authorized to update this record
        end
      end
    end

    def batch_successful?
      @batch_successful = true if @batch_successful.nil?
      @batch_successful
    end

    
    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def batch_update_authorized?(record = nil)
      authorized_for?(:crud_type => :update)
    end
    private
    def batch_update_authorized_filter
      link = active_scaffold_config.batch_update.link || active_scaffold_config.batch_update.class.link
      raise ActiveScaffold::ActionNotAllowed unless self.send(link.security_method)
    end
    def batch_edit_formats
      (default_formats + active_scaffold_config.formats).uniq
    end
    def batch_update_formats
      (default_formats + active_scaffold_config.formats + active_scaffold_config.batch_update.formats).uniq
    end
  end
end