class Photo < ApplicationRecord
  # Used by the failure-reconciliation demo/tests: saving under this context
  # always fails so the optimistic UI has to reconcile.
  validate :always_fail, on: :demo_failure

  private

  def always_fail
    errors.add(:base, "This is a simulated failure")
  end
end
