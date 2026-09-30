# Changelog

All notable changes to this project are documented here.

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
