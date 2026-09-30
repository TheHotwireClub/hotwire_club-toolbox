module HotwireClub
  module Toolbox
    # The default builder for `optimistic_form_with` / `optimistic_form_for`:
    # Rails' FormBuilder plus the optimistic-UI methods. Apps with a builder of
    # their own include `OptimisticFormBuilding` in it instead.
    class OptimisticFormBuilder < ActionView::Helpers::FormBuilder
      include OptimisticFormBuilding
    end
  end
end
