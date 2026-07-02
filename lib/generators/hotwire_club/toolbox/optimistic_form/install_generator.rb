require "rails/generators/base"

module HotwireClub
  module Toolbox
    module OptimisticForm
      # Wires the optimistic-form Stimulus controller into the host app,
      # adapting to its JavaScript setup (importmap, jsbundling/esbuild/bun, or
      # vite), and ensures the Turbo morph refresh meta tags are present.
      #
      #   bin/rails generate hotwire_club:toolbox:optimistic_form:install
      class InstallGenerator < Rails::Generators::Base
        CONTROLLER_MODULE = "hotwire_club/toolbox/optimistic_form_controller".freeze
        CONTROLLERS_INDEX = "app/javascript/controllers/index.js".freeze
        LAYOUT = "app/views/layouts/application.html.erb".freeze

        MORPH_META = <<~HTML
          <meta name="turbo-refresh-method" content="morph">
          <meta name="turbo-refresh-scroll" content="preserve">
        HTML

        def wire_javascript
          if importmap?
            register_for_importmap
          elsif bundler?
            register_for_bundler
          else
            say_unknown_js_setup
          end
        end

        def ensure_morph_meta_tags
          unless File.exist?(layout_path)
            say "Could not find #{LAYOUT}; add the Turbo morph refresh meta tags to your layout <head>:", :yellow
            say MORPH_META
            return
          end

          if File.read(layout_path).include?("turbo-refresh-method")
            say_status :identical, "morph refresh meta tags", :blue
          else
            inject_into_file layout_path, indent(MORPH_META), after: /<head>\n/
          end
        end

        def print_server_contract
          say ""
          say "Optimistic Form installed. Remember the server contract:", :green
          say "  • Success  -> head :no_content (204), or a targeted turbo_stream. Do not redirect."
          say "  • Failure  -> 4xx/422 so the client reconciles."
          say "See docs/optimistic-form.md for details."
        end

        private

        def importmap?
          File.exist?(File.join(destination_root, "config/importmap.rb"))
        end

        def bundler?
          gem_in_bundle?("jsbundling-rails") || gem_in_bundle?("vite_rails") ||
            File.exist?(File.join(destination_root, "package.json"))
        end

        def register_for_importmap
          register_controller(import: %(import OptimisticFormController from "#{CONTROLLER_MODULE}"))
        end

        def register_for_bundler
          copy_controller_sources
          register_controller(import: %(import OptimisticFormController from "./optimistic_form_controller"))
        end

        # Copy the controller + timing helpers into the host tree, rewriting the
        # bare-specifier import to a relative one bundlers can resolve.
        def copy_controller_sources
          controller = engine_js("optimistic_form_controller.js")
            .sub(%r{from "hotwire_club/toolbox/helpers/timing_helpers"}, %(from "../helpers/timing_helpers"))

          create_file "app/javascript/controllers/optimistic_form_controller.js", controller
          create_file "app/javascript/helpers/timing_helpers.js", engine_js("helpers/timing_helpers.js")
        end

        def register_controller(import:)
          registration = <<~JS
            #{import}
            application.register("optimistic-form", OptimisticFormController)
          JS

          index = File.join(destination_root, CONTROLLERS_INDEX)
          if File.exist?(index)
            if File.read(index).include?("optimistic-form")
              say_status :identical, "optimistic-form registration", :blue
            else
              append_to_file index, "\n#{registration}"
            end
          else
            say "Could not find #{CONTROLLERS_INDEX}; register the controller yourself:", :yellow
            say registration
          end
        end

        def say_unknown_js_setup
          say "Could not detect your JavaScript setup (importmap / jsbundling / vite).", :yellow
          say "Import and register the controller manually, e.g.:", :yellow
          say %(  import OptimisticFormController from "#{CONTROLLER_MODULE}")
          say %(  application.register("optimistic-form", OptimisticFormController))
        end

        def gem_in_bundle?(name)
          Gem.loaded_specs.key?(name)
        end

        def engine_js(relative_path)
          File.read(HotwireClub::Toolbox::Engine.root.join("app/javascript/hotwire_club/toolbox", relative_path))
        end

        def layout_path
          File.join(destination_root, LAYOUT)
        end

        def indent(text)
          text.gsub(/^/, "    ")
        end
      end
    end
  end
end
