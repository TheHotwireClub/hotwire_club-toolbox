import { Controller } from "@hotwired/stimulus";
import { throttle } from "hotwire_club/toolbox/helpers/timing_helpers";

// Applies optimistic UI on form submit by cloning the form's <template>(s)
// into the DOM (Turbo then processes the contained turbo-stream). Each
// submission is followed from the document until its submit-end, and the page
// is refreshed to reconcile against the server only when the submission failed.
export default class extends Controller {
  static targets = ["template"];

  initialize() {
    // Throttle so the paint fires immediately, but a burst of rapid submits on
    // the same form can't stack duplicate clones.
    this.paint = throttle(this.paint.bind(this), 200);
    this.reconciled = new WeakSet();
  }

  apply(event) {
    this.follow(event?.detail?.formSubmission);
    this.paint();
  }

  paint() {
    if (!this.hasTemplateTarget) return;

    this.templateTargets.forEach((template) => {
      document.body.appendChild(template.content.cloneNode(true));
    });
  }

  // Listened for on the document, not the form: a prediction may remove the
  // form itself (a deleted row), and Turbo then dispatches turbo:submit-end on
  // <html>, where a listener on the form never hears it.
  follow(formSubmission) {
    if (!formSubmission) return;

    // Not `once`: with several submissions in flight, another form's
    // submit-end may come first, and that one must not consume the listener.
    const onSubmitEnd = (event) => {
      if (event.detail.formSubmission !== formSubmission) return;

      document.removeEventListener("turbo:submit-end", onSubmitEnd);
      this.refresh(event);
    };

    document.addEventListener("turbo:submit-end", onSubmitEnd);
  }

  refresh(event) {
    // On success the optimistic paint already reflects the new state; only
    // refresh to reconcile when the server rejected the submission.
    if (event.detail?.success) return;

    // Once per submission, so a form that still carries the pre-0.2 submit-end
    // action does not refresh a second time.
    const { formSubmission } = event.detail ?? {};
    if (formSubmission) {
      if (this.reconciled.has(formSubmission)) return;
      this.reconciled.add(formSubmission);
    }

    // Morph for this refresh alone, so the app's other page refreshes keep their
    // own render. Turbo before 8.0.21 ignores the attributes and falls back to
    // the turbo-refresh-method/-scroll meta tags.
    document.body.insertAdjacentHTML(
      "beforeend",
      '<turbo-stream action="refresh" method="morph" scroll="preserve"></turbo-stream>',
    );
  }
}
