require "test_helper"
require "rails/generators/test_case"
require "generators/hotwire_club/toolbox/optimistic_form/install_generator"

module HotwireClub
  module Toolbox
    module OptimisticForm
      class InstallGeneratorTest < Rails::Generators::TestCase
        tests InstallGenerator
        destination File.expand_path("../../../../../tmp/generator", __dir__)
        setup :prepare_destination

        test "importmap: registers the controller and adds morph meta tags" do
          create_file "config/importmap.rb", ""
          create_file "app/javascript/controllers/index.js", "// controllers\n"
          create_layout

          run_generator

          assert_file "app/javascript/controllers/index.js" do |content|
            assert_match %r{import OptimisticFormController from "hotwire_club/toolbox/optimistic_form_controller"}, content
            assert_match %r{application.register\("optimistic-form", OptimisticFormController\)}, content
          end
          assert_file "app/views/layouts/application.html.erb" do |content|
            assert_match %r{turbo-refresh-method.*morph}, content
          end
          # importmap path must not copy JS into the host tree
          assert_no_file "app/javascript/controllers/optimistic_form_controller.js"
        end

        test "bundler: copies sources with a relative import and registers" do
          create_file "package.json", "{}\n"
          create_file "app/javascript/controllers/index.js", "// controllers\n"
          create_layout

          run_generator

          assert_file "app/javascript/controllers/optimistic_form_controller.js" do |content|
            assert_match %r{from "../helpers/timing_helpers"}, content
          end
          assert_file "app/javascript/helpers/timing_helpers.js"
          assert_file "app/javascript/controllers/index.js" do |content|
            assert_match %r{import OptimisticFormController from "./optimistic_form_controller"}, content
          end
        end

        test "is idempotent for registration" do
          create_file "config/importmap.rb", ""
          create_file "app/javascript/controllers/index.js", "// controllers\n"

          run_generator
          run_generator

          assert_file "app/javascript/controllers/index.js" do |content|
            assert_equal 1, content.scan("optimistic-form").size
          end
        end

        private

        def create_file(path, contents)
          full = File.join(destination_root, path)
          FileUtils.mkdir_p(File.dirname(full))
          File.write(full, contents)
        end

        def create_layout
          create_file "app/views/layouts/application.html.erb", "<html>\n  <head>\n  </head>\n  <body></body>\n</html>\n"
        end
      end
    end
  end
end
