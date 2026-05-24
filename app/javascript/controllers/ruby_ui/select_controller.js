import {Controller} from "@hotwired/stimulus";

// TODO: Figure out why the regular import fails.
import {
  computePosition,
  autoUpdate,
  offset,
  flip
} from "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.7.2/+esm";
// import { computePosition, autoUpdate, offset, flip } from "@floating-ui/dom";

export default class extends Controller {
  static targets = [
    "trigger",
    "content",
    "input",
    "value",
    "item",
    "valueContent",
    "filterInput",
    "emptyState",
  ];
  static values = {
    open: Boolean,
    allowCreate: {
      type: Boolean,
      default: false,
    },
  };
  static outlets = ["ruby-ui--select-item"];

  constructor(...args) {
    super(...args);
    this.cleanup = () => {};
  }

  connect() {
    this.setFloatingElement();
    this.generateItemsIds();
    this.filterItems();
  }

  disconnect() {
    this.cleanup();
  }

  selectItem(event) {
    event.preventDefault();

    this.rubyUiSelectItemOutlets.forEach((item) =>
      item.handleSelectItem(event),
    );

    const targetItem = event.target.closest("[data-ruby-ui--select-target='item']");
    const oldValue = this.inputTarget.value;
    const newValue = targetItem.dataset.value;


    this.inputTarget.value = newValue;
    this.valueContentTarget.innerHTML = targetItem.querySelector('[data-ruby-ui--select-target=itemContent]').innerHTML;

    this.dispatchOnChange(oldValue, newValue);
    this.closeContent();
  }

  onClick() {
    this.toogleContent();

    if (this.openValue) {
      this.filterItems();
      this.setFocusAndCurrent();
      this.focusFilterInput();
    } else {
      this.resetCurrent();
    }
  }

  handleKeyDown(event) {
    event.preventDefault();

    const visibleItems = this.visibleItems();
    if (visibleItems.length === 0) return;

    const currentIndex = visibleItems.findIndex(
      (item) => item.getAttribute("aria-current") === "true",
    );
    if (currentIndex === -1) {
      this.setAriaCurrentAndActiveDescendant(0, visibleItems);
      return;
    }

    if (currentIndex + 1 < visibleItems.length) {
      visibleItems[currentIndex].removeAttribute("aria-current");
      this.setAriaCurrentAndActiveDescendant(currentIndex + 1, visibleItems);
    }
  }

  handleKeyUp(event) {
    event.preventDefault();

    const visibleItems = this.visibleItems();
    if (visibleItems.length === 0) return;

    const currentIndex = visibleItems.findIndex(
      (item) => item.getAttribute("aria-current") === "true",
    );
    if (currentIndex === -1) {
      this.setAriaCurrentAndActiveDescendant(visibleItems.length - 1, visibleItems);
      return;
    }

    if (currentIndex > 0) {
      visibleItems[currentIndex].removeAttribute("aria-current");
      this.setAriaCurrentAndActiveDescendant(currentIndex - 1, visibleItems);
    }
  }

  handleEsc(event) {
    event.preventDefault();
    this.closeContent();
  }

  createFromQuery(event) {
    event.preventDefault();

    const createAction = this.createActionElement();
    if (!createAction) return;

    const query = this.currentQuery();
    if (!query) {
      this.focusFilterInput();
      return;
    }

    const oldValue = this.inputTarget.value;
    this.inputTarget.value = query;

    const content = createAction.querySelector(
      "[data-ruby-ui--select-target='itemContent']",
    );
    if (content) {
      this.valueContentTarget.innerHTML = content.innerHTML;
    }

    this.dispatchOnChange(oldValue, query);
    this.closeContent();
  }

  filterItems() {
    const query = this.currentQuery().toLowerCase();
    const hasQuery = query.length > 0;

    let visibleOptionCount = 0;
    this.optionItems().forEach((item) => {
      const searchValue = (item.dataset.search || "").toLowerCase();
      const match = !hasQuery || searchValue.includes(query);
      item.classList.toggle("hidden", !match);
      if (match) visibleOptionCount += 1;
    });

    const blankItem = this.blankItem();
    if (blankItem) {
      blankItem.classList.toggle("hidden", hasQuery);
    }

    if (this.hasEmptyStateTarget) {
      const showEmpty = hasQuery && visibleOptionCount === 0 && !this.allowCreateValue;
      this.emptyStateTarget.classList.toggle("hidden", !showEmpty);
    }

    const createAction = this.createActionElement();
    if (createAction && this.allowCreateValue) {
      const queryText = this.currentQuery();
      const defaultLabel = createAction.dataset.defaultLabel || "";
      const selectedDescription = createAction.dataset.selectedDescription || "";
      const defaultDescription = createAction.dataset.defaultDescription || "";
      createAction.dataset.value = queryText;
      const labelEl = createAction.querySelector("[data-create-action-label]");
      const descriptionEl = createAction.querySelector("[data-create-action-description]");

      if (labelEl) labelEl.textContent = queryText || defaultLabel;
      if (descriptionEl) {
        descriptionEl.textContent = queryText ? selectedDescription : defaultDescription;
      }
    }
  }

  setFocusAndCurrent() {
    const visibleItems = this.visibleItems();
    const selectedItem = visibleItems.find(
      (item) => item.getAttribute("aria-selected") === "true",
    );

    if (selectedItem) {
      selectedItem.focus({preventScroll: true});
      selectedItem.setAttribute("aria-current", "true");
      this.triggerTarget.setAttribute(
        "aria-activedescendant",
        selectedItem.getAttribute("id"),
      );
    } else {
      const firstItem = visibleItems[0];
      if (!firstItem) return;

      firstItem.focus({preventScroll: true});
      firstItem.setAttribute("aria-current", "true");
      this.triggerTarget.setAttribute(
        "aria-activedescendant",
        firstItem.getAttribute("id"),
      );
    }
  }

  resetCurrent() {
    this.itemTargets.forEach((item) => item.removeAttribute("aria-current"));
  }

  clickOutside(event) {
    if (!this.openValue) return;
    if (this.element.contains(event.target)) return;

    event.preventDefault();
    this.closeContent();
  }

  toogleContent() {
    this.openValue = !this.openValue;
    this.contentTarget.classList.toggle("hidden");
    this.triggerTarget.setAttribute("aria-expanded", this.openValue);
  }

  setFloatingElement() {
    this.cleanup = autoUpdate(this.triggerTarget, this.contentTarget, () => {
      computePosition(this.triggerTarget, this.contentTarget, {
        middleware: [offset(4), flip()],
      }).then(({x, y}) => {
        Object.assign(this.contentTarget.style, {
          left: `${x}px`,
          top: `${y}px`,
        });
      });
    });
  }

  generateItemsIds() {
    const contentId = this.contentTarget.getAttribute("id");
    this.triggerTarget.setAttribute("aria-controls", contentId);

    this.itemTargets.forEach((item, index) => {
      item.id = `${contentId}-${index}`;
    });
  }

  setAriaCurrentAndActiveDescendant(currentIndex, items = this.visibleItems()) {
    const currentItem = items[currentIndex];
    if (!currentItem) return;

    currentItem.focus({preventScroll: true});
    currentItem.setAttribute("aria-current", "true");
    this.triggerTarget.setAttribute(
      "aria-activedescendant",
      currentItem.getAttribute("id"),
    );
  }

  closeContent() {
    this.toogleContent();
    this.resetCurrent();
    this.resetFilter();

    this.triggerTarget.removeAttribute("aria-activedescendant");
    this.triggerTarget.focus({preventScroll: true});
  }

  dispatchOnChange(oldValue, newValue) {
    if (oldValue === newValue) return;

    const event = new InputEvent("change", {
      bubbles: true,
      cancelable: true,
    });

    this.inputTarget.dispatchEvent(event);
  }

  visibleItems() {
    return this.scopedItems().filter((item) => !item.classList.contains("hidden"));
  }

  optionItems() {
    return this.scopedItems().filter((item) => item.dataset.kind === "option");
  }

  blankItem() {
    return this.scopedItems().find((item) => item.dataset.kind === "blank");
  }

  focusFilterInput() {
    if (!this.hasFilterInputTarget) return;

    this.filterInputTarget.focus({preventScroll: true});
  }

  resetFilter() {
    if (this.hasFilterInputTarget) {
      this.filterInputTarget.value = "";
    }
    this.filterItems();
  }

  scopedItems() {
    return [...this.contentTarget.querySelectorAll("[data-ruby-ui--select-target='item']")];
  }

  currentQuery() {
    return this.hasFilterInputTarget
      ? this.filterInputTarget.value.trim()
      : "";
  }

  createActionElement() {
    return this.contentTarget.querySelector("[data-kind='create-action']");
  }
}
