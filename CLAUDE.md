# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`hotwire_club-toolbox` is a Rails **engine gem** (namespace `HotwireClub::Toolbox`, Rails ≥ 8.1.3) that packages a collection of **loosely connected Hotwire/Rails tools and techniques**. Each tool is independent — assume no shared runtime coupling between them beyond living in the same engine.

The repo was scaffolded with `rails plugin new` and is currently near-empty (only version/engine boilerplate). The bulk of the work is adding new tools.

## Convention for adding a tool (IMPORTANT)

Every time you build a tool or technique here, you MUST:

1. Implement it under the engine (`app/`, `lib/hotwire_club/toolbox/`, assets, etc.).
2. Write **clear usage instructions** for it as a standalone file in `docs/` (create `docs/` if it doesn't exist yet; one doc per tool).
3. Add a **mention/link to that tool** in `README.md` so the toolbox stays discoverable.

A tool is not "done" until its `docs/` page and README entry exist.

## Commands

```bash
bin/rails test                          # run the full test suite
bin/rails test test/path/to_a_test.rb   # run a single test file
bin/rails test test/path/to_a_test.rb:42  # run test at a line
bin/rails test -n /pattern/             # run tests matching a name pattern
bin/rubocop                             # lint (rubocop-rails-omakase style)
```

`rake` (default task) also runs the tests. Engine-level Rails tasks are exposed via `app:` prefixed tasks (e.g. `bin/rails app:...`), courtesy of `rails/tasks/engine.rake` in the `Rakefile`.

## Architecture

- **Engine, not isolated namespace.** `lib/hotwire_club/toolbox/engine.rb` intentionally does *not* call `isolate_namespace`, so engine code shares the host app's routing/helper namespace. Keep this in mind when adding routes (`config/routes.rb`) or helpers.
- **Entry point:** `lib/hotwire_club/toolbox.rb` requires `version` and `engine`. New top-level requires for tools go here.
- **Testing runs against a dummy host app** at `test/dummy/` (a full Rails app). `test/test_helper.rb` boots `test/dummy/config/environment`. Tests are Minitest; integration tests (e.g. `test/integration/navigation_test.rb`) subclass `ActionDispatch::IntegrationTest` and exercise the engine mounted in the dummy app.
- **Assets:** Propshaft; per-tool CSS/images live under `app/assets/{stylesheets,images}/hotwire_club/toolbox/`.
- **Stack:** sqlite3 + puma in the dummy app; the gem itself only depends on `rails`.
