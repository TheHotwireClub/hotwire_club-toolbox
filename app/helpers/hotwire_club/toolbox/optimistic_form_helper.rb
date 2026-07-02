module HotwireClub
  module Toolbox
    # View helpers that wrap `form_with` / `form_for` with the optimistic-UI
    # form builder and Stimulus wiring.
    #
    #   optimistic_form_for photo, attribute_name: :favorite, value: !photo.favorite do |form|
    #     form.optimistic_template dom_id(photo, "favorite-button"), favorite_button_icon(!photo.favorite)
    #     form.button { favorite_button_icon(photo.favorite) }
    #   end
    #
    # Pass +attribute_name:+/+value:+ to have a hidden field injected
    # automatically, or call +form.optimistic_hidden_field+ yourself to place it.
    module OptimisticFormHelper
      def optimistic_form_with(attribute_name: nil, value: OptimisticFormBuilder::UNSET, **options, &block)
        options[:builder] = OptimisticFormBuilder
        enrich_form_with_optimistic_options(options)

        form_with(**options) do |form|
          optimistic_form_body(form, attribute_name, value, &block)
        end
      end

      def optimistic_form_for(record, attribute_name: nil, value: OptimisticFormBuilder::UNSET, **options, &block)
        options[:builder] = OptimisticFormBuilder
        enrich_form_with_optimistic_options(options)

        form_for(record, **options) do |form|
          optimistic_form_body(form, attribute_name, value, &block)
        end
      end

      private

      # Capture the block first so an explicit `form.optimistic_hidden_field`
      # call inside it wins; only auto-inject when the caller supplied
      # attribute_name/value and didn't render the field themselves.
      def optimistic_form_body(form, attribute_name, value, &block)
        body = capture(form, &block)

        prefix = if auto_inject_hidden_field?(form, attribute_name, value)
          form.optimistic_hidden_field(attribute_name, value: value)
        end

        safe_join([ prefix, body ].compact)
      end

      def auto_inject_hidden_field?(form, attribute_name, value)
        attribute_name.present? &&
          !value.nil? &&
          !OptimisticFormBuilder::UNSET.equal?(value) &&
          !form.optimistic_hidden_field_rendered?
      end

      def enrich_form_with_optimistic_options(options)
        options[:html] ||= {}
        options[:html][:data] ||= {}

        options[:html][:data][:controller] =
          [ options[:html][:data][:controller], "optimistic-form" ].compact.join(" ")
        options[:html][:data][:action] =
          [ options[:html][:data][:action], "turbo:submit-start->optimistic-form#apply turbo:submit-end->optimistic-form#refresh" ].compact.join(" ")
      end
    end
  end
end
