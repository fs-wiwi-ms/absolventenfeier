// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
import "@fortawesome/fontawesome-free/js/all.js";

import flatpickr from "flatpickr";
import { German } from "flatpickr/dist/l10n/de.js";
import "flatpickr/dist/themes/dark.css";

declare global {
  interface Window {
    liveSocket: any;
  }
}

// Establish Phoenix Socket and LiveView configuration.
import topbar from "topbar";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  params: {
    _csrf_token: csrfToken,
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// Connect if there are any LiveViews on the page
liveSocket.connect();

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;





const FLATPICKR_DATETIME_CONFIG = {
  altInput: true,
  altFormat: "j. F Y H:i",
  enableTime: true,
  dateFormat: "Z",
  time_24hr: true,
  locale: German,
  placeholder: "Datum auswählen",
};

const FLATPICKR_DATE_CONFIG = {
  altInput: true,
  altFormat: "j. F Y",
  enableTime: false,
  dateFormat: "Y-m-d",
  locale: German,
  placeholder: "Datum auswählen",
};

function initDatePickers() {
  flatpickr(
    document.querySelectorAll(".datetimepicker"), FLATPICKR_DATETIME_CONFIG,
  );
  flatpickr(
    document.querySelectorAll(".datepicker"), FLATPICKR_DATE_CONFIG,
  );
}

function initCheckBoxHideShow() {
  document.querySelector("#checkBoxClick").addEventListener("click", (e) => {
    let checkBox = <HTMLInputElement> document.getElementById("checkBoxElem");
    let content = document.getElementById("checkBoxContent");
    // If the checkbox is checked, display the output text
    if (checkBox.checked == true){
      content.style.display = "block";
    } else {
      content.style.display = "none";
    }
  });
}

function initModals() {
  document.querySelector("#open-modal").addEventListener("click", (e) => {
    e.preventDefault();
    let modal = document.querySelector(".modal");  // assuming you have only 1
    let html = document.querySelector("html");
    modal.classList.add("is-active");
    html.classList.add("is-clipped");

    modal.querySelector(".modal-background").addEventListener("click", (e) => {
      e.preventDefault();
      modal.classList.remove("is-active");
      html.classList.remove("is-clipped");
    });

    modal.querySelector("#close-modal").addEventListener("click", (e) => {
      e.preventDefault();
      modal.classList.remove("is-active");
      html.classList.remove("is-clipped");
    });
  });
}

function initNavBarBurger() {
  // Get all "navbar-burger" elements
  const navbarBurgers = Array.prototype.slice.call(
    document.querySelectorAll(".navbar-burger"),
    0,
  );
  // Check if there are any navbar burgers
  if (navbarBurgers.length > 0) {
    // Add a click event on each of them
    navbarBurgers.forEach((el: any) => {
      el.addEventListener("click", () => {
        // Get the target from the "data-target" attribute
        const target = el.dataset.target;
        const $target = document.getElementById(target);

        // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
        el.classList.toggle("is-active");
        $target.classList.toggle("is-active");
      });
    });
  }
}

function initComponents () {
  initNavBarBurger();
  initDatePickers();
  initCheckBoxHideShow();
  initModals();
}

if (document.readyState !== "loading") {
  initComponents();
} else {
  document.addEventListener("DOMContentLoaded", initComponents);
}

import "./app.sass";
