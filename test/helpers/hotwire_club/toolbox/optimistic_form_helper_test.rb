require "test_helper"

module HotwireClub
  module Toolbox
    class OptimisticFormHelperTest < ActionView::TestCase
      # Real controllers get turbo-rails' view helpers via `helper Turbo::Engine.helpers`;
      # the bare ActionView::TestCase view does not, so include it explicitly.
      include Turbo::StreamsHelper

      # --- form wiring -------------------------------------------------------

      test "adds the optimistic-form controller and submit actions" do
        form = fragment(optimistic_form_with(url: "/x") { |f| "" }).at_css("form")

        assert_includes form["data-controller"].split, "optimistic-form"
        assert_includes form["data-action"], "turbo:submit-start->optimistic-form#apply"
        assert_includes form["data-action"], "turbo:submit-end->optimistic-form#refresh"
      end

      test "merges non-destructively with existing controller and action" do
        html = optimistic_form_with(
          url: "/x",
          html: { data: { controller: "existing", action: "click->existing#go" } }
        ) { |f| "" }
        form = fragment(html).at_css("form")

        assert_equal %w[existing optimistic-form], form["data-controller"].split
        assert_includes form["data-action"], "click->existing#go"
        assert_includes form["data-action"], "turbo:submit-start->optimistic-form#apply"
      end

      # --- optimistic_template ----------------------------------------------
      # The positional (turbo-stream) form needs a full view context and is
      # covered by test/integration/optimistic_form_rendering_test.rb.

      test "optimistic_template (block) captures the block and ignores target" do
        html = optimistic_form_with(url: "/x") do |form|
          form.optimistic_template { tag.span("hi", id: "boom") }
        end
        template = fragment(html).at_css("template[data-optimistic-form-target=template]")

        assert_not_nil template.at_css("span#boom")
        assert_nil template.at_css("turbo-stream")
      end

      # --- hidden field ------------------------------------------------------

      test "auto-injects the hidden field from attribute_name/value" do
        html = optimistic_form_with(url: "/x", attribute_name: :photo_id, value: 7) { |f| "" }

        assert_equal 1, hidden_inputs(html, "photo_id").size
        assert_equal "7", hidden_inputs(html, "photo_id").first["value"]
      end

      test "an explicit optimistic_hidden_field call suppresses the auto one" do
        html = optimistic_form_with(url: "/x", attribute_name: :photo_id, value: 7) do |form|
          form.optimistic_hidden_field(:photo_id, value: 99)
        end

        inputs = hidden_inputs(html, "photo_id")
        assert_equal 1, inputs.size
        assert_equal "99", inputs.first["value"]
      end

      test "value: false is preserved" do
        html = optimistic_form_with(url: "/x", attribute_name: :favorite, value: false) { |f| "" }

        inputs = hidden_inputs(html, "favorite")
        assert_equal 1, inputs.size
        assert_equal "false", inputs.first["value"]
      end

      test "nil value suppresses the hidden field" do
        html = optimistic_form_with(url: "/x", attribute_name: :favorite, value: nil) { |f| "" }
        assert_empty hidden_inputs(html, "favorite")
      end

      test "omitting value suppresses the hidden field" do
        html = optimistic_form_with(url: "/x", attribute_name: :favorite) { |f| "" }
        assert_empty hidden_inputs(html, "favorite")
      end

      test "an explicit optimistic_hidden_field requires a value" do
        assert_raises(ArgumentError) do
          optimistic_form_with(url: "/x") { |form| form.optimistic_hidden_field(:favorite) }
        end
      end

      private

      def fragment(html)
        Nokogiri::HTML5.fragment(html)
      end

      def hidden_inputs(html, name)
        fragment(html).css("input[type=hidden][name='#{name}']")
      end
    end
  end
end
