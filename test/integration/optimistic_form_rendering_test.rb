require "test_helper"

module HotwireClub
  module Toolbox
    # Renders the dummy app's photos index (a full view context) to exercise the
    # parts of the form builder that depend on turbo-rails' stream tag builder.
    class OptimisticFormRenderingTest < ActionDispatch::IntegrationTest
      setup { get "/photos" }

      test "wires the optimistic-form controller and submit actions onto forms" do
        assert_select "form[data-controller~=?]", "optimistic-form"
        assert_select "form[data-action*=?]", "turbo:submit-start->optimistic-form#apply"
        assert_select "form[data-action*=?]", "turbo:submit-end->optimistic-form#refresh"
      end

      test "renders optimistic templates as turbo-stream updates" do
        photo = photos(:one)

        assert_select "template[data-optimistic-form-target=template]" do
          assert_select "turbo-stream[action=update][target=?]", "cart-items-count"
          assert_select "turbo-stream[action=update][target=?]",
            ActionView::RecordIdentifier.dom_id(photo, "favorite-button-icon")
        end
      end

      test "supports multiple optimistic templates in one form" do
        photo = photos(:one)
        multi = css_select("form").find { |f| f.css("turbo-stream").size == 2 }

        assert_not_nil multi, "expected a form with two optimistic templates"
        targets = multi.css("turbo-stream").map { |s| s["target"] }
        assert_includes targets, "cart-items-count"
        assert_includes targets, ActionView::RecordIdentifier.dom_id(photo, "favorite-button-icon")
      end

      test "auto-injects the hidden field for the cart form" do
        assert_select "input[type=hidden][name=photo_id]"
      end
    end
  end
end
