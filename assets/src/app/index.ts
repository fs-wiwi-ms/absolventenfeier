import "@fortawesome/fontawesome-free/js/all.js";

import flatpickr from "flatpickr";
import { German } from "flatpickr/dist/l10n/de.js";
import "flatpickr/dist/themes/dark.css";

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
    document.querySelectorAll(".datetimepicker"),
    FLATPICKR_DATETIME_CONFIG,
  );
  flatpickr(
    document.querySelectorAll(".datepicker"),
    FLATPICKR_DATE_CONFIG,
  );
}

if (document.readyState !== "loading") {
  initDatePickers();
} else {
  document.addEventListener("DOMContentLoaded", initDatePickers);
}

document.addEventListener("DOMContentLoaded", () => {
  // Get all "navbar-burger" elements
  const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

  // Check if there are any navbar burgers
  if ($navbarBurgers.length > 0) {
    // Add a click event on each of them
    $navbarBurgers.forEach(el => {
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
});

document.querySelector('#open-modal').addEventListener('click', function(event) {
  event.preventDefault();
  var modal = document.querySelector('.modal');  // assuming you have only 1
  var html = document.querySelector('html');
  modal.classList.add('is-active');
  html.classList.add('is-clipped');

  modal.querySelector('.modal-background').addEventListener('click', function(e) {
    e.preventDefault();
    modal.classList.remove('is-active');
    html.classList.remove('is-clipped');
  });

  modal.querySelector('#close-modal').addEventListener('click', function(e) {
    e.preventDefault();
    modal.classList.remove('is-active');
    html.classList.remove('is-clipped');
  });
});

import "./theme.sass";
