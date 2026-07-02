# HotwireClub::Toolbox

A Rails engine that bundles loosely-connected, production-ready Hotwire and Rails patterns distilled from [The Hotwire Club](https://hotwire.club) challenge series. It's a growing collection, and each tool is independent: pull in the whole engine, use only the pieces you need. There's no shared runtime coupling between them beyond living in the same gem.

## Tools

Each tool has its own usage guide under [`docs/`](docs/).

- **[Optimistic Form](docs/optimistic-form.md)** - optimistic UI for Turbo forms: paint the predicted result instantly on submit, reconcile with the server only on failure.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem "hotwire_club-toolbox"
```

Then run `bundle`.

Each tool ships with its own generator, so you install only what you use. For Optimistic Form:

```bash
bin/rails generate hotwire_club:toolbox:optimistic_form:install
```

## Requirements

- Ruby >= 3.2.0
- Rails >= 8.1.3
- turbo-rails ~> 2.0

## Optimistic Form at a glance

You author the optimistic update as a Turbo Stream inside a `<template>`. On submit, a Stimulus controller clones it into the DOM so Turbo paints it instantly, then reconciles against the server only if the request fails. Here's a favorite toggle: the `optimistic_template` predicts the toggled state, and the button shows the current one.

```erb
<%= optimistic_form_for photo, attribute_name: :favorite, value: !photo.favorite do |form| %>
  <%= form.optimistic_template dom_id(photo, "favorite-button-icon"), favorite_button_icon(!photo.favorite) %>
  <%= form.button do %><%= favorite_button_icon(photo.favorite) %><% end %>
<% end %>
```

Full guide → [docs/optimistic-form.md](docs/optimistic-form.md).

## Contributing

Issues and pull requests are welcome. See the [CHANGELOG](CHANGELOG.md) for what's shipped.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
