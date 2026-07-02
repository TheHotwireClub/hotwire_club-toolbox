module HotwireClub
  module Toolbox
    # Form builder that renders the optimistic-UI scaffolding: a hidden
    # <template> holding the turbo-stream(s) the Stimulus controller paints on
    # submit, and (optionally) a hidden field carrying the value being toggled.
    class OptimisticFormBuilder < ActionView::Helpers::FormBuilder
      # Sentinel so an explicit `value: false` is preserved while "not given"
      # can still be distinguished from a real nil/false value.
      UNSET = Object.new

      # Wraps the optimistic markup in a <template> the Stimulus controller
      # clones into the DOM on `turbo:submit-start`.
      #
      #   form.optimistic_template "cart-count", @count + 1
      #   form.optimistic_template { turbo_stream.update("cart-count") { ... } }
      #
      # Positional form builds a `turbo_stream.update` for you; block form lets
      # you author the stream(s) yourself and ignores +target+/+template+.
      def optimistic_template(target = nil, template = nil, &block)
        content = if block
          @template.capture(&block)
        else
          @template.turbo_stream_action_tag(:update, target: target, template: template)
        end

        @template.content_tag("template", data: { optimistic_form_target: "template" }) do
          content
        end
      end

      # Explicit hidden field for the value being submitted. Calling this marks
      # the field as rendered so the helper skips its automatic injection.
      #
      #   form.optimistic_hidden_field :favorite, value: !photo.favorite
      def optimistic_hidden_field(attribute_name, value: UNSET)
        @optimistic_hidden_field_rendered = true
        hidden_field(attribute_name, value: UNSET.equal?(value) ? nil : value)
      end

      def optimistic_hidden_field_rendered?
        !!@optimistic_hidden_field_rendered
      end
    end
  end
end
