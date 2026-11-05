"use strict";

/* =========================================================
   LIVE UTC CLOCK
========================================================= */
function updateUtcClock() {
    const clock = document.getElementById("utc-clock");
    if (!clock) return;
    clock.textContent = new Date().toISOString();
}

/* =========================================================
   PORTFOLIO INTERACTION CONTROLLER
========================================================= */
document.addEventListener("DOMContentLoaded", () => {
    updateUtcClock();
    setInterval(updateUtcClock, 1000);

    const portfolioGrid = document.getElementById("portfolio-grid");
    if (!portfolioGrid) return;

    portfolioGrid.addEventListener("click", (event) => {
        const card = event.target.closest(".card");
        if (!card) return;

        // Prevent highlighting when clicking buttons or internal links
        const interactiveElement = event.target.closest("a, button");
        if (interactiveElement) return;

        card.classList.toggle("highlight");
    });
});
