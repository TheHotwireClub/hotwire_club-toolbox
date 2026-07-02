module HotwireClub
  module Toolbox
    class Engine < ::Rails::Engine
      # Make the engine's view helpers available in the host app's views.
      # (The engine intentionally does not isolate its namespace.)
      initializer "hotwire_club.toolbox.helpers" do
        ActiveSupport.on_load(:action_view) do
          include HotwireClub::Toolbox::OptimisticFormHelper
        end
      end

      # Serve the engine's JavaScript through the asset pipeline (Propshaft).
      initializer "hotwire_club.toolbox.assets" do |app|
        if app.config.respond_to?(:assets)
          app.config.assets.paths << root.join("app/javascript")
        end
      end

      # Contribute the engine's importmap pins to host apps using importmap-rails.
      initializer "hotwire_club.toolbox.importmap", before: "importmap" do |app|
        if app.config.respond_to?(:importmap)
          app.config.importmap.paths << root.join("config/importmap.rb")
          app.config.importmap.cache_sweepers << root.join("app/javascript")
        end
      end
    end
  end
end
