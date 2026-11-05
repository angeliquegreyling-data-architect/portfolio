"use strict";

/* =========================================================
   LIVE UTC CLOCK CONTROLLER
========================================================= */

function updateUtcClock() {
    const clock = document.getElementById("utc-clock");

    if (clock) {
        clock.textContent = new Date().toISOString();
    }
}


/* =========================================================
   PORTFOLIO EVENT MATRIX
========================================================= */

document.addEventListener("DOMContentLoaded", () => {

    /* -----------------------------------------------------
       INITIALISE LIVE CLOCK
    ----------------------------------------------------- */

    updateUtcClock();

    setInterval(updateUtcClock, 1000);


    /* -----------------------------------------------------
       EVENT DELEGATION
       
       Clicking anywhere on a portfolio card toggles its
       highlight state. Interactive links and buttons are
       excluded so that external navigation works normally.
    ----------------------------------------------------- */

    const portfolioGrid = document.getElementById("portfolio-grid");

    if (!portfolioGrid) {
        return;
    }

    portfolioGrid.addEventListener("click", (event) => {

        const card = event.target.closest(".card");

        if (!card) {
            return;
        }


        /*
         * Do not toggle the card when the user clicks an
         * external link or action button.
         */

        const interactiveElement = event.target.closest("a, button");

        if (interactiveElement) {
            return;
        }


        /*
         * Toggle focus highlight on the selected system.
         */

        card.classList.toggle("highlight");

    });

});
