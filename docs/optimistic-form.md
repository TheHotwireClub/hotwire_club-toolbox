# Optimistic Form

Optimistic UI for Turbo forms. You author the optimistic update as a Turbo Stream inside a `<template>`; on submit, a Stimulus controller clones it into the DOM so Turbo paints it instantly, then reconciles against the server only if the request fails.

Because the optimistic update and the server response speak the same Turbo Stream vocabulary, there is one mental model and no bespoke DOM patching.

## Installation

The tool ships with the `hotwire_club-toolbox` engine. Add the gem, then run the installer:

```bash
bin/rails generate hotwire_club:toolbox:optimistic_form:install
```

The generator detects your JavaScript setup and wires the Stimulus controller:

- **importmap** (the module is pinned by the engine): adds an import and `application.register("optimistic-form", …)` to `app/javascript/controllers/index.js`.
- **jsbundling (esbuild/bun/rollup) or vite**: copies `optimistic_form_controller.js` and `helpers/timing_helpers.js` into `app/javascript/`, rewriting the import to a relative path, and registers the controller.

It also ensures the Turbo morph refresh meta tags (see Prerequisites) are present in your layout.

### Prerequisites

- **Turbo and Stimulus** in the host app.
- **Turbo morph page refreshes.** Reconciliation on failure uses a Turbo refresh, which must morph (not hard reload) to be seamless. The generator adds these to your layout `<head>`:

  ```html
  <meta name="turbo-refresh-method" content="morph">
  <meta name="turbo-refresh-scroll" content="preserve">
  ```

## Basic usage

A favorite toggle. The `optimistic_template` predicts the toggled state; the button shows the current one:

```erb
<%= optimistic_form_for photo, attribute_name: :favorite, value: !photo.favorite do |form| %>
  <%= form.optimistic_template dom_id(photo, "favorite-button-icon"), favorite_button_icon(!photo.favorite) %>
  <%= form.button do %><%= favorite_button_icon(photo.favorite) %><% end %>
<% end %>
```

An add-to-cart button that bumps a counter elsewhere on the page:

```erb
<%= optimistic_form_with url: carts_update_path, method: :patch, attribute_name: :photo_id, value: photo.id do |form| %>
  <%= form.optimistic_template "cart-items-count", (@cart_items_count + 1) %>
  <%= form.button "Add to cart" %>
<% end %>
```

`attribute_name:`/`value:` inject a hidden field carrying the submitted value (see [Hidden field](#hidden-field)).

## The reconciliation model

- **On submit-start**, the controller clones the form's `<template>`(s) into the document. Turbo processes the contained stream and paints the optimistic state.
- **On submit-end**, the controller reconciles **only if the submission failed** (`event.detail.success === false`). On success the optimistic paint already reflects the new state, so nothing happens.

This keeps the happy path free of extra requests. A full page refresh only ever runs when the server rejects the change, which is exactly when you want authoritative truth.

## Server contract

Because success trusts the optimistic paint and failure triggers a client refresh, your controller must respond accordingly:

- **Success:** `head :no_content` (204), or a targeted Turbo Stream (see below). **Do not redirect.** A redirect combined with morph refreshes is itself a full reload, which defeats the optimism.
- **Failure:** respond `4xx`/`422` so `event.detail.success` is false and the client reconciles. Set a flash if you want it surfaced after the refresh.

```ruby
def update
  @photo = Photo.find(params[:id])

  if @photo.update(photo_params)
    head :no_content
  else
    flash[:alert] = "Your changes could not be saved."
    head :unprocessable_entity
  end
end
```

### Authoritative correction on success (opt-in)

If the true value can differ from your prediction under contention (for example a shared counter), return a targeted Turbo Stream on success. Turbo applies it over the optimistic guess; no client change is needed. To keep the prediction and the truth from drifting, render the reconcilable fragment from a **single partial** used in both places:

```erb
<%# app/views/photos/_favorite_button.html.erb (single source of truth) %>
<span id="<%= dom_id(photo, "favorite-button-icon") %>"><%= favorite_button_icon(photo.favorite) %></span>
```

```erb
<%# the optimistic prediction %>
<%= form.optimistic_template dom_id(photo, "favorite-button-icon") do %>
  <%= turbo_stream.update dom_id(photo, "favorite-button-icon") do %>
    <%= favorite_button_icon(!photo.favorite) %>
  <% end %>
<% end %>
```

```ruby
# the authoritative response
render turbo_stream: turbo_stream.update(
  ActionView::RecordIdentifier.dom_id(@photo, "favorite-button-icon"),
  partial: "photos/favorite_button", locals: { photo: @photo }
)
```

## Multiple templates in one form

Declare more than one `optimistic_template` to paint several regions from a single submit (for example a counter and a button). All of them are applied:

```erb
<%= optimistic_form_with url: carts_update_path, method: :patch, attribute_name: :photo_id, value: photo.id do |form| %>
  <%= form.optimistic_template "cart-items-count", (@cart_items_count + 1) %>
  <%= form.optimistic_template dom_id(photo, "favorite-button-icon"), favorite_button_icon(true) %>
  <%= form.button "Add and favorite" %>
<% end %>
```

## Hidden field

Two ways to submit the toggled value, pick one per form:

- **Automatic:** pass `attribute_name:`/`value:` to the form helper and a hidden field is injected for you.
- **Explicit:** call `form.optimistic_hidden_field :favorite, value: !photo.favorite` where you want it. This suppresses the automatic injection.

`value: false` is preserved (a favorite toggle legitimately submits `false`). Only `nil` or an omitted value suppresses the field.

## Block form

Instead of the positional `target, template`, pass a block to author the stream(s) yourself:

```erb
<%= form.optimistic_template do %>
  <%= turbo_stream.update("cart-items-count") { @cart_items_count + 1 } %>
<% end %>
```

## Notes

- **Escaping.** Template content is treated as trusted developer markup, the same as any `turbo_stream.update` body (this is what lets you inject SVG icons). Do not pass unescaped user input; sanitize at the call site if you must.
- **Throttling.** `apply` is throttled per form so a burst of rapid submits cannot stack duplicate clones. The first paint is still immediate.

## API reference

Helpers (available in all views):

- `optimistic_form_with(attribute_name: nil, value: nil, **options, &block)`
- `optimistic_form_for(record, attribute_name: nil, value: nil, **options, &block)`

Both set `options[:builder]` to `OptimisticFormBuilder`; a `builder:` you pass is overridden (the tool's builder methods depend on it).

Builder methods (yielded `form`):

- `optimistic_template(target = nil, template = nil, &block)` - wraps a `turbo_stream.update` (positional) or your block in the tracked `<template>`.
- `optimistic_hidden_field(attribute_name, value:)` - renders the hidden field explicitly and suppresses auto-injection.
