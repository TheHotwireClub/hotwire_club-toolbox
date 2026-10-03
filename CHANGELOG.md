# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Fixed
- The app no longer fails to boot with `uninitialized constant
  HotwireClub::Toolbox::OptimisticFormHelper` when another gem loads
  `ActionView::Base` before the app initializes (prawn-rails does, during
  `Bundler.require`). The engine's `on_load(:action_view)` hook then runs
  immediately, before the main autoloader is set up. The engine's own
  `app/helpers` directory is now managed by the once autoloader, which is
  available during initialization. Nothing else moves: the host app's helpers
  and other engines stay on the main autoloader. The only consequence is that
  the toolbox's helpers are no longer reloaded in development, which suits
  modules mixed into the never-reloaded `ActionView::Base`.

## [0.2.0]

### Changed
- **Optimistic Form**: reconciliation moved from the form to the document. The
  controller follows each submission it saw on `turbo:submit-start` and
  refreshes on its `turbo:submit-end` when it failed, wherever that event is
  dispatched. `optimistic_form_with` / `optimistic_form_for` now wire only
  `turbo:submit-start->optimistic-form#apply`; the
  `turbo:submit-end->optimistic-form#refresh` action is gone. A form that
  still carries it (hand-wired, or rendered by a cached fragment) keeps
  working: `refresh` runs once per submission.
- **Upgrading**: apps that copied `optimistic_form_controller.js` (jsbundling,
  vite) must copy the new one before rendering with the 0.2.0 helpers, since
  the old controller only reconciled through the removed action.

### Fixed
- **Optimistic Form**: a failed submission is reconciled when the optimistic
  paint removed the form itself, as a predicted row removal does. Turbo
  dispatches `turbo:submit-end` on `<html>` once the form has left the page,
  so the form-bound action never ran and the removed row stayed gone.

## [0.1.1]

### Added
- **Optimistic Form**: the builder methods (`optimistic_template`,
  `optimistic_hidden_field`) now live in the `OptimisticFormBuilding` mixin, so
  an app can include them in its own form builder. `optimistic_form_with` /
  `optimistic_form_for` keep a `builder:` that includes the mixin and raise
  `ArgumentError` for one that does not, instead of silently replacing it.
  `OptimisticFormBuilder` is unchanged in behaviour (a plain `FormBuilder` with
  the mixin). Documented under "Using your own form builder".

## [0.1.0]

### Added
- Initial release.
- **Optimistic Form** tool: an optimistic-UI form builder for Turbo that paints
  a predicted result on submit and reconciles with the server only on failure.
  Includes a Stimulus controller, an install generator (importmap / jsbundling /
  vite), and documentation in `docs/optimistic-form.md`.
