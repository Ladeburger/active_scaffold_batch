module ActiveScaffoldBatch
  class Engine < ::Rails::Engine
    initializer("initialize_active_scaffold_batch", :after => "initialize_active_scaffold") do
      ActiveSupport.on_load(:action_controller) do
        require "active_scaffold_batch/config/core.rb"
      end

      ActiveSupport.on_load(:action_view) do
        begin
          include ActiveScaffold::Helpers::UpdateColumnHelpers
          if ActiveScaffold.js_framework == :jquery
            include ActiveScaffold::Helpers::DatepickerUpdateColumnHelpers
          elsif ActiveScaffold.js_framework == :prototype
            include ActiveScaffold::Helpers::CalendarDateSelectUpdateColumnHelpers if defined? CalendarDateSelect
          end
          include ActiveScaffold::Helpers::BatchCreateColumnHelpers
        rescue
          raise $! unless Rails.env == 'production'
        end
      end
    end
  end
end
