import { Controller } from "@hotwired/stimulus";
import { throttle } from "hotwire_club/toolbox/helpers/timing_helpers";

// Applies optimistic UI on form submit by cloning the form's <template>(s)
// into the DOM (Turbo then processes the contained turbo-stream). On submit-end
// it reconciles against the server only when the submission failed, also when
// the paint took the form out of the page.
export default class extends Controller {
  static targets = ["template"];

  initialize() {
    // Throttle so the paint fires immediately, but a burst of rapid submits on
    // the same form can't stack duplicate clones.
    this.apply = throttle(this.apply.bind(this), 200);
  }

  apply(event) {
    if (!this.hasTemplateTarget) return;

    this.reconcileWhenDetached(event?.detail?.formSubmission);

    this.templateTargets.forEach((template) => {
      document.body.appendChild(template.content.cloneNode(true));
    });
  }

  // A prediction may remove the form itself (a deleted row). Turbo then
  // dispatches turbo:submit-end on <html>, where the form's own action never
  // hears it, so this submission is also watched from the document.
  reconcileWhenDetached(formSubmission) {
    if (!formSubmission) return;

    // Not `once`: with several submissions in flight, another form's
    // submit-end may come first, and that one must not consume the listener.
    const onSubmitEnd = (event) => {
      if (event.detail.formSubmission !== formSubmission) return;

      document.removeEventListener("turbo:submit-end", onSubmitEnd);
      // A form still in the page got the event through its action.
      if (!this.element.isConnected) this.refresh(event);
    };

    document.addEventListener("turbo:submit-end", onSubmitEnd);
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
