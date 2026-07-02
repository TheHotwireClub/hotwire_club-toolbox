import { Controller } from "@hotwired/stimulus";
import { throttle } from "hotwire_club/toolbox/helpers/timing_helpers";

// Applies optimistic UI on form submit by cloning the form's <template>(s)
// into the DOM (Turbo then processes the contained turbo-stream). On submit-end
// it reconciles against the server only when the submission failed.
export default class extends Controller {
  static targets = ["template"];

  initialize() {
    // Throttle so the paint fires immediately, but a burst of rapid submits on
    // the same form can't stack duplicate clones.
    this.apply = throttle(this.apply.bind(this), 200);
  }

  apply() {
    if (!this.hasTemplateTarget) return;

    this.templateTargets.forEach((template) => {
      document.body.appendChild(template.content.cloneNode(true));
    });
  }

  refresh(event) {
    // On success the optimistic paint already reflects the new state; only
    // refresh to reconcile when the server rejected the submission.
    if (event.detail?.success) return;

    document.body.insertAdjacentHTML(
      "beforeend",
      '<turbo-stream action="refresh"></turbo-stream>',
    );
  }
}
