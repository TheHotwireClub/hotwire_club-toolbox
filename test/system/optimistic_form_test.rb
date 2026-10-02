require "application_system_test_case"

class OptimisticFormTest < ApplicationSystemTestCase
  setup do
    @photo = photos(:one)
    @icon = "##{ActionView::RecordIdentifier.dom_id(@photo, "favorite-button-icon")}"
  end

  test "optimistically toggles and persists on success" do
    visit photos_path
    assert_selector @icon, text: "☆"

    click_on "Favorite"

    # Optimistic paint stays because the server responds 204 (no refresh).
    assert_selector @icon, text: "★"
    assert @photo.reload.favorite
  end

  test "optimistically increments the cart count on success" do
    visit photos_path
    assert_selector "#cart-items-count", text: "0"

    click_on "Add to cart"

    assert_selector "#cart-items-count", text: "1"
  end

  test "reverts and flashes when the server rejects the change" do
    visit photos_path

    click_on "Favorite (fails)"

    # 422 -> the controller refreshes, reconciling the optimistic paint back to
    # the server's truth and surfacing the flash.
    assert_selector "#alert", text: "could not be saved"
    assert_selector @icon, text: "☆"
    assert_not @photo.reload.favorite
  end

  test "applies multiple optimistic templates from one form" do
    visit photos_path
    assert_selector "#cart-items-count", text: "0"
    assert_selector @icon, text: "☆"

    click_on "Add and favorite"

    assert_selector "#cart-items-count", text: "1"
    assert_selector @icon, text: "★"
  end

  test "a form without an optimistic template submits without error" do
    visit photos_path

    click_on "Add without template"

    # No optimistic paint and success is 204, so the UI is unchanged and intact.
    assert_selector "h1", text: "Photos"
    assert_selector "#cart-items-count", text: "0"
  end

  test "optimistically removes a row whose form goes with it" do
    visit photos_path
    row = "##{ActionView::RecordIdentifier.dom_id(@photo)}"

    click_on "Remove"

    assert_no_selector row
    # Waits for the response: the paint alone would also pass the line above.
    assert_no_selector "html[aria-busy]"
    assert_not Photo.exists?(@photo.id)
    assert_no_selector "#alert"
  end

  test "brings a removed row back when the server rejects the removal" do
    visit photos_path
    row = "##{ActionView::RecordIdentifier.dom_id(@photo)}"

    click_on "Remove (fails)"

    # The form left the page with the row, so turbo:submit-end no longer reaches
    # it. The flash only renders through the reconciling refresh.
    assert_selector "#alert", text: "could not be removed"
    assert_selector row
    assert Photo.exists?(@photo.id)
  end
end
