require "test_helper"
require "open3"

module HotwireClub
  module Toolbox
    # In its own process: the suite's app is already initialized, and the case
    # is an app whose gems load ActionView::Base before initialization (as
    # prawn-rails does), so the engine's on_load(:action_view) hook runs at once.
    class EngineBootTest < ActiveSupport::TestCase
      test "boots when ActionView is loaded before the app initializes" do
        script = <<~RUBY
          require #{File.expand_path("../../dummy/config/application", __dir__).dump}
          ActionView::Base
          Rails.application.initialize!
          print ActionView::Base.include?(HotwireClub::Toolbox::OptimisticFormHelper)
        RUBY

        output, status = Open3.capture2e({ "RAILS_ENV" => "test" }, RbConfig.ruby, "-e", script)

        assert status.success?, output
        assert_equal "true", output.lines.last
      end
    end
  end
end
