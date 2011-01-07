module ActiveScaffold::Config
  class Sortable < Base
    def initialize(core_config)
      @options = {}
      @core = core_config
      
      self.column = core_config.model.new.position_column if @core.model.instance_methods.include? 'acts_as_list_class'
      self.column = core_config.model.new.left_column_name if @core.model.instance_methods.include? 'nested_set_scope'
      if self.column.nil?
        raise "ActiveScaffoldSortable: Missing sortable attribute '#{core_config.model.new.position_column}' in model '#{core_config.model.to_s}'" if @core.model.instance_methods.include? 'acts_as_list_class'
        raise "ActiveScaffoldSortable: Missing sortable attribute '#{core_config.model.new.left_column_name}' in model '#{core_config.model.to_s}'" if @core.model.instance_methods.include? 'nested_set_scope'
      end

    end

    self.crud_type = :update
    
    attr_reader :column
    def column=(column_name)
      @column = @core.columns[column_name]
      Rails.logger.error("ActiveScaffold Sortable: postion column: #{column_name} not found in model") if @column.nil?
      @column
    end
    
    attr_accessor :options
  end
end