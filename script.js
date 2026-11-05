"use strict";

/* =========================================================
   LIVE UTC CLOCK
========================================================= */

function updateUtcClock() {
    const clock = document.getElementById("utc-clock");

    if (!clock) {
        return;
    }

    clock.textContent = new Date().toISOString();
}


/* =========================================================
   PORTFOLIO INTERACTION CONTROLLER
========================================================= */

document.addEventListener("DOMContentLoaded", () => {

    /* -----------------------------------------------------
       INITIALISE CLOCK
    ----------------------------------------------------- */

    updateUtcClock();

    setInterval(updateUtcClock, 1000);


    /* -----------------------------------------------------
       EVENT DELEGATION MATRIX

       Clicking on the body of a system card toggles its
       technical focus state.

       Links and buttons are excluded so that external
       navigation behaves normally.
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


        /* Do not interfere with navigation links. */

        const interactiveElement =
            event.target.closest("a, button");

        if (interactiveElement) {
            return;
        }


        /* Toggle technical focus state. */

        card.classList.toggle("highlight");

    });

});
